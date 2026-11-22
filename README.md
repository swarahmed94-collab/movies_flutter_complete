# Movies

A Flutter movie discovery application featuring movie browsing, search, details, saved favourites and user accounts.

## Features

- Explore movies, search by title and browse by genre.
- View movie information, ratings, posters and recommendations.
- Register and sign in using Firebase Authentication.
- Save favourites and user data in Cloud Firestore.
- Cache movie data locally and retain lightweight preferences.
- Open movie trailers when a trailer is available. Playback depends on the configured YouTube integration and the video's embedding permissions.

## Technology

- **Flutter / Dart** for the mobile interface.
- **Clean Architecture** to separate domain, data and presentation code.
- **Cubit / flutter_bloc** for application state.
- **Dio** for REST requests to the YTS movie API.
- **Firebase Authentication & Cloud Firestore** for accounts and favourites.
- **Hive & SharedPreferences** for local storage.

## Project structure

```text
lib/                Application source (core, features)
assets/             App images and icons
android/            Android project
ios/                iOS project
firebase/           Firestore rules and Firebase-related files
test/               Automated tests
design_reference/    Exported reference screens
```

## Run locally

1. Install Flutter and the required Android/iOS development tools.
2. Run `flutter pub get` from the repository directory.
3. Configure your own Firebase project with `flutterfire configure`, and enable the authentication providers and Firestore rules needed by the app.
4. For iOS, open `ios/Runner.xcworkspace` in Xcode to set signing for your own device. Run `cd ios && pod install` if required.
5. Start the app using `flutter run`.

The movie API host must be available from the target device. Some YouTube trailers do not permit playback in embedded players.

## Design

UI implemented using the supplied Figma reference screens. The source exports are under `design_reference/` when included.
