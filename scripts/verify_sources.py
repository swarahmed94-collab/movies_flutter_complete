#!/usr/bin/env python3
"""Dependency-free (stdlib only) source/inventory sanity checks; not a Dart compiler."""
from pathlib import Path
import re
import sys
import zipfile
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
errors=[]
source=list(root.rglob('*.dart'))
for file in source:
    text=file.read_text(encoding='utf-8')
    for imp in re.findall(r'''import\s+['\"]([^'\"]+)['\"]''', text):
        if imp.startswith('.'):
            target=(file.parent/imp).resolve()
        elif imp.startswith('package:movies_app/'):
            target=root/'lib'/imp[len('package:movies_app/'):]
        else:
            continue
        if not target.is_file():errors.append(f'Missing Dart import: {file.relative_to(root)} -> {imp}')
    for asset in re.findall(r'''['\"](assets/(?:images|icons)/[^'\"]+)['\"]''', text):
        if '$' not in asset and not (root/asset).is_file():
            errors.append(f'Missing asset: {file.relative_to(root)} -> {asset}')
    if 'TODO' in text: errors.append(f'Unfinished TODO in {file.relative_to(root)}')
for svg in (root/'assets/icons').glob('*.svg'):
    try: ET.parse(svg)
    except ET.ParseError as e:errors.append(f'Invalid SVG: {svg.name}: {e}')
for i in range(6):
    if not (root/f'assets/images/onboarding_{i}.jpg').is_file():errors.append(f'Missing onboarding {i}')
for i in range(9):
    if not (root/f'assets/images/avatar_{i}.png').is_file():errors.append(f'Missing avatar {i}')
exports=list((root/'design_reference/screens').glob('*.png'))
if len(exports)!=20: errors.append(f'Expected 20 PNG exports, got {len(exports)}')
print(f'{len(source)} Dart files; {len(exports)} reference PNGs; {len(list((root/"assets/icons").glob("*.svg")))} SVGs')
if errors:
    print('\n'.join(errors))
    sys.exit(1)
print('Source reference checks PASSED (Flutter compilation not checked)')
