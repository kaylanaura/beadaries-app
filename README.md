# Beadaries

Beadaries is a Flutter prototype for browsing handmade bead accessories, requesting reservations, and managing inventory.

## What works

- Firebase email/password sign-in, customer registration, and role-checked admin entry.
- Catalogue search and category filters backed by the shared inventory provider.
- Product details linked to the in-memory reservation demo.
- Admin inventory management backed by Cloud Firestore by default.
- Demo reservations, approval/status tracking, and AI-style recommendations stored in memory.

The AI stylist is currently a deterministic mock, not a live generative-AI service. Demo reservations are not persisted and reset when the app restarts.

## Requirements

- Flutter 3.50.0 / Dart 3.14 or compatible versions satisfying `pubspec.yaml`.
- A Firebase project with Email/Password Authentication, Cloud Firestore, and Cloud Storage enabled.
- Firebase CLI for deploying rules and hosting.

`lib/firebase_options.dart` currently contains web configuration only. Configure each additional target with FlutterFire before building it:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure --platforms=web
```

For Android, install the Android SDK and run `flutterfire configure --platforms=android,web`. Do not commit service-account credentials or other server secrets.

## Run locally

```powershell
flutter pub get
flutter run -d chrome
```

Inventory uses Firestore by default. For a UI-only inventory demo, use:

```powershell
flutter run -d chrome --dart-define=USE_MOCK_DATA=true
```

Firebase Authentication is still required in mock inventory mode.

## Firebase setup and web deployment

1. Enable Email/Password in Firebase Authentication and create a Firestore database and Storage bucket.
2. Configure web options with FlutterFire as described above.
3. Select the Firebase project with `firebase use --add`.
4. Create an admin account in Firebase Authentication. In the Firestore console, create `users/{uid}` with that account's `email`, `displayName`, and `role: "admin"`. Customer accounts receive a `customer` profile during registration. Clients cannot grant themselves admin access.
5. Deploy the access rules, then build and deploy the web app:

```powershell
firebase deploy --only firestore:rules,storage
flutter build web --release
firebase deploy --only hosting
```

The repository does not include a Firebase project alias; choose the correct project before deployment.

## Validation

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
```

GitHub Actions runs formatting, analysis, tests, and a web release build for pushes and pull requests.

## Architecture

The app shell exposes customer and admin flows. `AdminProductProvider` owns the shared inventory stream; it uses Firestore after authentication by default and supports an explicit mock override for UI demos and tests. The catalogue reads this provider and product details can open the demo reservation flow. Reservation and recommendation state remains in-memory.

Stakeholder acceptance, peer-contribution records, and AI-use logs must be collected from genuine project activity; repository documentation cannot substitute for them.
