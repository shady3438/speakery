# Google Play Data Safety Draft

Use this as a starting point for Google Play Console. Verify final answers against the production build and legal/privacy review.

## Data Types

- Email address: collected for account creation and authentication.
- User IDs: collected through Firebase Auth.
- Name / username / profile text: collected for profile and social features.
- Photos: optional profile image upload.
- Audio: optional speaking/listening practice recording.
- App activity: lesson progress, XP, streaks, feature usage, AI request logs.
- User-generated content: social/profile text and practice submissions.

## Purposes

- App functionality.
- Account management.
- Personalization.
- Analytics/product improvement.
- Safety, abuse prevention, and moderation.

## Sharing

- Firebase services process authentication, Firestore, and storage data.
- AI provider receives only the compact text/context needed for feedback through backend endpoints.

## Security Practices

- Data is sent over HTTPS.
- Admin operations require Firebase admin custom claims.
- AI provider keys are not stored in the mobile app.
- Firestore rules restrict admin-only collections.

## Deletion

Provide an account/data deletion request path through support email or an in-app flow before store submission.
