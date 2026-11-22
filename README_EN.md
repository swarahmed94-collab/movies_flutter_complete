# Movies UI precision patch — visual-only update

Changes precisely 7 files when applicable: six smooth SVG icon assets (`home`, `search`, `browse`, `profile`, `back`, `bookmark`) and the floating bottom tab-bar layout in `lib/features/navigation/presentation/screens/app_shell.dart`.

The vector shapes were manually reconstructed from exported Figma screenshots, not obtained from the original editable Figma paths. Expect a crisp result, with small visual differences possible. Back is a left chevron; bookmark is a filled ribbon. Existing navigation, bookmarking, Firebase, REST API, trailer, and login behaviors remain untouched.

From the Flutter project root after copying this ZIP into Downloads:

```bash
unzip -o ~/Downloads/Movies_Navigation_Icons_Precision_Patch.zip -d .
python3 scripts/apply_precise_nav_patch.py --dry-run
python3 scripts/apply_precise_nav_patch.py
flutter pub get
flutter run -d 00008140-00063DA92252801C
```

The installer validates source compatibility and creates a backup under `.movies_ui_backups/`. If the installed version of `app_shell.dart` differs from recognized variants, it stops safely without overwriting your customized Dart code. No generated build outputs or native configuration files are included. Restart the app after patching; Hot Reload alone may not refresh asset changes.

The installer has been checked against two prior app-shell variants and validated for reruns. Flutter/Xcode compilation and on-device pixel matching have not been performed in this environment.
