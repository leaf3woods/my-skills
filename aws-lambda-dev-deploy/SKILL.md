---
name: aws-lambda-dev-deploy
description: Guarded AWS Lambda dev-test workflow for one staged Lambda project: resolve a dev target from CI/CD or updateFunction.sh, package existing repository files without modifying them, back up live $LATEST, upload only to $LATEST, persist deploy-state.json for cross-session resume, pause for user testing, and restore the original package after a passing test. Use when Codex is asked to test Lambda changes in dev, resume an in-progress Lambda test, or run a safe Lambda update/restore flow that must not publish versions, update aliases/tags, use profiles, or deploy staging/production.
---

# AWS Lambda Dev Deploy

## Core Rules

- Work from the repository root and handle exactly one staged Lambda project.
- Stop on any unstaged tracked change or untracked file anywhere in the repository.
- Do not edit, stage, install, build, generate, format, clean, or otherwise modify repository files.
- Create only deployment/backup artifacts under `~\.test\<lambda-directory-name>`.
- Persist deployment state in `~\.test\<lambda-directory-name>\deploy-state.json`; use it to resume testing, retry, or restore across windows.
- Use the developer machine's default AWS identity. Do not require, parse, or pass `--profile`.
- Resolve the base dev Lambda function and region from CI/CD first, then `updateFunction.sh` as fallback, or an explicit one-off user override. Record the target source.
- Upload only to `$LATEST` with `aws lambda update-function-code` and no `--publish`.
- Never publish versions, update aliases/tags, run API Gateway stage deploys, or deploy staging/production.
- On the initial upload, back up the current live `$LATEST` package. On failed-test retries, reuse that original backup. After a passing test, restore that original backup to `$LATEST`.
- Never treat a local deployment ZIP as the live backup.

## Stop Conditions

Stop immediately when any of these are true:

- Staged paths do not identify exactly one Lambda root, or any staged path is outside that root.
- Git status has an unstaged worktree status or `??` entry.
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

- Stop when column 2 is not a space, or on any `??` entry.
- Collect staged paths from entries whose index status in column 1 is not a space.
- Infer the Lambda root as the top-level project directory that contains Lambda source/package files, with or without `updateFunction.sh`.
- Stop if there is not exactly one candidate Lambda root.
- Record staged files and `git write-tree`; use the tree hash later to detect staged-content drift.

## 2. Resolve Target

Inspect CI/CD before relying on `updateFunction.sh`.

For GitHub Actions, check `.github/workflows/*.yml` and `.github/workflows/*.yaml` for Lambda upload commands, AWS credential setup, region variables, and mapping files such as `.github/workflows/lambdaMapper.json`.

Use CI/CD as the target source when it clearly maps the selected Lambda root to exactly one function and region. Record the workflow path, mapping path if any, function name, and region.

If the user provides a one-off test function name, use it only for the current run and still require a verified region from CI/CD, `updateFunction.sh`, AWS CLI config, or an explicit user-provided value. Show the override in the confirmation summary.

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
- Include at least `phase`, `repoRoot`, `lambdaRoot`, `stagedFiles`, `stagedTreeHash`, `functionName`, `region`, `targetSource`, `awsAccount`, `awsArn`, `originalBackupZip`, `originalBackupVerifiedAt`, `originalBackupSha256` when available, `currentLocalZip`, `lastUploadedZip`, `retryCount`, `lastUploadAt`, `lastRestoreAt`, `uploadCommand`, and `restoreCommand`.
- Use phases such as `target-resolved`, `awaiting-upload-confirmation`, `awaiting-test`, `retry-pending`, `restored`, and `canceled`.
- Never replace `originalBackupZip` during failed-test retries.

- Inspect CI/CD and `updateFunction.sh` only to understand package contents and exclusions.
- Do not run commands that write inside the repository, including install, build, generator, formatter, cleanup, or dependency repair commands.
- If required build outputs or dependencies are not already present, stop and ask the user to prepare them.
- Compress only deployable files already present under the Lambda root, preserving the Lambda root contents as the ZIP root.
- Exclude `.git`, the `~\.test` working directory, and backup ZIPs.
- Include `node_modules` only when the repository's CI/CD or local packaging convention includes installed runtime dependencies in the Lambda ZIP.

On the initial upload, prepare the local ZIP first, then download the current live `$LATEST` package:

```powershell
aws lambda get-function --function-name <function-name> --qualifier '$LATEST' --region <region> --query 'Code.Location' --output text
```

Download the returned pre-signed URL to the backup ZIP path. Verify the file exists, is nonempty, was created for this run, and is readable when local tooling can list ZIP contents.

On retry uploads after a failed test, create a new local ZIP only. Do not download or replace the original live backup.

## 5. Confirm Before Upload

After the local ZIP and original live backup are verified, stop and show a compact summary:

- Lambda root and staged files.
- Target function, region, target source, AWS account, and ARN.
- Lambda readiness result.
- Staged tree hash.
- Local ZIP path and original live backup path.
- State file path.
- Initial upload or retry upload.
- Exact upload command, with no `--publish`.
- Exact restore command using the original live backup ZIP.
- Confirmation that no publish, alias/tag update, staging/production deploy, or extra deploy command will run.

Ask for explicit confirmation before uploading. Keep the summary compact; omit ZIP entry counts, long file listings, and ZIP sizes unless suspicious or requested.

## 6. Upload After Confirmation

Only after explicit confirmation:

1. Re-check `git status --porcelain=v1`; stop on new unstaged, untracked, or changed staged files.
2. Re-run `git write-tree`; stop if it differs from the recorded tree hash.
3. Re-check `aws sts get-caller-identity`; stop if account or ARN differs from the confirmation summary.
4. Re-check that the original live backup ZIP exists, is nonempty, and is readable.
5. Upload:

```powershell
aws lambda update-function-code --function-name <function-name> --region <region> --zip-file fileb://<local-deployment-zip>
```

6. Confirm the AWS CLI response reports `Version` = `$LATEST`.
7. Wait for `$LATEST` and show final status:

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
