# Padeleiro MVP Implementation Roadmap

## Overview
This roadmap turns the current assessment into a concrete sequence of deliverables for completing the Padeleiro app.

The project is structurally sound but still needs:
- a full match creation and result workflow
- complete admin location and user management
- profile/account screens
- production-ready documentation and tests
- Firestore rule validation and backend role setup

---

## Phase 1 — Player match experience

### 1. Implement match creation UI
- `padeleiro_app/lib/features/match/presentation/create_match_screen.dart`
- `padeleiro_app/lib/features/match/data/match_repository.dart`
- `padeleiro_app/lib/features/match/data/location_repository.dart`
- `padeleiro_app/lib/features/admin/data/admin_providers.dart`

Deliverable:
- players can select location, team members, schedule a match, and save it to Firestore

### 2. Implement match detail and finalize flow
- `padeleiro_app/lib/features/match/presentation/match_detail_screen.dart`
- `padeleiro_app/lib/features/match/data/match_repository.dart`
- `functions/src/onMatchFinalized.ts`

Deliverable:
- match detail screen shows match info and lets authorized user finalize a match with set scores

### 3. Wire match history into dashboard
- `padeleiro_app/lib/features/dashboard/presentation/dashboard_screen.dart`
- `padeleiro_app/lib/features/dashboard/presentation/match_history_list.dart`
- `padeleiro_app/lib/features/dashboard/data/dashboard_providers.dart`

Deliverable:
- dashboard displays paginated user match history with summary cards and load-more behavior

---

## Phase 2 — Admin workflows

### 4. Finish admin location management
- `padeleiro_app/lib/features/admin/presentation/admin_screen.dart`
- `padeleiro_app/lib/features/match/data/location_repository.dart`
- `padeleiro_app/lib/features/admin/data/admin_providers.dart`

Deliverable:
- admin can create and archive locations from the admin panel

### 5. Expand admin user actions
- `padeleiro_app/lib/features/admin/data/admin_repository.dart`
- `padeleiro_app/lib/features/admin/data/admin_providers.dart`
- `functions/src/manageUserStatus.ts`

Deliverable:
- admin UI includes suspend/reject/approve actions and reflects status changes immediately

---

## Phase 3 — Account and UX polish

### 6. Add user profile/settings screen
- `padeleiro_app/lib/features/profile/presentation/profile_screen.dart`
- `padeleiro_app/lib/features/auth/data/user_repository.dart`
- `padeleiro_app/lib/core/router/app_router.dart`

Deliverable:
- users can view and edit their profile fields directly in the app

### 7. Improve onboarding and empty states
- `padeleiro_app/lib/features/auth/presentation/pending_screen.dart`
- `padeleiro_app/lib/features/auth/presentation/suspended_screen.dart`
- `padeleiro_app/lib/features/dashboard/presentation/dashboard_screen.dart`
- `padeleiro_app/lib/features/admin/presentation/admin_screen.dart`

Deliverable:
- polished messaging, clear next steps, and better feedback for pending/suspended/admin flows

---

## Phase 4 — Backend, security, and deployment

### 8. Harden Firestore security rules
- `firestore.rules`
- optionally add validation helper functions in Cloud Functions or rules

Deliverable:
- rules validate match creation/update payloads, restrict admin-only actions, and protect user status data

### 9. Document Firebase setup and admin role provisioning
- `firebase.json` review
- new documentation in `README.md` or `docs/FIREBASE_SETUP.md`

Deliverable:
- clear instructions for deploying rules, functions, and setting admin custom claims

---

## Phase 5 — Tests and release preparation

### 10. Add automated tests
- unit tests for repositories and auth logic
- widget tests for login/register/dashboard/admin flows
- integration tests for key user journeys

Deliverable:
- regression coverage for auth, match workflows, and admin actions

### 11. Final documentation and project polish
- replace default Flutter README with app-specific content
- add architecture overview, feature list, and deployment steps

Deliverable:
- professional project documentation that supports team handoff and release

---

## Immediate next actions
1. Harden Firestore security rules and validate the deployed rule set.
2. Add automated tests for auth, profile, and match onboarding flows.
3. Finalize release documentation and Firebase deployment guidance.

These are the highest-value changes to move the app from MVP implementation into a production-ready release.
