# Padeleiro UI/UX and Design Decisions

## Design principles

- Keep the experience simple and focused on key actions: authentication, match creation, match tracking, and admin approval.
- Use clear status-driven navigation so users always know whether they are pending, active, or suspended.
- Prioritize direct actions: the dashboard should clearly lead to creating a match and reviewing match history.
- Use existing Material 3 components and a consistent color palette for a modern, accessible mobile interface.

## Navigation flow

### Authentication flow
- `/login`: login screen with email/password.
- `/register`: registration screen with required user details.
- `/pending`: shown when the user account exists but is waiting for admin approval.
- `/suspended`: shown when the account is suspended.

### Main user flow
- `/dashboard`: primary landing page after successful login and active status.
- `/match/create`: create a new match.
- `/match/:matchId`: view match details and finalize results.

### Admin flow
- `/admin`: admin panel.
- `/admin/users`: pending user approval.
- `/admin/locations`: location management.

## Screen design decisions

### Dashboard
- Show user stats immediately with large summary cards.
- Provide a clear FAB for creating a new match.
- Include match history as a scrollable list with status badges and an easy tap target for details.

### Create Match
- Select a location from active locations.
- Pick date and time using native pickers.
- Choose 4 active players and assign two teams of two.
- Use inline validation to prevent invalid team composition or incomplete data.
- After success, return to the dashboard with a success confirmation.

### Match Detail
- Display match metadata, teams, and scheduled time.
- If the match is still scheduled and the user is the creator, show a score entry form.
- Allow entry of scores for 3 sets, reflecting padel’s best-of-3 structure.
- On finalize, invoke backend finalization and update user statistics via Cloud Function.
- If the match is completed, display results and winner information.

### Admin panel
- Pending users are displayed with swipe actions for approval/rejection.
- Active users are also displayed with a suspend action.
- Locations are listed, with a clear future action for creating new locations.
- Admin actions are exposed separately from player actions to avoid confusion.

## Data handling and state

- Use Riverpod providers to separate UI from data operations.
- Keep repositories responsible for Firestore read/write logic.
- Use `FutureProvider.family` for loading individual match details.
- Use `StateNotifierProvider` for form state and validation in match creation.
- Use `StreamProvider` for active user and location lists to keep selections live.

## Backend integration

- Firebase Auth manages login and registration.
- Firestore stores users, locations, matches, and user stats.
- Cloud Function `manageUserStatus` administers status changes safely.
- Cloud Function `onMatchFinalized` updates `user_stats` when a match transitions to completed.

## Current implementation status

- Authentication flow: implemented.
- User status flow: implemented.
- Match creation: implemented.
- Match detail and finalize flow: implemented.
- Dashboard match history: implemented in UI but may still require additional list refinement.
- Admin workflows: location creation implemented, active user suspension implemented, pending-user approval complete.
- User profile/settings screen: implemented.

## Future improvements

- Add richer match filtering and sorting in history.
- Add better responsive layout for larger screens.
- Add in-app guidance for pending users and admin reviewers.
- Add stronger field validation at the Firestore rules level.
