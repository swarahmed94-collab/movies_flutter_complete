#!/usr/bin/env python3
"""Safely apply only screenshot-derived UI changes to an existing Movies Flutter project.

- No change to Firebase, YTS, CocoaPods, iOS signing, pubspec, or data layers.
- Existing files are backed up before writes.
- Recognizes the initial delivered Home/Details/Shell code and their follow-up patches.
"""
from __future__ import annotations
import argparse
from datetime import datetime, timezone
from pathlib import Path
import re
import shutil
import sys

FILE_SHELL = Path('lib/features/navigation/presentation/screens/app_shell.dart')
FILE_HOME = Path('lib/features/movies/presentation/screens/home_tab.dart')
FILE_DETAILS = Path('lib/features/movies/presentation/screens/movie_details_screen.dart')

NEW_SHELL = '''child:Scaffold(
      // MOVIES_UI_FULL_BLEED_V1: the content fills the viewport; navigation floats over it.
      backgroundColor: AppColors.background,
      extendBody: true,
      body: Stack(children: [
        Positioned.fill(child:IndexedStack(index:index,children:[
          HomeTab(onBrowseGenre:showBrowse),
          Padding(padding:EdgeInsets.only(bottom:84.h),child:const SearchTab()),
          Padding(padding:EdgeInsets.only(bottom:84.h),
            child:BrowseTab(key:ValueKey(browseGenre),initialGenre:browseGenre)),
          Padding(padding:EdgeInsets.only(bottom:84.h),child:const ProfileTab()),
        ])),
        Align(alignment:Alignment.bottomCenter,child:SafeArea(
          top:false,
          minimum:EdgeInsets.only(bottom:8.h),
          child:Padding(
            padding:EdgeInsets.symmetric(horizontal:9.w),
            child:Material(
              color:AppColors.surface,
              borderRadius:BorderRadius.circular(15.r),
              clipBehavior:Clip.antiAlias,
              child:SizedBox(height:60.h,child:Row(children:[
                _item(0,AppAssets.homeIcon),
                _item(1,AppAssets.searchIcon),
                _item(2,AppAssets.browseIcon),
                _item(3,AppAssets.profileIcon),
              ])),
            ),
          ),
        )),
      ]),
    ));
  '''

HOME_BACKGROUND = '''return Stack(fit:StackFit.expand,children:[
        // MOVIES_UI_FULL_BLEED_HERO_V1
        Positioned.fill(child:state.featured.isEmpty
          ? const ColoredBox(color:AppColors.background)
          : Opacity(opacity:.12,child:PosterImage(
              url:state.featured[focused.clamp(0,state.featured.length-1).toInt()].backgroundImage))),
        const Positioned.fill(child:DecoratedBox(decoration:BoxDecoration(
          gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,
            colors:[Color(0x99121312),AppColors.background])))),
        SafeArea(top:true,bottom:false,child:RefreshIndicator('''

# An inline image-view doesn't get drawn as a static screenshot; this is a real Flutter widget.
WATCH_BUTTON = '''SizedBox(width:double.infinity,height:58.h,
      child:ElevatedButton(
        onPressed:()=>{action}(context,movie),
        style:ElevatedButton.styleFrom(
          backgroundColor:AppColors.destructive,
          foregroundColor:Colors.white,
          padding:EdgeInsets.zero,
          elevation:0,
          shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(15.r))),
        child:Text(AppStrings.text(context,'Watch'),
          style:TextStyle(fontSize:20.sp,fontWeight:FontWeight.w700)),
      ))'''


