# Movies — Onboarding & Safe Area UI Patch

## What was fixed

- The original six exported `onboarding_*.jpg` files included Figma captions and panels baked into each JPG. The app also rendered titles and descriptions through Flutter Text widgets, creating doubled and overlapping text. The six new `onboarding_art_*.jpg` files contain the photo/artwork only. `AppAssets.onboarding()` now selects those assets. Titles, subtitles and buttons remain real widgets.
- The onboarding footer uses a scroll-constrained bottom panel so long captions and buttons remain accessible at different heights.
- Search and Browse content now starts below iOS status-bar / Dynamic Island insets.
- The Movie Details back/bookmark row now sits inside the device's top SafeArea, making Back tappable outside the notch.
- Home content starts below the top SafeArea, and the bottom navigation has a proper bottom SafeArea so it avoids the home indicator.

## Files included

The patch contains only seven changed Dart source files and six new assets. It intentionally does NOT include or modify `ios/Podfile`, `ios/Runner`, `lib/firebase_options.dart`, Firebase configurations, Android files, REST repositories, or authentication code.

## How to apply on your Mac

1. Close any active Flutter debug session. Keep your current project and its Firebase/iOS settings.
2. Back up your current project folder (copy `movies_flutter_complete` to `movies_flutter_complete_backup`).
3. Place this ZIP in Downloads. Open VS Code Terminal in the root of your existing `movies_flutter_complete` folder. Confirm `pwd` points to that folder.
4. Run:

   ```bash
   unzip -o ~/Downloads/Movies_UI_Onboarding_SafeArea_Patch.zip -d .
   flutter pub get
   ```

5. Fully STOP and RUN the app again so new image assets are bundled. The UI patch does not require reinstalling CocoaPods or changing Firebase. For an already-paired device, choose SWAR in Xcode or run Flutter with the current device ID shown by `flutter devices`.

## Visual QA checklist on your real iPhone

1. Onboarding 1 through 6: captions appear ONCE; each Next/Back/Finish button can be tapped; all text stays within the dark panel.
2. Search: input, search icon and clear icon sit BELOW the Dynamic Island; keyboard opens and closes normally.
3. Browse: genre pills are below the top inset; genre switching works.
4. Movie Details: Back and bookmark buttons are below the notch, can be tapped, and don't overlap it; scroll to lower content still works.
5. Bottom navigation: all four icons sit above the home indicator and remain tappable.
6. Verify on a smaller iPhone / landscape / larger text setting and record new screenshots for fine visual adjustments.

## Important

These changes were checked against the 20 supplied design PNG exports, the image ZIP, and the supplied Flutter source code. They have passed basic local source-path/asset checks. The Flutter SDK and an iPhone simulator are not available in this environment, so this patch has NOT been compiled or visually tested on your device. The original editable Figma layers were unavailable; final pixel-level verification must be done on a device screenshot.
