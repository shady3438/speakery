# Speakery Admin Panel Plan

## Goal

Build a private web admin panel for operating Speakery without touching the mobile app manually.

## First Version

- Secure admin login.
- User list and user detail view.
- Feedback review queue for AI writing, speaking, listening, grammar, and chat.
- Content controls for lesson visibility, featured lessons, and reported content.
- Basic metrics: daily active users, completed lessons, XP, streaks, AI request count.
- AI endpoint usage dashboard to watch token cost by feature.

## Recommended Architecture

- Separate web app under `admin/`.
- Firebase Auth for login.
- Firestore security rules with an `admin` custom claim.
- Cloud Functions or backend API for privileged mutations.
- The mobile app should never contain admin-only permissions.

## Data Collections To Standardize

- `users`
- `user_progress`
- `ai_feedback_logs`
- `content_reports`
- `lessons`
- `feature_flags`
- `admin_audit_logs`

## Release Gate

- No admin route should be exposed inside the public mobile build.
- Every admin write must create an audit log entry.
- Admin API must reject non-admin users server-side.
