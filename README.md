# Speakery

Speakery is a Flutter English learning app with grammar, reading, vocabulary,
listening, speaking, writing, social profile, AI feedback, notifications, and a
Firebase-backed admin console.

## Project Type

- Mobile app: Flutter / Dart
- Backend: Firebase Cloud Functions / Node.js
- Database: Cloud Firestore
- Hosting: Firebase Hosting for the admin console and AI proxy routes
- Platforms: Android, iOS, Web source scaffold
- Docker: Not used

## Main Technologies

- Flutter 3 / Dart
- Firebase Core, Auth, Firestore, Storage
- Firebase Functions v2 and Firebase Admin SDK
- HTTP-based AI feedback proxy endpoints
- Local Flutter tests with `flutter_test`

## Project Structure

- `lib/`: Flutter app source code
- `lib/presentation/`: screens and UI widgets
- `lib/data/`: lesson, grammar, reading, vocabulary, and local store data
- `lib/services/`: AI, speech, and notification services
- `assets/`: app images and SVG assets
- `android/`, `ios/`, `web/`: platform projects
- `admin/`: Firebase Hosting admin console
- `functions/`: Firebase Cloud Functions backend
- `firestore.rules`, `firestore.indexes.json`: Firestore security and indexes
- `docs/`: release, admin, privacy, terms, and data safety notes
- `config/release_defines.example.json`: safe release define template

## Required Local Setup

Install:

- Flutter SDK
- Android Studio or Android SDK command-line tools
- Xcode on macOS for iOS release builds
- Node.js 20+ for Firebase Functions
- Firebase CLI

Then install dependencies:

```bash
flutter pub get
cd functions
npm install
cd ..
```

## Firebase Setup

Real Firebase client config files are intentionally not committed. Create them
locally with your own Firebase project:

```bash
flutterfire configure
```

Or copy the examples and replace placeholders:

```bash
cp lib/firebase_options.example.dart lib/firebase_options.dart
cp android/app/google-services.example.json android/app/google-services.json
cp admin/firebase-config.example.js admin/firebase-config.js
```

For iOS, add your own `ios/Runner/GoogleService-Info.plist` from Firebase.

## Environment Variables

The app must call backend AI proxy endpoints. Do not place provider API keys in
the mobile app.

Safe local template:

```bash
cp env.example.json env.json
```

Run with defines:

```bash
flutter run --dart-define-from-file=env.json
```

Or pass values manually:

```bash
flutter run \
  --dart-define=AI_FEEDBACK_ENDPOINT=https://PROJECT.web.app/ai/general \
  --dart-define=AI_WRITING_FEEDBACK_ENDPOINT=https://PROJECT.web.app/ai/writing \
  --dart-define=AI_SPEAKING_FEEDBACK_ENDPOINT=https://PROJECT.web.app/ai/speaking \
  --dart-define=AI_LISTENING_FEEDBACK_ENDPOINT=https://PROJECT.web.app/ai/listening \
  --dart-define=AI_CHAT_FEEDBACK_ENDPOINT=https://PROJECT.web.app/ai/chat
```

Set the OpenAI key only as a Firebase Functions secret:

```bash
firebase functions:secrets:set OPENAI_API_KEY
```

## Running The App

```bash
flutter pub get
flutter run --dart-define-from-file=env.json
```

If you do not configure AI endpoints, the app still opens, but AI feedback
features will report that AI is not configured.

## Admin Console

The admin console lives in `admin/`. It can be opened locally as static files
after creating `admin/firebase-config.js`.

Production hosting and AI rewrites are configured in `firebase.json`:

```bash
firebase deploy --only firestore,functions,hosting
```

Admin setup details are in `docs/backend_admin_setup.md`.

## Verification

```bash
dart analyze lib
flutter test
```

For Android:

```bash
flutter build apk --debug
flutter build appbundle --release --dart-define-from-file=config/release_defines.json
```

For iOS, use macOS with Xcode signing:

```bash
flutter build ipa --release --dart-define-from-file=config/release_defines.json
```

## Release Notes

- Android release signing is wired through `android/key.properties`.
- `android/key.properties` is ignored; use `android/key.properties.example`.
- iOS release requires a real bundle id, Apple Developer account, provisioning
  profile, and Firebase iOS app config.
- This Windows machine still needs Android SDK command-line tools and accepted
  Android licenses before reliable release app bundle generation.

See `docs/release_readiness.md` for the full mobile release checklist.

## Security Notes

Ignored local files include `.env*`, `env.json`, Firebase client configs, Android
signing files, build outputs, dependency folders, caches, logs, and large
archives. Never commit provider secrets, service account JSON files, private
keys, or mobile signing credentials.
