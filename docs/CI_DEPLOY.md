# CI Deployment with GitHub Actions

This document explains how the `CI & Deploy` GitHub Actions workflow works and how to configure your repository to allow automated Firebase deployments.

## What the workflow does
- Runs Flutter unit and widget tests in `padeleiro_app`.
- Builds Cloud Functions (if a `build` script exists in `functions/package.json`).
- Authenticates to Firebase using a service account JSON stored in GitHub Secrets.
- Deploys Firestore rules, Cloud Functions, and Hosting for the selected Firebase project.

## Required GitHub secrets
Add the following repository secrets (Repository Settings → Secrets → Actions):

- `FIREBASE_SERVICE_ACCOUNT` — the full JSON contents of a Firebase service account key (create in Google Cloud IAM & Admin).
- `FIREBASE_PROJECT_ID` — the Firebase project id to deploy to (e.g. `my-padeleiro-prod`).

How to create a service account key
1. In Google Cloud Console, go to IAM & Admin → Service Accounts.
2. Create a service account and grant it the `Firebase Admin` and `Cloud Functions Developer` roles (or fine-grained roles as needed).
3. Create a JSON key and copy its contents into the `FIREBASE_SERVICE_ACCOUNT` secret.

## Security notes
- Treat `FIREBASE_SERVICE_ACCOUNT` as highly sensitive. Use least-privilege roles where possible.
- Prefer using separate Firebase projects for staging and production and restrict the secret to the appropriate repo/branch.

## Triggering deployments
- Pushes to the `main` branch trigger the workflow and will deploy on success.
- You can also create a release (publish) or push a tag like `v1.2.3` to trigger deploys.
- Manual runs (via `workflow_dispatch`) are supported from the Actions UI.

## Local verification
Before committing secrets, test deployments locally using the Firebase CLI:

```bash
# authenticate locally
firebase login
# use the desired project
firebase use --add
# deploy rules/functions/hosting
firebase deploy --only firestore:rules,functions,hosting --project <PROJECT_ID>
```

## Admin helper
A small helper script `scripts/setAdminClaim.js` lets you set the `role: 'admin'` custom claim for a user using a service account key.

Usage:
```bash
node scripts/setAdminClaim.js <USER_UID> /path/to/serviceAccount.json
# or if GOOGLE_APPLICATION_CREDENTIALS is set
node scripts/setAdminClaim.js <USER_UID>
```
