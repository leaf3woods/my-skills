---
name: aws-lambda-dev-deploy
description: Safely upload one staged AWS Lambda project to a dev Lambda function's $LATEST code only, with AWS CLI, a verified live ZIP backup, explicit confirmation, user testing pause, and automatic restore after a passing test. Use when Codex is asked to test Lambda changes in dev, back up and restore the current Lambda package, or run a guarded update flow from updateFunction.sh without publishing versions, aliases, tags, or staging/production deploys.
---

# AWS Lambda Dev Deploy

## Core Rule

Upload only one staged Lambda project to the selected dev Lambda function's unpublished `$LATEST` code, and only after backing up the latest live `$LATEST` ZIP, verifying the default AWS account, and receiving explicit user confirmation. Never publish a version, update an alias/tag, or run an extra deploy command.

After upload, wait until `$LATEST` is active, then stop for user testing. If the user says the test passed, upload the original live backup back to `$LATEST` to restore the shared environment. If the user says the test failed, wait for the user to modify and stage Lambda code, then upload another local ZIP to `$LATEST` without replacing the original live backup. Repeat until the user says the test passed.

Use the developer machine's default AWS login. Do not require, parse, or pass `--profile`.

## Required Stop Conditions

Stop immediately and report the reason when any of these are true:

- More than one Lambda project has staged changes. List each candidate Lambda directory and ask which one to deploy.
- The staged changes are not Lambda code, or they include files outside the selected Lambda project.
- Any changed code is not staged, including unstaged tracked files and untracked files anywhere in the repository.
- There are no staged Lambda code changes.
- The selected Lambda directory has no `updateFunction.sh`.
- `updateFunction.sh` does not clearly provide `--function-name` and `--region` for the target AWS CLI upload.
- The parsed target does not look like a dev target, or the dev target cannot be confidently identified.
- The target function name or ARN includes an alias, tag, or numeric version qualifier instead of the base function.
- The requested or discovered workflow would publish a version, update an alias/tag, deploy staging/production, or otherwise touch anything other than `$LATEST`.
- `aws sts get-caller-identity` fails or the AWS account/ARN cannot be shown to the user.
- The Lambda target is not `PackageType` = `Zip`.
- The Lambda target version cannot be verified as `$LATEST`.
- The live `$LATEST` ZIP cannot be downloaded and verified before the initial upload.
- A retry upload is requested after a failed test but the original verified live backup from the initial upload is missing.
- The user has not explicitly confirmed the final pre-upload summary.

## Git State Analysis

Start from the repository root.

1. Run `git status --porcelain=v1`.
2. Stop if any entry has unstaged worktree status, or if any entry is untracked:
   - In porcelain v1, stop when column 2 is not a space.
   - Stop on `??` entries.
3. Collect staged paths from entries whose index status in column 1 is not a space.
4. Infer candidate Lambda roots from staged paths. A Lambda root is the top-level project directory that contains `updateFunction.sh` and Lambda source/package files.
5. Stop if there is not exactly one candidate Lambda root.
6. Stop if any staged path is outside that Lambda root.
7. Record the staged tree hash with `git write-tree` before creating ZIPs. Use it later to detect staged-content drift before upload.

Do not continue by guessing. If a path classification is unclear, stop and explain what was found.

## Parse `updateFunction.sh`

Inspect the script; do not execute it just to discover parameters.

Extract these required upload parameters from the AWS Lambda update command:

- `--function-name`
- `--region`

Support normal shell line continuations and quoted literal values. If a value is stored in a variable, resolve it only when the variable is assigned a clear literal in the same file. Stop on computed, environment-dependent, missing, or conflicting values.

The function target must be an unqualified function name or base Lambda function ARN. Stop if it contains a qualifier suffix such as an alias/tag or numeric version.

Reject any discovered command or flag that would change published traffic routing or a non-`$LATEST` version, including:

- `--publish`
- `publish-version`
- `create-alias`
- `update-alias`
- deployment commands for staging or production stages

