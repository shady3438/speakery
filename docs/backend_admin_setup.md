# Backend And Admin Setup

## Install Firebase Tools

```bash
npm install -g firebase-tools
firebase login
firebase use speakery-gokay
```

## Functions Dependencies

```bash
cd functions
npm install
npm run lint
```

`npm audit --omit=dev` currently reports moderate `uuid` advisories through the Firebase Admin dependency chain. The automatic force fix upgrades `firebase-admin` to a major version that is outside the supported peer range of `firebase-functions`. Keep `firebase-admin` and `firebase-functions` on compatible versions unless Firebase releases a peer-compatible fix.

## Secrets

```bash
firebase functions:secrets:set OPENAI_API_KEY
```

`OPENAI_MODEL` defaults to `gpt-4.1-mini`.

## Deploy

```bash
firebase deploy --only firestore,functions,hosting
```

If PowerShell blocks `firebase.ps1`, use `firebase.cmd` or run commands from Command Prompt.

## Grant Admin Access

The user must already exist in Firebase Auth.

```bash
cd functions
npm run set-admin -- you@example.com true
```

Revoke:

```bash
npm run set-admin -- you@example.com false
```

After granting the claim, sign out and sign in again in the admin panel so the ID token refreshes.

## Seed Admin Data

```bash
cd functions
npm run seed-admin
```

This creates default `feature_flags`, selected `lessons`, and an `admin_audit_logs` entry.

## Mobile AI Dart Defines

When deployed through Firebase Hosting rewrites, the mobile app can point at one hosted domain:

```bash
flutter run \
  --dart-define=AI_FEEDBACK_ENDPOINT=https://PROJECT.web.app/ai/general \
  --dart-define=AI_WRITING_FEEDBACK_ENDPOINT=https://PROJECT.web.app/ai/writing \
  --dart-define=AI_SPEAKING_FEEDBACK_ENDPOINT=https://PROJECT.web.app/ai/speaking \
  --dart-define=AI_LISTENING_FEEDBACK_ENDPOINT=https://PROJECT.web.app/ai/listening \
  --dart-define=AI_CHAT_FEEDBACK_ENDPOINT=https://PROJECT.web.app/ai/chat
```

Use the same defines for release builds.

Flutter release builds can also use:

```bash
flutter build appbundle --release --dart-define-from-file=config/release_defines.json
```

Create `config/release_defines.json` from `config/release_defines.example.json`.
