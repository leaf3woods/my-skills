---
name: aws-lambda-dev-deploy
description: >-
  Guarded AWS Lambda dev-test workflow for one Lambda project selected from
  an explicit user request, staged paths, or from the latest commit when
  nothing is staged: resolve a dev target from CI/CD or updateFunction.sh,
  package existing repository files without modifying them, back up live
  $LATEST, upload only to $LATEST, persist deploy-state.json for cross-session
  resume, pause for user testing, and restore the original package after a
  passing test. Use when the user asks an AI CLI or agent to test Lambda changes
  in dev, deploy a named Lambda to dev for testing, resume an in-progress Lambda
  test, or run a safe Lambda update/restore flow that must not publish versions,
  update aliases/tags, use profiles, or deploy staging/production.
---

# AWS Lambda Dev Deploy

## Core Rules

- Work from the repository root and handle exactly one Lambda project selected in this order: explicit user-provided Lambda root/name/function, staged paths, then latest commit paths.
- When the user explicitly names the Lambda to deploy, do not block because staged paths, unstaged paths, untracked files, or the latest commit do not identify that Lambda. Use the explicit target as the selection source and treat git changes as package context and drift data.
- In inferred mode, stop on any unstaged tracked change or untracked file anywhere in the repository. In explicit mode, do not let unrelated changes outside the selected Lambda root block the run.
- Do not edit, stage, install, build, generate, format, clean, or otherwise modify repository files.
- Create only deployment/backup artifacts under `~\.test\<lambda-directory-name>`.
- Persist deployment state in `~\.test\<lambda-directory-name>\deploy-state.json`; use it to resume testing, retry, or restore across windows.
- Use the developer machine's default AWS identity. Do not require, parse, or pass `--profile`.
- Resolve the base dev Lambda function and region from CI/CD first, then `updateFunction.sh` as fallback, or an explicit one-off user override. Record the target source.
- Upload only to `$LATEST` with `aws lambda update-function-code` and no `--publish`.
- Never publish versions, update aliases/tags, run API Gateway stage deploys, or deploy staging/production.
- On the initial upload, back up the current live `$LATEST` package. On failed-test retries, reuse that original backup. After a passing test, restore that original backup to `$LATEST`.
- Never treat a local deployment ZIP as the live backup.

## Explicit Lambda Requests

Use explicit mode when the user clearly names a Lambda directory, project, function name, ARN, or otherwise says to deploy a specific Lambda.

- Set `selectionSource` to `explicit-lambda`.
- Resolve exactly one Lambda root from the explicit input, CI/CD mappings, repository paths, or `updateFunction.sh`. If the input is only a function name, still resolve the matching local Lambda root before packaging.
- Do not infer the Lambda root from staged paths or the latest commit in this mode.
- Do not stop because changed files are absent, unrelated to the Lambda, include multiple Lambda roots, are unstaged, or include untracked files.
- Package the current filesystem contents under the selected Lambda root, following the normal packaging exclusions. Show changed, deleted, and untracked paths under that root before upload.
- Treat changes outside the selected Lambda root as unrelated context. Report them compactly in the confirmation summary, but ignore them for packaging and upload drift checks.
- Stop only when the explicit input cannot be resolved to exactly one Lambda root, the dev target cannot be safely resolved, the package contents are unclear, or another safety rule would be violated.

## Stop Conditions

Stop immediately when any of these are true:

- No explicit Lambda was provided and selection paths do not identify exactly one Lambda root, or they identify more than one Lambda root. Use staged paths when any exist; otherwise use the latest commit's paths.
- No explicit Lambda was provided, no staged paths exist, and the latest commit cannot be read or has no changed paths.
- No explicit Lambda was provided and git status has an unstaged worktree status or `??` entry.
- An explicit Lambda was provided but cannot be resolved to exactly one local Lambda root.
- The target cannot be resolved to exactly one dev function name and AWS region.
- The target function name or ARN includes an alias/tag/version qualifier instead of the base function.
- The discovered workflow would touch anything other than `$LATEST`.
- AWS identity cannot be shown.
- Lambda configuration does not report `Version` = `$LATEST`, `PackageType` = `Zip`, `State` = `Active`, and `LastUpdateStatus` = `Successful`.
- Packaging would require repository mutation, missing generated files, dependency installation, or unclear exclusions.
- The initial live backup cannot be downloaded, opened/listed when tooling supports it, or verified as nonempty.
- A retry upload is requested but the original verified live backup is missing.
- A resume, retry, pass, fail, cancel, or restore request cannot be matched to exactly one valid `deploy-state.json`.
- The user has not explicitly confirmed the final pre-upload summary.

## Resume From State

When the user asks to continue a prior deployment, reports a test result, or asks to restore, load `deploy-state.json` from `~\.test\<lambda-directory-name>` before acting. If the Lambda directory is not clear, search `~\.test\*\deploy-state.json` and stop unless exactly one active state matches the request.