def patch_shell(source: str) -> tuple[str, str]:
    if 'MOVIES_UI_FULL_BLEED_V1' in source:
        return source, 'already applied'
    start = source.find('child:Scaffold(')
    end = source.find('  Widget _item(', start)
    if start < 0 or end < 0:
        raise ValueError('AppShell Scaffold layout does not match the known versions')
    segment = source[start:end]
    if not all(s in segment for s in ('IndexedStack(', 'HomeTab(', 'SearchTab(', 'BrowseTab(', 'ProfileTab(', 'bottomNavigationBar:')):
        raise ValueError('AppShell has custom navigation; refusing to overwrite it')
    return source[:start] + NEW_SHELL + source[end:], 'full-bleed shell + floating accessible bottom bar'


def patch_home(source: str) -> tuple[str, str]:
    if 'MOVIES_UI_FULL_BLEED_HERO_V1' in source:
        return source, 'already applied'
    safe = 'return SafeArea(top:true,bottom:false,child:RefreshIndicator('
    legacy = 'return RefreshIndicator('
    if safe in source:
        source = source.replace(safe, HOME_BACKGROUND, 1)
        # only inside HomeBodyState's BlocBuilder, before the _section method
        split_mark = '  Widget _section('
        head, tail = source.split(split_mark, 1)
        finish = '      ));\n    });'
        if head.count(finish) != 1:
            raise ValueError('Home scroll end does not match the expected SafeArea close')
        head = head.replace(finish, '      ))]);\n    });', 1)
        source = head + split_mark + tail
    elif legacy in source:
        source = source.replace(legacy, HOME_BACKGROUND, 1)
        split_mark = '  Widget _section('
        head, tail = source.split(split_mark, 1)
        finish = '      );\n    });'
        if head.count(finish) != 1:
            raise ValueError('Home scroll end does not match original version')
        head = head.replace(finish, '      ))]);\n    });', 1)
        source = head + split_mark + tail
    else:
        raise ValueError('Home scroll structure is not recognized')

    # Avoid painting the same background twice, remove only the original limited-to-hero overlay.
    duplicate = '''            if(state.featured.isNotEmpty)
              Positioned.fill(child:Opacity(opacity:.18,child:PosterImage(
                url:state.featured[focused.clamp(0,state.featured.length-1).toInt()].backgroundImage))),
'''
    if duplicate in source:
        source = source.replace(duplicate, '', 1)
    # Space for the floating bottom bar so the last carousel is never obscured.
    bottom = 'SliverToBoxAdapter(child:SizedBox(height:18.h)),'
    if bottom in source:
        source = source.replace(bottom, 'SliverToBoxAdapter(child:SizedBox(height:108.h)),', 1)
    # Avoid clipped overscroll on short lists and support pull-to-refresh on large phones.
    source = source.replace('child:CustomScrollView(slivers:[',
        'child:CustomScrollView(physics:const AlwaysScrollableScrollPhysics(),slivers:[', 1)
    return source, 'viewport-filling Home background + uninterrupted scrolling'


def patch_details(source: str) -> tuple[str, str]:
    if 'MOVIES_UI_WATCH_BUTTON_V1' in source:
        return source, 'already applied'
    # Only update the button's appearance, not what pressing it calls.
    expr = re.compile(r"PrimaryButton\(text:'Watch(?: Trailer)?',color:AppColors\.destructive,foreground:Colors\.white,\s*height:42,onPressed:\(\)=>(_[A-Za-z0-9_]+)\(context,movie\)\)")
    match = expr.search(source)
    if not match:
        raise ValueError('Watch button action/layout differs from delivered versions; leave unchanged')
    # Keep the current _watchTrailer or _watch action name intact.
    replacement = '/* MOVIES_UI_WATCH_BUTTON_V1 */\n    '+WATCH_BUTTON.format(action=match.group(1))
    source = source[:match.start()] + replacement + source[match.end():]
    old_pad = 'Padding(padding:EdgeInsets.fromLTRB(11.w,10.h,11.w,40.h)'
    if old_pad in source:
        source = source.replace(old_pad, 'Padding(padding:EdgeInsets.fromLTRB(16.w,10.h,16.w,40.h)', 1)
    # Restore a top safe inset when older version is present.
    source = source.replace('SafeArea(top:false,bottom:false,child:Align(',
        'SafeArea(top:true,bottom:false,child:Align(', 1)
    # Play button follows screenshot's larger round two-ring treatment.
    source = source.replace('Container(width:69.w,height:69.w,', 'Container(width:96.w,height:96.w,', 1)
    source = source.replace('border:Border.all(color:Colors.white,width:5.w)',
        'border:Border.all(color:Colors.white,width:6.w)',1)
    source = source.replace('Container(width:47.w,height:47.w,', 'Container(width:65.w,height:65.w,',1)
    source = source.replace("AppIcon('assets/icons/play.svg',size:21,", "AppIcon('assets/icons/play.svg',size:28,",1)
    return source, 'Figma-sized 398×58 red Watch CTA + original action preserved + larger play ring'


