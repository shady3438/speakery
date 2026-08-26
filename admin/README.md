# Speakery Admin Console

Static first version of the private Speakery admin console.

## Local Preview

Open `admin/index.html` in a browser.

## Firebase Setup

1. Copy `firebase-config.example.js` to `firebase-config.js`.
2. Fill it with the Firebase web app config.
3. Deploy hosting with:

```bash
firebase deploy --only hosting
```

## Production Requirements

- Protect all real data with Firestore rules and admin custom claims.
- Do not expose admin routes inside the mobile app.
- Every privileged write should create an `admin_audit_logs` document.
