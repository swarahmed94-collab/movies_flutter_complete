#!/usr/bin/env python3
"""Surgical UI-only Movies patch: smooth vector icons + lower floating navigation.

No editing Firebase, API, user features, pubspec, CocoaPods or signing settings.
Validates and creates a timestamped backup before changing local Dart / SVG files.
"""
from __future__ import annotations
import argparse
from datetime import datetime
from pathlib import Path
import shutil
import sys
import xml.etree.ElementTree as ET

SHELL=Path('lib/features/navigation/presentation/screens/app_shell.dart')
DETAILS=Path('lib/features/movies/presentation/screens/movie_details_screen.dart')
ICONS=('home.svg','search.svg','browse.svg','profile.svg','back.svg','bookmark.svg')

NAV_NODE='''Positioned(
          // MOVIES_FIGMA_NAV_PRECISION_V2: float close to the bottom, above the gesture handle.
          left: 9.w,
          right: 9.w,
          bottom: 8.h + MediaQuery.of(context).padding.bottom * 0.15,
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15.r),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 58.h,
              child: Row(children: [
                _item(0, AppAssets.homeIcon),
                _item(1, AppAssets.searchIcon),
                _item(2, AppAssets.browseIcon),
                _item(3, AppAssets.profileIcon),
              ]),
            ),
          ),
        )'''

LEGACY_SCAFFOLD='''child:Scaffold(
      // MOVIES_FIGMA_NAV_PRECISION_V2: content fills screen; bottom bar overlays content.
      backgroundColor: AppColors.background,
      extendBody: true,
      body: Stack(children: [
        Positioned.fill(child: IndexedStack(index: index,children: [
          HomeTab(onBrowseGenre: showBrowse),
          Padding(padding: EdgeInsets.only(bottom: 80.h),child: const SearchTab()),
          Padding(padding: EdgeInsets.only(bottom: 80.h),child:
            BrowseTab(key: ValueKey(browseGenre),initialGenre: browseGenre)),
          Padding(padding: EdgeInsets.only(bottom: 80.h),child: const ProfileTab()),
        ])),
        '''+NAV_NODE+''',
      ]),
    ));
  '''

def match_parens(text: str, start: int)->int:
    """Return index after balanced (...) for a known widget constructor."""
    at=text.find('(',start)
    if at<0: raise ValueError('Opening parenthesis not found')
    depth=0
    quote=None
    escaped=False
    for i in range(at,len(text)):
        c=text[i]
        if quote:
            if escaped: escaped=False
            elif c=='\\': escaped=True
            elif c==quote: quote=None
            continue
        if c in ('"',"'"): quote=c;continue
        if c=='(':depth+=1
        elif c==')':
            depth-=1
            if depth==0:return i+1
    raise ValueError('Unbalanced widget expression')


def patch_shell(src: str)->tuple[str,str]:
    if 'MOVIES_FIGMA_NAV_PRECISION_V2' in src:
        return src,'Already installed'
    needle='Align(alignment:Alignment.bottomCenter,child:SafeArea('
    if needle in src:
        at=src.index(needle)
        end=match_parens(src,at)
        segment=src[at:end]
        for required in ('_item(0,AppAssets.homeIcon)','_item(3,AppAssets.profileIcon)','SafeArea(', 'Material('):
            if required not in segment:
                raise ValueError('Floating navigation contains custom UI; refusing to overwrite it')
        result=src[:at]+NAV_NODE+src[end:]
        return result,'Replaced tall SafeArea wrapper with lower 58dp floating tab bar'
    # Recognized initial project implementation: convert limited body + bottomNavigationBar
    legacy_start=src.find('child:Scaffold(')
    legacy_end=src.find('  Widget _item(',legacy_start)
    if legacy_start>=0 and legacy_end>=0:
        old=src[legacy_start:legacy_end]
        required=('bottomNavigationBar:Padding(', 'body:IndexedStack(',
                  'HomeTab(onBrowseGenre:showBrowse)', 'const SearchTab()',
                  'BrowseTab(key:ValueKey(browseGenre)', 'const ProfileTab()',
                  '_item(3,AppAssets.profileIcon)')
        if all(token in old for token in required):
            return src[:legacy_start]+LEGACY_SCAFFOLD+src[legacy_end:], 'Converted known original shell to full-screen Stack'
    raise ValueError('Navigation layout differs from both known project versions; no Dart changes made')


def main()->int:
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--project',type=Path,default=Path('.'),help='Flutter project root')
    ap.add_argument('--dry-run',action='store_true')
    opts=ap.parse_args()
    root=opts.project.expanduser().resolve()
    asset_source=Path(__file__).resolve().parent.parent/'ui_patch_assets'/'icons'
    if not (root/'pubspec.yaml').is_file() or not (root/SHELL).is_file():
        print('ERROR: Run inside Flutter project root (movies_flutter_complete).',file=sys.stderr)
        return 2
    try:
        # Confirm the current Details page uses those assets; do not rewrite any trailer or watchlist logic.
        details=(root/DETAILS).read_text(encoding='utf-8')
        if 'assets/icons/back.svg' not in details or 'assets/icons/bookmark.svg' not in details:
            raise ValueError('Details screen does not reference known Back/Bookmark assets')
        orig=(root/SHELL).read_text(encoding='utf-8')
        updated,note=patch_shell(orig)
        if updated.count('{')!=orig.count('{') or updated.count('}')!=orig.count('}'):
            # Strict compare is not suitable when a legacy Stack was inserted. Verify balance instead.
            if updated.count('{')!=updated.count('}'):
                raise ValueError('Unbalanced Dart braces')
        if updated.count('(')!=updated.count(')'):
            raise ValueError('Unbalanced Dart parentheses')
        edits={}
        if orig!=updated: edits[SHELL]=updated.encode('utf-8')
        for name in ICONS:
            src=asset_source/name
            dest=Path('assets/icons')/name
            if not src.is_file() or not (root/dest).is_file():
                raise ValueError(f'Missing icon file {dest}')
            ET.parse(src)
            if b'viewBox=' not in src.read_bytes():
                raise ValueError(f'Non-scalable SVG: {src}')
            if (root/dest).read_bytes()!=src.read_bytes():
                edits[dest]=src.read_bytes()
        print('UI layout:',note)
        print('Files to change:',len(edits))
        for p in edits:print('  ',p)
        if opts.dry_run:
            print('DRY RUN: no files changed.')
            return 0
        if not edits:
            print('Already up to date.')
            return 0
        backup=root/'.movies_ui_backups'/('nav_icons_'+datetime.now().strftime('%Y%m%d_%H%M%S_%f'))
        try:
            for rel in edits:
                destination=backup/rel
                destination.parent.mkdir(parents=True,exist_ok=True)
                shutil.copy2(root/rel,destination)
            for rel,content in edits.items():
                (root/rel).write_bytes(content)
        except Exception:
            for rel in edits:
                back=backup/rel
                if back.exists(): shutil.copy2(back,root/rel)
            raise
        print('SUCCESS: UI-only patch applied.')
        print('Backup:',backup)
        print('Firebase / API / trailer / pubspec / Podfile / iOS project untouched.')
        return 0
    except (ValueError,OSError,ET.ParseError) as ex:
        print('STOPPED SAFELY: '+str(ex),file=sys.stderr)
        print('No files changed. Your modified screen may need a manually adapted patch.',file=sys.stderr)
        return 3

if __name__=='__main__': raise SystemExit(main())
