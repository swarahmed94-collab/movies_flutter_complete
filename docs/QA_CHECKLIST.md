# Shipping quality checklist

## Checks possible in the authoring environment

- [x] Original 20 PNG exports inventoried, including the 430 × 2961 long image.
- [x] Source references and generated image assets present under the project root.
- [x] Movies data layer uses YTS v2 list/details/suggestions paths.
- [x] Auth uses actual Firebase SDK (no mock sign-in flow).
- [x] Firestore owner-based rules included for profile, watchlist and history.
- [x] App router exposes authentication, shell, details and edit routes.
- [x] All 20 exports mapped to screens or interactive state variations.
- [x] No full-page raster screenshot substituted for interactive UI.

## Must be run on a Flutter developer machine — not verified here

- [ ] Run `flutter pub get`, `dart format lib test`, `flutter analyze` and `flutter test`; address any findings.
- [ ] Generate Android/iOS host scaffolds, add Firebase config and run `flutterfire configure`.
- [ ] Enable Firebase email/password and Google OAuth providers, validate sign-in/out and password reset on *real Android and iOS devices*.
- [ ] Deploy `firebase/firestore.rules`; verify a user cannot read another user's documents.
- [ ] Test watchlist add/delete, real-time sync, profile edits, account deletion with reauthentication, and logged-out behavior.
- [ ] Verify the selected YTS-compatible v2 host is accessible on-device; try paging, search, genre filters, details and suggestions.
- [ ] Disable connectivity after a successful API fetch and verify Hive fallback; ensure signed-out users cannot access Firestore-protected documents.
- [ ] Compare each screen to its exported PNG at 430 × 932 and check the scrollable details page at 430 × 2961. Check text scaling, keyboard overflow and small devices.
- [ ] Verify fonts, recreated SVGs, image crop boundaries, padding, safe areas, localization/RTL and contrast against Figma once layer access exists.
- [ ] Test handling when a film has no images, cast or official YouTube trailer.
- [ ] Exercise error flows, expired sessions, double-tap interactions and manual offline mode.
- [ ] Profile release builds, remove unnecessary permissions, and review privacy/distribution policies before app-store launch.

No compiled/release artefact is claimed by this source package. In particular, compilation and pixel-perfect matching have **not** been independently confirmed.
