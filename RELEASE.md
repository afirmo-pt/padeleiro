# Release Checklist and Deployment

This document outlines the steps to prepare a Padeleiro release and deploy Firebase services.

## Prepare release

- Bump the app version in `padeleiro_app/pubspec.yaml`.
- Run tests locally: `cd padeleiro_app && flutter test`.
- Update `CHANGELOG.md` (if present) describing user-facing changes.

## Build

- Android: `cd padeleiro_app && flutter build apk --release`
- iOS: `cd padeleiro_app && flutter build ipa --export-options-plist=...` (macOS required)

## Firebase

- Ensure Firestore rules are tested in the emulator:

```bash
firebase emulators:start --only firestore,functions
# In another terminal run your test suite against the emulator
```

- Deploy rules and functions:

```bash
firebase deploy --only firestore:rules,functions
```

- If you changed hosting configuration or added assets:

```bash
firebase deploy --only hosting
```

## Release store submission

- Follow platform-specific guidelines for Play Store / App Store. Ensure privacy policy, screenshots, and proper signing keys are set.

## Post-release

- Monitor analytics and error reporting
- Prepare hotfix process if critical issues are found