Do not infer the original live backup from the newest ZIP file. Trust only a state file whose recorded backup path exists, is nonempty, and is readable.

## 1. Analyze Git State

Run `git status --porcelain=v1`.

- First determine whether the user explicitly named the Lambda to deploy.
- If explicit, set `selectionSource` to `explicit-lambda`, resolve the Lambda root from the explicit input, and record the full git status, status entries under the selected Lambda root, and status entries outside it. Continue even when there are unstaged or untracked files.
- If not explicit, stop when column 2 is not a space, or on any `??` entry.
- Collect staged paths from entries whose index status in column 1 is not a space.
- If not explicit and staged paths exist, set `selectionSource` to `staged` and use those paths to infer the target Lambda root.
- If not explicit and no staged paths exist, set `selectionSource` to `latest-commit`; run `git rev-parse HEAD` and `git diff-tree --no-commit-id --name-only -r --root HEAD`, then use those latest-commit paths to infer the target Lambda root.
- Stop if not explicit and the latest commit cannot be read or returns no changed paths.
- Infer the Lambda root as the top-level project directory that contains Lambda source/package files, with or without `updateFunction.sh`.
- Stop if not explicit and the selection paths identify zero Lambda roots or more than one Lambda root.
- Ignore non-Lambda repository metadata in the selection paths only when exactly one Lambda root remains clear, or when explicit mode already selected the Lambda root.
- Record `selectionSource` and `selectionFiles`.
- For `staged`, also record staged files and `git write-tree`; use the tree hash later to detect staged-content drift.
- For `latest-commit`, also record the `HEAD` commit hash; use it later to detect commit drift.
- For `explicit-lambda`, also record `explicitLambdaInput`, selected-root git status entries, unrelated git status entries, and a compact fingerprint of the selected-root status; use it later to detect package-content drift before upload.

## 2. Resolve Target

Inspect CI/CD before relying on `updateFunction.sh`.

For GitHub Actions, check `.github/workflows/*.yml` and `.github/workflows/*.yaml` for Lambda upload commands, AWS credential setup, region variables, and mapping files such as `.github/workflows/lambdaMapper.json`.

Use CI/CD as the target source when it clearly maps the selected Lambda root to exactly one function and region. Record the workflow path, mapping path if any, function name, and region.

If the user provides a one-off test function name, use it only for the current run and still require a verified region from CI/CD, `updateFunction.sh`, AWS CLI config, or an explicit user-provided value. Show the override in the confirmation summary. This function override can be combined with explicit mode; it must not depend on changed files to choose the Lambda root.

If CI/CD does not clearly own deployment, inspect `updateFunction.sh` without executing it. Extract literal `--function-name` and `--region` values, including variables assigned clear literals in the same file. Ignore any `--profile` value.

Reject `--publish`, `publish-version`, alias/tag updates, API Gateway stage deploys, staging/production deploy commands, computed targets, multiple candidate regions/functions, or branch/stage logic that cannot be resolved for dev.

When CI/CD already provides the target, use `updateFunction.sh` only as packaging reference. Do not fail only because it lacks `--region` or contains `--profile`.

## 3. Verify AWS Target

Show the default AWS caller identity:

```powershell
aws sts get-caller-identity --output json
```

Fetch `$LATEST` configuration:

```powershell
aws lambda get-function-configuration --function-name <function-name> --qualifier '$LATEST' --region <region> --query '{FunctionName:FunctionName,Version:Version,PackageType:PackageType,Runtime:Runtime,State:State,LastUpdateStatus:LastUpdateStatus,LastModified:LastModified}' --output json
```

Stop unless the configuration reports `$LATEST`, `Zip`, `Active`, and `Successful`. Do not invoke the Lambda as a runtime test unless the user explicitly asks.

## 4. Prepare Package And Backup

Use `~\.test\<lambda-directory-name>` as the working directory. Use a timestamp like `yyyyMMdd-HHmmss`.

Recommended filenames:

- Local package: `<lambda-directory-name>-local-<timestamp>.zip`
- Original live backup: `<lambda-directory-name>-live-<function-name>-<timestamp>.zip`
- State file: `deploy-state.json`

Packaging rules:

State file rules:

- Write or update `deploy-state.json` after target resolution, after backup verification, after each upload, and after restore.
- Keep it under the working directory only.
- Include at least `phase`, `repoRoot`, `lambdaRoot`, `selectionSource`, `selectionFiles`, `explicitLambdaInput`, `selectedRootStatus`, `selectedRootStatusFingerprint`, `unrelatedStatus`, `stagedFiles`, `stagedTreeHash`, `headCommit`, `functionName`, `region`, `targetSource`, `awsAccount`, `awsArn`, `originalBackupZip`, `originalBackupVerifiedAt`, `originalBackupSha256` when available, `currentLocalZip`, `lastUploadedZip`, `retryCount`, `lastUploadAt`, `lastRestoreAt`, `uploadCommand`, and `restoreCommand`.
- Use phases such as `target-resolved`, `awaiting-upload-confirmation`, `awaiting-test`, `retry-pending`, `restored`, and `canceled`.
- Never replace `originalBackupZip` during failed-test retries.

