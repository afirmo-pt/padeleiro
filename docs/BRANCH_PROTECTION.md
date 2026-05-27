# Enforce Branch Protection: require tests before merge

This repository includes a GitHub Actions workflow to apply branch protection rules to the `main` branch and require that tests pass before merging pull requests.

## What it does
- Sets branch protection on `main` with:
  - required status checks (strict)
  - a required status check context `CI & Deploy / Run tests`
  - required approving review count = 1
  - admin enforcement enabled

> Note: The required status check context must match the name displayed in the PR checks. If your workflow displays a different context string, update the workflow input accordingly.

## How to run
1. Create a Personal Access Token (PAT) with `repo` scope.
2. Add it to the repository secrets as `GH_ADMIN_PAT`.
3. From the repository Actions tab, run the `Set Branch Protection` workflow (manual `workflow_dispatch`).

## Caveats
- The workflow needs a PAT with admin rights for the repository to update branch protection. The `GITHUB_TOKEN` provided by Actions does **not** have sufficient privileges for this operation.
- If you prefer, you can manually set branch protection in the GitHub UI: Settings → Branches → Add rule → `main`.

## Troubleshooting
- If the workflow fails with an authentication error, confirm the PAT has `repo` scope and that `GITHUB_ADMIN_PAT` is set correctly.
- If the status check context doesn't appear in PR checks, adjust the `contexts` array in `.github/workflows/set_branch_protection.yml` to match the check name shown in the PR UI.
