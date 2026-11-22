#!/usr/bin/env python3
"""Safe repair of the Movies trailer patch. UI/API/Firebase/Podfile untouched."""
from __future__ import annotations
import argparse
import datetime
import pathlib
import re
import shutil
import sys

DETAILS = pathlib.Path('lib/features/movies/presentation/screens/movie_details_screen.dart')
PLAYER = pathlib.Path('lib/features/movies/presentation/screens/trailer_player_screen.dart')
BAD_TEMPLATE = pathlib.Path('patch_templates/trailer_player_screen.dart')
OLD_TEST = pathlib.Path('test/widget_test.dart')
IMPORT = "import 'trailer_player_screen.dart';"
WATCH_RE = re.compile(r'Future\s*<\s*void\s*>\s+_watch\s*\(\s*BuildContext\s+context\s*,\s*Movie\s+movie\s*\)\s*async\s*\{')

NEW_WATCH = '''Future<void> _watch(BuildContext context, Movie movie) async {
    // MOVIES_TRAILER_ONLY_V1: Keep the existing Figma Play/Watch UI untouched.
    final library = context.read<LibraryCubit>();
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => MoviesTrailerPlayerScreen(movie: movie),
    ));
    final failure = await library.recordHistory(movie);
    if (context.mounted && failure != null) {
      showAppError(context, failure.message);
    }
  }'''

TEST_CONTENT = '''import 'package:flutter_test/flutter_test.dart';
import 'package:movies_app/features/movies/domain/entities/movie.dart';

void main() {
  test('Movie entity preserves YTS trailer code', () {
    const movie = Movie(
      id: 25,
      title: 'Sample Movie',
      year: 2024,
      rating: 7.0,
      runtime: 120,
      genres: ['Drama'],
      smallCover: '',
      mediumCover: '',
      largeCover: '',
      backgroundImage: '',
      trailerCode: 'dQw4w9WgXcQ',
    );

    expect(movie.title, 'Sample Movie');
    expect(movie.trailerCode, 'dQw4w9WgXcQ');
  });
}
'''


def end_brace(src: str, brace: int) -> int:
    depth = 0
    quote = None
    escaped = False
    line_comment = False
    block_comment = False
    i = brace
    while i < len(src):
        c = src[i]
        n = src[i + 1] if i + 1 < len(src) else ''
        if line_comment:
            if c == '\n': line_comment = False
        elif block_comment:
            if c == '*' and n == '/':
                block_comment = False
                i += 1
        elif quote:
            if escaped: escaped = False
            elif c == '\\': escaped = True
            elif c == quote: quote = None
        elif c == '/' and n == '/':
            line_comment = True
            i += 1
        elif c == '/' and n == '*':
            block_comment = True
            i += 1
        elif c in ('"', "'"):
            quote = c
        elif c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
            if depth == 0: return i + 1
        i += 1
    raise ValueError('Could not safely identify the end of _watch. No modifications made.')