Ignore any `--profile` value found in the script. This workflow uses the default AWS identity on the developer machine only.

If the script contains multiple AWS Lambda targets, select only the one that clearly corresponds to dev. If this is ambiguous, stop and ask for confirmation before preparing any upload.

## $LATEST Effectiveness Model

`aws lambda update-function-code` without `--publish` updates only `$LATEST`. Once Lambda reports the update as successful, `$LATEST` is effective for direct `$LATEST` invocation and for integrations that already point at `$LATEST`.

Do not run an extra deploy step. If the service would require `publish-version`, alias movement, SAM/Serverless/CDK deployment, API Gateway stage deployment, or another routing update before traffic can see the change, stop and explain that this skill is limited to guarded `$LATEST` testing. Published versions, aliases, tags, staging, and production are outside this workflow.

## Verify AWS Identity And Lambda Type

Before creating or uploading ZIPs, show the default AWS caller identity:

```powershell
aws sts get-caller-identity --output json
```

Include the returned account and ARN in the confirmation summary. Stop if the command fails.

Fetch Lambda configuration for `$LATEST` and confirm the function is ZIP-based:

```powershell
aws lambda get-function-configuration --function-name <function-name> --qualifier '$LATEST' --region <region> --query '{FunctionName:FunctionName,Version:Version,PackageType:PackageType,Runtime:Runtime,State:State,LastModified:LastModified,LastUpdateStatus:LastUpdateStatus}' --output json
```

Stop if `Version` is not `$LATEST` or `PackageType` is not `Zip`.

## Working Directory And Filenames

Use the working directory:

```text
~\.test\<lambda-directory-name>
```

Create it if it does not exist. Use a timestamp such as `yyyyMMdd-HHmmss` in generated filenames.

Recommended names:

- Local deployment ZIP: `<lambda-directory-name>-local-<timestamp>.zip`
- Live backup ZIP: `<lambda-directory-name>-live-<function-name>-<timestamp>.zip`

Keep local ZIPs and the original live backup ZIP in the working directory. For retry uploads after a failed test, create a new local deployment ZIP but keep reusing the original live backup ZIP.

## Prepare ZIPs

Before downloading live code on the initial upload, prepare the local deployment ZIP.

1. Inspect `updateFunction.sh` for the packaging behavior before compressing anything.
2. If the script has clear non-upload build/package commands that create the ZIP used by `update-function-code`, follow those packaging commands without executing the upload command.
3. If no clear packaging command exists, compress all files under the selected Lambda directory into the local deployment ZIP in the working directory.
4. Preserve the Lambda directory contents as the archive root, so files such as `index.js` and `package.json` appear at the ZIP root.
5. Do not include `.git`, `node_modules` generated outside the Lambda package convention, the working directory, or backup ZIPs unless the project's packaging script explicitly includes them.
6. Stop if packaging requires dependency installation, build outputs, or exclusion rules that cannot be confidently inferred.
7. On the initial upload only, download the current live `$LATEST` Lambda package:

```powershell
aws lambda get-function --function-name <function-name> --qualifier '$LATEST' --region <region> --query 'Code.Location' --output text
```

Use the returned pre-signed URL to download the live ZIP into the working directory.

8. Verify the live backup before upload:
   - The backup ZIP path exists.
   - The backup ZIP size is greater than zero.
   - The backup was created in this run, after parameter parsing.
   - Prefer opening/listing the ZIP to confirm it is a readable archive when local tooling supports it.

For retry uploads after a failed test, do not download a new live backup. Reuse the original verified backup from the initial upload and stop if it cannot be found or verified.

## Pre-Upload Confirmation

After the local ZIP is prepared and the original live backup is verified, stop and show a concise summary. Do not upload yet.

Include:

