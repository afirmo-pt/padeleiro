# Firebase Security Rules for Padeleiro

This document describes the Firestore security model used by the app and the key validation rules applied in `firestore.rules`.

## Purpose

The security rules protect user data, match state, and admin-only operations in a Firebase-backed padel app.

## Key protections

- `users/{uid}`
  - Read access is limited to the authenticated user or an admin.
  - Account creation is only allowed when the authenticated UID matches the document ID.
  - Users may only update their own profile fields (`fullName`, `phone`, `community`).
  - Sensitive fields such as `email`, `status`, and `createdAt` cannot be modified by the user.
  - Admins may read, update, or delete any user document.

- `matches/{matchId}`
  - Read access is restricted to match participants and admins.
  - Match creation is only allowed for active users and requires a valid scheduled match payload.
  - Only the match creator can finalize a match, and only if the match is currently scheduled.
  - Score updates and completion are validated to prevent unauthorized changes to match metadata.

- `locations/{locationId}`
  - Only admins can create or update locations.
  - Active users and admins can read locations.

- `user_stats/{uid}`
  - Statistics are read-only and available to active users and admins.

## Admin role

Admin route protection is enforced both in the app router and via Firestore rules.

- The app uses a custom claim `role: admin` in the Firebase ID token to gate access to `/admin` routes.
- The Firestore rules additionally require `request.auth.token.role == 'admin'` for admin-only writes.

## Deployment

Use the Firebase CLI to deploy the security rules together with functions:

```bash
firebase deploy --only firestore:rules,functions
```

To test locally with emulators:

```bash
firebase emulators:start --only firestore,functions
```

## Notes

- The current app stores profile data in `users/{uid}` and does not use the `user_profiles` collection.
- Rule validation is intentionally conservative for user updates and match finalization.
- If a future profile collection is added, the rules should be updated to reflect that separation explicitly.
