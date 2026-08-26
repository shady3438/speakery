# Speakery Release Readiness

## Current Verified State

- `dart analyze lib`: clean.
- `flutter test`: all tests passed.
- `flutter build apk --debug`: builds successfully.
- `flutter build appbundle --release`: blocked on this machine by Android SDK command-line tools / native symbol strip tooling.

## Android Before Play Store

- Replace `applicationId = "com.example.speakery"` with the final Play package id.
- Create matching Firebase Android app for the final package id and replace `android/app/google-services.json`.
- Install Android SDK Command-line Tools and accept Android licenses:
  - Android Studio > SDK Manager > SDK Tools > Android SDK Command-line Tools
  - `flutter doctor --android-licenses`
- Generate a Play upload keystore and create `android/key.properties` from `android/key.properties.example`.
- Run:
  - `flutter clean`
  - `flutter pub get`
  - `flutter build appbundle --release`

## iOS Before App Store

- Set final bundle id in Xcode project instead of `com.example.flutterTemplate`.
- Add Apple Developer Team signing in Xcode.
- Create matching Firebase iOS app for the final bundle id.
- Add `ios/Runner/GoogleService-Info.plist` if native Firebase config is required.
- Verify iOS privacy strings in `ios/Runner/Info.plist`.
- Build/archive on macOS with Xcode:
  - `flutter build ipa --release`
  - Xcode Organizer upload or Transporter.

## Backend / AI

- Do not ship OpenAI or other model keys in the app.
- Set production AI endpoints with `--dart-define`.
- Keep AI calls behind backend endpoints for token control and abuse protection.

## Store Assets

- Final app icon.
- Splash/launch visuals.
- App screenshots for phone sizes.
- Privacy policy URL.
- Terms of use URL.
- Support email.
- Data safety / nutrition label answers.

## Draft Store Documents

- Privacy policy draft: `docs/privacy_policy_draft.md`
- Terms of use draft: `docs/terms_of_use_draft.md`
- Google Play data safety draft: `docs/data_safety_play_console.md`

Publish the final privacy policy and terms on a public HTTPS URL before submitting to Google Play or App Store review.