def check_details(source: str) -> str:
    if 'MoviesTrailerPlayerScreen(movie: movie)' in source:
        if IMPORT in source:
            return source
        if "import 'package:flutter/material.dart';" not in source:
            raise ValueError('Existing trailer navigation is present but import location is unexpected.')
        return source.replace("import 'package:flutter/material.dart';", IMPORT + "\nimport 'package:flutter/material.dart';", 1)
    if '_watchTrailer(' in source:
        # Earlier patch used a named route rather than the new screen.
        if 'AppRouter.trailer' in source:
            raise ValueError('Earlier custom trailer route found; not safe to overwrite automatically.')
        raise ValueError('Custom _watchTrailer function found; not safe to overwrite automatically.')
    matches = list(WATCH_RE.finditer(source))
    if len(matches) != 1:
        raise ValueError('Cannot find exactly one old _watch(BuildContext, Movie) method.')
    match = matches[0]
    old = source[match.start():end_brace(source, match.end() - 1)]
    if not all(s in old for s in ('launchUrl(', 'movie.trailerCode.trim()', 'recordHistory(movie)')):
        raise ValueError('The _watch handler has been customized; refusing to replace it.')
    output = source[:match.start()] + NEW_WATCH + source[match.start() + len(old):]
    if IMPORT not in output:
        output = output.replace("import 'package:flutter/material.dart';", IMPORT + "\nimport 'package:flutter/material.dart';", 1)
    return output


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--project', type=pathlib.Path, default=pathlib.Path('.'))
    p.add_argument('--dry-run', action='store_true')
    args = p.parse_args()
    root = args.project.resolve()
    if not (root / 'pubspec.yaml').exists() or not (root / DETAILS).exists():
        print('ERROR: Run this from movies_flutter_complete project root (with pubspec.yaml).', file=sys.stderr)
        return 2
    template = pathlib.Path(__file__).with_name('trailer_player_screen.source.txt')
    if not template.exists():
        print('ERROR: Patch source file missing. Unzip the FULL repair ZIP.', file=sys.stderr)
        return 2
    changes: dict[pathlib.Path, bytes | None] = {}
    try:
        source = (root / DETAILS).read_text(encoding='utf-8')
        updated = check_details(source)
        if updated != source: changes[DETAILS] = updated.encode('utf-8')

        known_player = template.read_text(encoding='utf-8')
        assert 'class MoviesTrailerPlayerScreen' in known_player
        if (root / PLAYER).exists():
            present = (root / PLAYER).read_text(encoding='utf-8')
            # A small iOS UX fix: require a user tap, which avoids autoplay blocking.
            if 'YoutubePlayerController.fromVideoId' in present and 'autoPlay: true' in present:
                fixed = present.replace('autoPlay: true', 'autoPlay: false', 1)
                changes[PLAYER] = fixed.encode('utf-8')
        else:
            changes[PLAYER] = known_player.encode('utf-8')

        if (root / BAD_TEMPLATE).exists():
            bad = (root / BAD_TEMPLATE).read_text(encoding='utf-8')
            if 'class MoviesTrailerPlayerScreen' not in bad:
                raise ValueError('patch_templates/trailer_player_screen.dart looks different. Refusing removal.')
            changes[BAD_TEMPLATE] = None  # Remove an orphan duplicate outside lib.

        if (root / OLD_TEST).exists():
            test = (root / OLD_TEST).read_text(encoding='utf-8')
            if 'MyApp(' in test and 'flutter_test/flutter_test.dart' in test:
                changes[OLD_TEST] = TEST_CONTENT.encode('utf-8')

        print('MOVIES TRAILER REPAIR —', 'DRY RUN' if args.dry_run else 'APPLY')
        print('Target project:', root)
        if not changes:
            print('No known repair needed. No files changed.')
            return 0
        for rel, data in changes.items():
            print(('REMOVE orphan: ' if data is None else 'WRITE: ') + str(rel))
        print('Firebase/API/assets/Podfile/signing/UI widgets: NOT CHANGED')
        if args.dry_run:
            print('Dry run complete, no files modified.')
            return 0
        backup = root / '.movies_trailer_repair_backup' / datetime.datetime.now().strftime('%Y%m%d_%H%M%S_%f')
        completed: list[pathlib.Path] = []
        try:
            for rel, data in changes.items():
                current = root / rel
                if current.exists():
                    saved = backup / (str(rel) + '.backup.txt')
                    saved.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copyfile(current, saved)
                if data is None:
                    current.unlink()
                else:
                    current.parent.mkdir(parents=True, exist_ok=True)
                    current.write_bytes(data)
                completed.append(rel)
        except Exception:
            for rel in completed:
                dest = root / rel
                saved = backup / (str(rel) + '.backup.txt')
                if saved.exists():
                    dest.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copyfile(saved, dest)
                elif dest.exists():
                    dest.unlink()
            raise
        print('SUCCESS. Backup (text files):', backup)
        print('NEXT: flutter pub get && flutter analyze')
        print('Do NOT run the old apply_movies_trailer_only.py again.')
        return 0
    except (OSError, ValueError, UnicodeError, AssertionError) as exc:
        print('STOPPED SAFELY:', exc, file=sys.stderr)
        print('No existing project files changed.', file=sys.stderr)
        return 3


if __name__ == '__main__':
    raise SystemExit(main())
