# Export-to-implementation traceability

The supplied 20 PNGs are **states/screens**, not 20 necessarily distinct navigation paths. Figma layer metadata was unavailable; spacing/icons are visually recreated from the supplied exports.

| # | Supplied PNG | Implemented location / state | Data source |
|---:|---|---|---|
| 1 | Splash Screen.png | `SplashScreen` → startup navigation | SharedPreferences + Firebase current user |
| 2 | Login.png | `LoginScreen` email/password + Google | Firebase Auth |
| 3 | Register.png | `RegisterScreen` + avatar picker | Firebase Auth + Firestore profile |
| 4 | Update Profile.png | `EditProfileScreen` edit form | Firestore + Firebase Auth display name |
| 5 | Update Profile-1.png | `EditProfileScreen` avatar/alternate state | Firestore |
| 6 | Forget Password.png | `ForgotPasswordScreen` | Firebase Auth password reset |
| 7 | Home.png | `HomeTab` featured + genre rows | YTS list movies |
| 8 | Movie Details.png | `MovieDetailsScreen` hero and top information | YTS details + user watchlist |
| 9 | Search.png | `SearchTab` empty state | Local search state |
| 10 | Search-1.png | `SearchTab` with results | YTS list_movies query_term |
| 11 | Browse.png | `BrowseTab` horizontal genre selector + grid | YTS list_movies genre |
| 12 | Profile.png | `ProfileTab` watchlist selected | Firestore watchlist |
| 13 | Profile-1.png | `ProfileTab` history selected | Firestore history |
| 14 | Movie Detials.png (430 × 2961) | `MovieDetailsScreen` `CustomScrollView` screenshots, similar, summary, cast, genres | YTS details + suggestions |
| 15 | OnBoarding.png | `OnboardingScreen` step 0 | Bundled artwork |
| 16 | OnBoarding-1.png | `OnboardingScreen` step 1 | Bundled artwork |
| 17 | OnBoarding-2.png | `OnboardingScreen` step 2 | Bundled artwork |
| 18 | OnBoarding-3.png | `OnboardingScreen` step 3 | Bundled artwork |
| 19 | OnBoarding-4.png | `OnboardingScreen` step 4 | Bundled artwork |
| 20 | OnBoarding-5.png | `OnboardingScreen` step 5 | Bundled artwork |

`AppRouter` routes: `/`, `/onboarding`, `/login`, `/register`, `/forgot-password`, `/app`, `/movie`, `/edit-profile`. Home/Search/Browse/Profile tabs are reachable from `/app`, and onboarding has 6 Cubit-controlled states. Update Profile’s avatar alternatives, search’s empty/results, and profile’s watchlist/history all remain actual UI states rather than duplicated hardcoded screens.
