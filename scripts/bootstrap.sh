#!/usr/bin/env bash
set -euo pipefail
# Run from the root of the extracted project after installing Flutter/FlutterFire.
command -v flutter >/dev/null || { echo 'Flutter SDK is required'; exit 2; }
flutter create --project-name movies_app --platforms=android,ios .
flutter pub get
if command -v flutterfire >/dev/null; then
  flutterfire configure
else
  echo 'Install FlutterFire CLI: dart pub global activate flutterfire_cli'
fi
flutter analyze
flutter test