- Inspect CI/CD and `updateFunction.sh` only to understand package contents and exclusions.
- Do not run commands that write inside the repository, including install, build, generator, formatter, cleanup, or dependency repair commands.
- If required build outputs or dependencies are not already present, stop and ask the user to prepare them.
- Compress only deployable files already present under the Lambda root, preserving the Lambda root contents as the ZIP root.
- Exclude `.git`, the `~\.test` working directory, and backup ZIPs.
- Include `node_modules` only when the repository's CI/CD or local packaging convention includes installed runtime dependencies in the Lambda ZIP.
- In explicit mode, include the current deployable files under the selected Lambda root even when they are unstaged or untracked, after showing those paths in the confirmation summary. Deleted tracked files under that root are absent from the package.

On the initial upload, prepare the local ZIP first, then download the current live `$LATEST` package:

```powershell
aws lambda get-function --function-name <function-name> --qualifier '$LATEST' --region <region> --query 'Code.Location' --output text
```

Download the returned pre-signed URL to the backup ZIP path. Verify the file exists, is nonempty, was created for this run, and is readable when local tooling can list ZIP contents.

On retry uploads after a failed test, create a new local ZIP only. Do not download or replace the original live backup.

## 5. Confirm Before Upload

After the local ZIP and original live backup are verified, stop and show a compact summary:

- Lambda root, selection source, and selection files.
- Explicit Lambda input when `selectionSource` is `explicit-lambda`.
- Changed, deleted, and untracked files under the selected Lambda root in explicit mode, summarized when long.
- Unrelated changed files outside the selected Lambda root in explicit mode, summarized as ignored for packaging.
- Target function, region, target source, AWS account, and ARN.
- Lambda readiness result.
- Staged tree hash when `selectionSource` is `staged`, or `HEAD` commit hash when `selectionSource` is `latest-commit`.
- Local ZIP path and original live backup path.
- State file path.
- Initial upload or retry upload.
- Exact upload command, with no `--publish`.
- Exact restore command using the original live backup ZIP.
- Confirmation that no publish, alias/tag update, staging/production deploy, or extra deploy command will run.

Ask for explicit confirmation before uploading. Keep the summary compact; omit ZIP entry counts, long file listings, and ZIP sizes unless suspicious or requested.

## 6. Upload After Confirmation

Only after explicit confirmation:

1. Re-check `git status --porcelain=v1`.
2. If `selectionSource` is `explicit-lambda`, compare the selected-root status fingerprint with the recorded fingerprint; stop only when package-relevant status under the selected Lambda root changed after confirmation. Ignore unrelated status outside the selected Lambda root.
3. If `selectionSource` is `staged`, stop on new unstaged, untracked, or changed staged files; re-run `git write-tree`; stop if it differs from the recorded tree hash.
4. If `selectionSource` is `latest-commit`, stop on new unstaged, untracked, or staged files; re-run `git rev-parse HEAD` and stop if it differs from the recorded `headCommit`.
5. Re-check `aws sts get-caller-identity`; stop if account or ARN differs from the confirmation summary.
6. Re-check that the original live backup ZIP exists, is nonempty, and is readable.
7. Upload:

```powershell
aws lambda update-function-code --function-name <function-name> --region <region> --zip-file fileb://<local-deployment-zip>
```

8. Confirm the AWS CLI response reports `Version` = `$LATEST`.
9. Wait for `$LATEST` and show final status:

```powershell
aws lambda wait function-updated --function-name <function-name> --qualifier '$LATEST' --region <region>
aws lambda get-function-configuration --function-name <function-name> --qualifier '$LATEST' --region <region> --query '{FunctionName:FunctionName,Version:Version,State:State,LastUpdateStatus:LastUpdateStatus,LastModified:LastModified}' --output json
```

Stop and ask the user to test `$LATEST`. Include the function, region, account, local ZIP, backup ZIP, and exact restore command.

Update `deploy-state.json` to `phase: awaiting-test` after upload succeeds.

## 7. Handle Test Result

When the user reports the result:

- Passed: load state, re-check AWS identity and original backup, restore the backup to `$LATEST`, confirm `Version` = `$LATEST`, wait for `function-updated`, update state to `restored`, and report the restored status.
- Failed: load state, update state to `retry-pending`, do not restore, and do not create a new backup. Ask the user to modify and stage Lambda code, then repeat from git analysis with the same account, function, region, and original backup.
- Canceled: load state and ask whether to restore the original backup before stopping. If the user declines restore, update state to `canceled`.

Restore command:

```powershell
aws lambda update-function-code --function-name <function-name> --region <region> --zip-file fileb://<live-backup-zip>
```