def main() -> int:
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--project',type=Path,default=Path.cwd(),help='Flutter project root (defaults to current directory)')
    ap.add_argument('--dry-run',action='store_true',help='Validate and report changes without writing')
    args=ap.parse_args()
    root=args.project.expanduser().resolve()
    source_icons=Path(__file__).resolve().parent.parent/'ui_patch_assets'/'icons'
    if not (root/'pubspec.yaml').is_file() or not (root/FILE_SHELL).is_file():
        print('ERROR: Open Terminal in the movies_flutter_complete project folder, not inside ios/ or Downloads.',file=sys.stderr)
        return 2
    try:
        edits={}
        notes=[]
        for rel, fn in ((FILE_SHELL,patch_shell),(FILE_HOME,patch_home),(FILE_DETAILS,patch_details)):
            original=(root/rel).read_text(encoding='utf-8')
            updated,note=fn(original)
            if updated.count('{')!=updated.count('}'):
                raise ValueError(f'Unbalanced Dart braces after patching {rel}')
            if updated.count('(')!=updated.count(')'):
                # This sanity check is conservative; patch deliberate widget adds pairs.
                raise ValueError(f'Unbalanced Dart parentheses after patching {rel}')
            notes.append(f'{rel}: {note}')
            if updated != original:
                edits[rel]=updated.encode('utf-8')
        for file in sorted(source_icons.glob('*.svg')):
            rel=Path('assets/icons')/file.name
            content=file.read_bytes()
            if not (root/rel).is_file():
                raise ValueError(f'Missing referenced icon path: {rel}')
            if (root/rel).read_bytes()!=content:
                edits[rel]=content
    except (ValueError,OSError) as exc:
        print(f'NO FILES CHANGED — safety check failed: {exc}',file=sys.stderr)
        print('Your version may contain additional UI edits. Do not overwrite it with older screens.',file=sys.stderr)
        return 3
    print('\n'.join(notes))
    print(f'Files to update: {len(edits)} (Dart layout: {sum(p.suffix==".dart" for p in edits)}, SVG assets: {sum(p.suffix==".svg" for p in edits)})')
    if args.dry_run or not edits:
        if not edits:print('Already up to date.')
        return 0
    now=datetime.now(timezone.utc).strftime('%Y%m%d_%H%M%S_%f')
    backup=root/'.movies_ui_backups'/now
    try:
        for rel in edits:
            dst=backup/rel;dst.parent.mkdir(parents=True,exist_ok=True)
            shutil.copy2(root/rel,dst)
        for rel,data in edits.items():
            dst=root/rel
            dst.write_bytes(data)
    except Exception as exc:
        for rel in edits:
            if (backup/rel).exists():shutil.copy2(backup/rel,root/rel)
        print(f'ERROR — restored original files: {exc}',file=sys.stderr)
        return 4
    print('UI patch applied successfully.')
    print('Backup created at:',backup)
    print('No Firebase / API / Podfile / Xcode / pubspec files changed.')
    print('Run: flutter pub get && flutter run -d <your-device-id>')
    return 0

if __name__=='__main__':raise SystemExit(main())
