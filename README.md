# Movies — Flutter app (Phase 1 + Phase 2 source)

A Flutter movie-discovery application reconstructed **from 20 supplied PNG screen exports**. UI follows the dark/amber styling, 430 × 932 reference viewport, and the scrollable long-form movie-details layout. It uses Clean Architecture, Cubit/BLoC, a YTS v2 REST client, Hive, SharedPreferences, Firebase Authentication, and Firestore.

**Status:** All supplied screen *states* have corresponding interactive UI routes and/or variants in the source. This is a **full source delivery, not a verified release build**: this authoring environment does not have a Flutter/Dart SDK and cannot run `flutter pub get`, `flutter analyze`, widget tests, or a simulator. Native Android/iOS launchers and the project's own Firebase credentials must be generated/configured locally. Exact pixel-perfect fidelity cannot be independently established from flattened PNGs without Figma layers and device rendering. See `docs/QA_CHECKLIST.md`.

## Get started

Install a current stable Flutter SDK (Dart >=3.6), Android SDK/Xcode as applicable, Firebase CLI and FlutterFire CLI, then run **inside this extracted folder**:

```bash
flutter create --platforms=android,ios --project-name movies_app .
flutter pub get
flutterfire configure
flutter analyze
flutter test
flutter run --dart-define=MOVIES_API_BASE_URL=https://yts.pw/api/v2/
```

`flutter create .` generates the native host projects missing from this source-only delivery. Keep the existing `lib/`, `assets/`, `test/`, and `pubspec.yaml` files. The provided `scripts/bootstrap.sh` automates those steps on Unix-like systems. FlutterFire options setup may be configured by replacing the initialization in `lib/main.dart` after you generate `lib/firebase_options.dart`:

```dart
import 'firebase_options.dart';
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

The distributed `main.dart` uses `await Firebase.initializeApp()` for Android/iOS native configuration so the project does **not** import a nonexistent `firebase_options.dart` before the user supplies one. Make sure `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist` are provided as appropriate. Configure Android SHA-1/SHA-256 signing fingerprints, iOS URL scheme, and OAuth consent settings for Google sign-in.

**Firebase Console:** Enable Email/Password and Google sign-in in Authentication, create a Firestore database, and deploy **`firebase/firestore.rules`** after reviewing them for your Firebase project. Collections are `users/{uid}` for profile data and `users/{uid}/watchlist/{movieId}` and `users/{uid}/history/{movieId}` for authenticated user data. Firestore Security Rules must be applied before using those writes. Account deletion requires fresh Firebase reauthentication and deletes app-owned Firestore user documents/subcollections.

## Architecture

```text
lib/
  core/
    config/ constants/ di/ error/ localization/ network/
    router/ storage/ theme/ widgets/
  features/
    auth/          data/ domain/ presentation/
    movies/        data/ domain/ presentation/
    library/       data/ domain/ presentation/
    user_data/     data/ domain/ presentation/
    onboarding/ navigation/ profile/ settings/ splash/
assets/
  icons/          22 standalone app-owned vector assets
  images/         cropped supplied UI artwork / avatars
firebase/
  firestore.rules
  firebase.json
design_reference/
  screens/        original 20 PNG references (never embedded as fake screens)
docs/
  SCREEN_COVERAGE.md
  API_CONTRACT.md
  QA_CHECKLIST.md
test/
  core/ movies/
```

**State ownership:** `AuthCubit`, `HomeCubit`, `MovieListCubit`, `SearchCubit`, `MovieDetailsCubit`, `LibraryCubit`, `ProfileCubit`, `LanguageCubit`, `OnboardingCubit`, `StartupCubit`.

**Error/data behavior:** repository contracts return `Either<Failure, T>`; Dio performs network requests and maps errors; Hive caches the *actual received JSON* for successful GETs. Valid fresh cache is read first and stale cached responses are used only if the network fails. Search includes debounce and pagination. Firestore profile, watchlist and history use real-time streams; SharedPreferences holds onboarding and language choice. There is no dummy movie list.

## YTS API and host constraints

The supplied address was `https://yts.pw/api`. This source uses the documented YTS v2 suffix with default base URL `https://yts.pw/api/v2/`. The particular mirror was **not independently reachable from this environment**; override the host with a functioning YTS-compatible v2 mirror via:

```bash
flutter run --dart-define=MOVIES_API_BASE_URL=https://your-approved-host/api/v2/
```

Only the documented YTS **GET** endpoints are implemented: `list_movies.json`, `movie_details.json`, and `movie_suggestions.json`. `list_movies.json` handles search and genre filters through documented query parameters. The original user message did not paste a complete JSON schema; therefore the model parser uses known common YTS v2 keys with safe treatment of absent optional fields. See `docs/API_CONTRACT.md`.

**Movie playback:** YTS movie-list/detail APIs do not provide an authorized in-app video stream in this contract. The design's **Watch** action opens the movie's official YouTube trailer when `yt_trailer_code` is provided. It does not play or download films. “History” records movies whose trailers were successfully opened. The marketing copy in the onboarding art is retained from the exports and is not a claim that movie playback or a ratings/reviews service has been implemented.

## Navigation and screen coverage

All 20 source export states are mapped in `docs/SCREEN_COVERAGE.md`. The navigation shell comprises Home, Search, Browse and Profile; Movie Details is a `CustomScrollView`, not a 2961px screenshot. Authentication pages have validation, success/error states and Firebase-backed operations. Avatar selection has real selectable avatar assets; profile updates are persisted in Firestore.

Design tokens are approximate raster samples because the source Figma design layers could not be accessed. The vector icon SVGs are reconstructed from the flattened images rather than original exported Figma vectors. This distinction is documented in `design_reference/NOTES.md`.

## Quality gates you should run after configuration

```bash
dart format lib test
flutter analyze
flutter test
flutter run  # Inspect visuals on a 430 x 932 reference emulator first
```

See `docs/QA_CHECKLIST.md` for concrete manual UI, Firestore, offline/cache and API host checks. **Do not ship to an app store until those checks, cross-device sizing tests, and production Firebase configuration have passed.**
