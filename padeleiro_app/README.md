# Padeleiro Flutter App

`padeleiro_app` is the Flutter client for the Padeleiro MVP.

## Purpose

This app is built to help closed padel communities manage matches, track player statistics, and allow admin-controlled account approval.

## Key features

- Email/password authentication using Firebase Auth
- User registration with pending approval by admin
- Status-aware navigation for `pending`, `active`, and `suspended` accounts
- Dashboard with user statistics and match history
- Match creation workflow with team selection, location, and schedule
- Admin panel for reviewing pending users and managing locations
- Firestore offline persistence enabled

## Architecture

### State management
- `flutter_riverpod` is used for dependency injection and reactive state
- Providers isolate repository logic from UI

### Navigation
- `go_router` centralizes routes and redirect logic
- Auth and status guards are evaluated in `lib/core/router/app_router.dart`

### Firebase integration
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `cloud_functions`
- Firebase initialization and Firestore persistence configured in `lib/core/firebase/firebase_init.dart`

### Theming
- Material 3 theming defined in `lib/core/theme/app_theme.dart`
- Custom palette and typography via `google_fonts`

## Notable modules

- `lib/features/auth/`: authentication and registration flow
- `lib/features/dashboard/`: user dashboard, stats, and match history
- `lib/features/match/`: match creation, match data, and location repositories
- `lib/features/admin/`: admin user approval and location management
- `lib/models/`: shared domain models for users, matches, locations, and stats

## Current development status

Implemented:
- authentication flow
- pending user lifecycle
- match creation
- dashboard stats
- admin pending-user approval

Work remaining:
- detailed match review and finalize screen
- admin "create location" workflow
- user profile/settings screen
- additional tests and documentation

## How to run

1. `cd padeleiro_app`
2. `flutter pub get`
3. Configure Firebase in the app
4. `flutter run`

## Further documentation

For repository-level architecture and backlog, see `../README.md` and `../ROADMAP.md`.
