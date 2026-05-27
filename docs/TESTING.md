# Testing the Padeleiro App

This guide explains how to run the automated tests locally and in CI.

## Running tests locally

From the repository root:

```bash
cd padeleiro_app
flutter pub get
flutter test
```

This runs the unit and widget tests located in `padeleiro_app/test/`.

## CI

A GitHub Actions workflow is provided at `.github/workflows/flutter_test.yml` which runs `flutter test` on every push and pull request against `main`/`master`.

## Adding tests

- Unit tests for model classes and repositories live under `padeleiro_app/test/`.
- Widget tests should wrap widgets with `ProviderScope` when they use Riverpod providers.
- For repository-level tests that need Firebase, prefer using the Firebase emulators and the `firebase_auth_mocks` package or a local `Cloud Firestore` emulator setup.

## Troubleshooting

- If tests fail due to missing Flutter SDK, install Flutter and ensure `flutter` is on your `PATH`.
- For Firebase-related tests, start the emulators with:

```bash
firebase emulators:start --only firestore,auth
```

and point the app to the emulator host via environment configuration.
