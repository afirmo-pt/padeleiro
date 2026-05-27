# Padeleiro MVP

Padeleiro is a Firebase-backed Flutter app for managing padel matches in closed communities.

## Project overview

This repository contains:
- `padeleiro_app/`: Flutter client application
- `functions/`: Firebase Cloud Functions backend
- `firestore.rules`: Firestore security rules
- `docs/FIREBASE_SECURITY.md`: Firestore security model and deployment guidance
- `firebase.json`: Firebase hosting and functions configuration
- `ROADMAP.md`: implementation roadmap and next steps

## Core product concept

The MVP is designed for local padel communities with:
- user registration and manual admin approval
- user status management (`pending`, `active`, `suspended`, `rejected`)
- user profile settings with editable name, phone, and community
- match creation and scheduling
- match result finalization and player statistics
- admin moderation for pending and active users, including approval/rejection and suspension
- location management

## Implemented features

### Authentication & user onboarding
- Email/password sign-in
- Registration with full name, email, phone, and community
- New user account saves Firestore document `users/{uid}` with `status: pending`
- Redirect guard enforces auth and user status flows
- Pending and suspended screens for account state

### User status and access control
- Firestore `users/{uid}` status is used to gate access
- Admin-only routes require a custom claim `role: admin`
- Firestore security rules enforce read/write access across collections

### Match domain
- Match creation model includes:
  - scheduled date/time
  - active location
  - two teams of two players
  - creator UID and player IDs
- Backend trigger on `matches/{matchId}` finalization updates `user_stats/{uid}`
- Dashboard displays user statistics and match history list

### Admin features
- Pending user approval and rejection via admin screen
- Admin location list and archive support
- Admin callable Cloud Function `manageUserStatus`

## Architecture and design details

### Client architecture
- Flutter app uses `flutter_riverpod` for state management
- `go_router` handles navigation and route guards
- `freezed` provides immutable data classes and convenient model factories
- `cloud_firestore`, `firebase_auth`, `cloud_functions` for backend integration
- Offline persistence enabled for Firestore
- Material 3 theming with a custom color palette

### Data models
- `AppUser`: user profile information and status
- `Location`: location metadata and active state
- `Match`: scheduled match data, teams, scores, winner
- `UserStats`: aggregate stats per user

### Backend behavior
- `functions/src/manageUserStatus.ts`: validates admin role and updates user status
- `functions/src/onMatchFinalized.ts`: detects a scheduled->completed transition, computes winner, and increments stats for all match participants

## Current status

The codebase is functional across core user and admin workflows, with the remaining work focusing on security validation, documentation, and test coverage:
- `CreateMatchScreen` implemented
- `MatchDetailScreen` implemented with finalization support
- admin location creation and user moderation complete
- user profile/settings screen implemented
- Firestore security rules have been tightened
- documentation is updated and additional test coverage is being added

## Running the app

1. Install Flutter SDK and required dependencies
2. Configure Firebase for the project
3. Run `flutter pub get`
4. Use `flutter run` from `padeleiro_app/`

## Next steps

See `ROADMAP.md` for the prioritized feature plan and the remaining work for a final app.