- Selected Lambda directory name and path.
- Staged files that will be deployed.
- Live AWS Lambda function name.
- AWS region.
- AWS account and ARN from `aws sts get-caller-identity`.
- Working directory.
- Staged tree hash recorded before ZIP creation.
- Local deployment ZIP path and size.
- Original live `$LATEST` backup ZIP path and size.
- Whether this is the initial upload or a retry upload that reuses the original backup.
- Exact `aws lambda update-function-code` command to be run, including `fileb://` ZIP path and no `--publish`.
- Exact restore command using the original live backup ZIP.
- Confirmation that no publish, alias/tag update, staging/production deploy, or extra deploy command will be run.
- Confirmation that the latest live `$LATEST` backup has already been downloaded and verified, or that a retry upload is reusing that original verified backup.

Ask the user to confirm before continuing.

## Upload After Confirmation

Only after explicit user confirmation:

1. Re-check `git status --porcelain=v1`; stop if new unstaged, untracked, or changed staged files appeared after ZIP creation.
2. Re-run `git write-tree`; stop if it differs from the staged tree hash recorded before ZIP creation.
3. Re-check `aws sts get-caller-identity`; stop if the account or ARN differs from the identity shown in the confirmation summary.
4. Re-check that the live backup ZIP still exists, has nonzero size, and was created for the same function and region in this run.
5. Upload with:

```powershell
aws lambda update-function-code --function-name <function-name> --region <region> --zip-file fileb://<local-deployment-zip>
```

6. Confirm the AWS CLI response reports `Version` = `$LATEST`. Stop and report a critical safety issue if it does not.
7. Wait for `$LATEST` to become active:

```powershell
aws lambda wait function-updated --function-name <function-name> --qualifier '$LATEST' --region <region>
aws lambda get-function-configuration --function-name <function-name> --qualifier '$LATEST' --region <region> --query '{FunctionName:FunctionName,Version:Version,State:State,LastUpdateStatus:LastUpdateStatus,LastModified:LastModified}' --output json
```

8. Stop and ask the user to test `$LATEST`. Do not restore or continue until the user reports the result. Include function name, region, AWS account, local ZIP, backup ZIP, and restore command:

```powershell
aws lambda update-function-code --function-name <function-name> --region <region> --zip-file fileb://<live-backup-zip>
```

## After User Testing

When the user reports the test result:

- If the test passed, restore the original live backup to `$LATEST`.
- If the test failed, do not restore and do not create a new live backup. Ask the user to modify and stage the Lambda code, then repeat the upload flow with a new local ZIP and the original live backup.
- If the user wants to cancel testing before a pass, ask whether to restore the original live backup before stopping.

Before restoring after a pass:

1. Re-check `aws sts get-caller-identity`; stop if the account or ARN differs from the identity used for upload.
2. Re-check that the original live backup ZIP exists, has nonzero size, and is readable.
3. Restore with:

```powershell
aws lambda update-function-code --function-name <function-name> --region <region> --zip-file fileb://<live-backup-zip>
```

4. Confirm the AWS CLI response reports `Version` = `$LATEST`.
5. Wait for `$LATEST` to become active with `aws lambda wait function-updated --function-name <function-name> --qualifier '$LATEST' --region <region>`.
6. Report that the original live `$LATEST` package has been restored, including function name, region, AWS account, backup ZIP, and final Lambda status.

## Do Not

- Do not deploy multiple Lambdas in one run.
- Do not deploy when non-Lambda files are part of the staged change set.
- Do not stage files for the user.
- Do not use `--profile`.
- Do not pass `--publish`.
- Do not run `publish-version`, `create-alias`, `update-alias`, staging deploys, production deploys, or any extra deploy command.
- Do not use a different region or function name than the values parsed from `updateFunction.sh` unless the user explicitly updates the script or provides a new verified source.
- Do not proceed from a missing, empty, stale, or unverifiable live backup.
- Do not replace the original live backup during retry uploads after a failed test.
- Do not leave test code on `$LATEST` after the user reports a passing test; restore the original live backup.
- Do not treat a local ZIP as a live backup.
