#!/usr/bin/env python3
"""Non-destructive Movies trailer upgrade.

Edits only the existing Movie Details tap handler and creates the new player screen.
Never modifies any current UI widgets, assets, Firebase, API, router, or iOS files.
"""
from __future__ import annotations

import argparse
from datetime import datetime
from pathlib import Path
import re
import shutil
import sys

DETAILS = Path('lib/features/movies/presentation/screens/movie_details_screen.dart')
PLAYER = Path('lib/features/movies/presentation/screens/trailer_player_screen.dart')
IMPORT = "import 'trailer_player_screen.dart';"
OLD_WATCH_RE = re.compile(
    r'Future\s*<\s*void\s*>\s+_watch\s*\(\s*BuildContext\s+context\s*,\s*Movie\s+movie\s*\)\s*async\s*\{'
)

NEW_WATCH = '''Future<void> _watch(BuildContext context, Movie movie) async {
    // MOVIES_TRAILER_ONLY_V1: keep the existing Figma Play/Watch buttons;
    // only change where their existing callback navigates.
    final library = context.read<LibraryCubit>();
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => MoviesTrailerPlayerScreen(movie: movie),
    ));
    // Retain the app's existing watch-history behavior without changing Firestore.
    final failure = await library.recordHistory(movie);
    if (context.mounted && failure != null) {
      showAppError(context, failure.message);
    }
  }'''


def matching_close_brace(src: str, start: int) -> int:
    """Find the closing brace of one known Dart function; strings/comments ignored."""
    depth = 0
    quote = None
    escaped = False
    line_comment = False
    block_comment = False
    i = start
    while i < len(src):
        c = src[i]
        nextc = src[i + 1] if i + 1 < len(src) else ''
        if line_comment:
            if c == '\n': line_comment = False
        elif block_comment:
            if c == '*' and nextc == '/':
                block_comment = False
                i += 1
        elif quote:
            if escaped: escaped = False
            elif c == '\\': escaped = True
            elif c == quote: quote = None
        elif c == '/' and nextc == '/':
            line_comment = True
            i += 1
        elif c == '/' and nextc == '*':
            block_comment = True
            i += 1
        elif c in ("'", '"'):
            quote = c
        elif c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    raise ValueError('Cannot find end of _watch method. Source differs; stopping.')


def prepare(details: str) -> tuple[str, str]:
    if 'MOVIES_TRAILER_ONLY_V1' in details:
        return details, 'Already installed'
    if '_watchTrailer(' in details:
        # This is a known earlier patch that already contains an embedded player.
        if ('Find Full Movie on YouTube' in details
                and 'AppRouter.trailer' in details):
            return details, 'Earlier in-app trailer patch already installed; no changes'
        raise ValueError('Custom _watchTrailer flow detected; no automatic overwrite')
    matches = list(OLD_WATCH_RE.finditer(details))
    if len(matches) != 1:
        raise ValueError('Expected one known _watch(BuildContext, Movie) method; none/ambiguous')
    match = matches[0]
    function = details[match.start():matching_close_brace(details, match.end() - 1)]
    for required in ('movie.trailerCode.trim()', 'launchUrl(', 'recordHistory(movie)'):
        if required not in function:
            raise ValueError(f'The existing _watch was customized (missing {required}); refusing overwrite')
    # Only one existing handler is replaced; no widget/layout changes.
    updated = details.replace(function, NEW_WATCH, 1)
    if IMPORT not in updated:
        position = updated.find("import 'package:flutter/material.dart';")
        if position < 0:
            raise ValueError('Cannot identify safe import insertion point')
        updated = updated[:position] + IMPORT + '\n' + updated[position:]
    return updated, 'Updated existing Play/Watch tap callback; all UI remains unchanged'


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--project', default='.', type=Path)
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args()
    root = args.project.expanduser().resolve()
    template = Path(__file__).resolve().parent.parent / 'patch_templates' / 'trailer_player_screen.dart'
    try:
        if not (root / 'pubspec.yaml').is_file() or not (root / DETAILS).is_file():
            raise ValueError('Run this from your movies_flutter_complete project root')
        original = (root / DETAILS).read_text(encoding='utf-8')
        amended, message = prepare(original)
        player_exists = (root / PLAYER).is_file()
        if 'Earlier in-app trailer patch' in message:
            if not player_exists:
                raise ValueError('Prior trailer handler found but player file missing; cannot safely adapt')
            print(message)
            print('Nothing to overwrite. If your old trailer does not play, send the two small movie screen Dart files.')
            return 0

        contents = template.read_bytes()
        changes: dict[Path, bytes] = {}
        if amended != original:
            changes[DETAILS] = amended.encode('utf-8')
        if player_exists:
            if (root / PLAYER).read_bytes() != contents:
                raise ValueError('trailer_player_screen.dart already exists with different content; refusing overwrite')
        else:
            changes[PLAYER] = contents
        print(message)
        print('Files to create/update:', len(changes))
        for rel in changes:
            print('  ', rel, '(NEW)' if not (root / rel).exists() else '(MODIFIED)')
        if args.dry_run:
            print('DRY RUN: project untouched')
            return 0
        if not changes:
            print('Everything is already installed.')
            return 0
        backup = root / '.movies_trailer_backups' / datetime.now().strftime('%Y%m%d_%H%M%S_%f')
        try:
            for rel in changes:
                target = root / rel
                if target.exists():
                    backup_file = backup / rel
                    backup_file.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(target, backup_file)
            for rel, data in changes.items():
                target = root / rel
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(data)
        except Exception:
            for rel in changes:
                old = backup / rel
                dest = root / rel
                if old.exists(): shutil.copy2(old, dest)
                elif dest.exists(): dest.unlink()
            raise
        print('SUCCESS: In-app trailer player code installed.')
        print('Backup (only if an old file was replaced):', backup)
        print('Next: flutter pub add "youtube_player_iframe:^5.2.2"')
        print('Firebase / API / app router / existing widgets / icons / Podfile untouched.')
        return 0
    except (OSError, ValueError, UnicodeError) as exc:
        print('STOPPED SAFELY:', exc, file=sys.stderr)
        print('No existing project files changed.', file=sys.stderr)
        return 3


if __name__ == '__main__':
    sys.exit(main())
