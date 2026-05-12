---
name: aws-lambda-dev-deploy
description: Safely deploy one staged AWS Lambda project to its dev Lambda with AWS CLI after backing up the live ZIP and confirming the default AWS account. Use when Codex is asked to publish completed Lambda changes to dev, back up the current Lambda package, or run a guarded Lambda update flow from updateFunction.sh.
---

# AWS Lambda Dev Deploy

## Core Rule

Deploy only one staged Lambda project to its dev AWS Lambda target, and only after backing up the latest live Lambda ZIP, verifying the default AWS account, and receiving explicit user confirmation. Treat every ambiguity as a stop condition.

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
- `aws sts get-caller-identity` fails or the AWS account/ARN cannot be shown to the user.
- The Lambda target is not `PackageType` = `Zip`.
- The live Lambda ZIP cannot be downloaded and verified before upload.
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

Ignore any `--profile` value found in the script. This workflow uses the default AWS identity on the developer machine only.

If the script contains multiple AWS Lambda targets, select only the one that clearly corresponds to dev. If this is ambiguous, stop and ask for confirmation before preparing any upload.

## Verify AWS Identity And Lambda Type

Before creating or uploading ZIPs, show the default AWS caller identity:

```powershell
aws sts get-caller-identity --output json
```

Include the returned account and ARN in the confirmation summary. Stop if the command fails.

Fetch Lambda configuration and confirm the function is ZIP-based:

```powershell
aws lambda get-function-configuration --function-name <function-name> --region <region> --query '{FunctionName:FunctionName,PackageType:PackageType,Runtime:Runtime,LastModified:LastModified}' --output json
```

Stop if `PackageType` is not `Zip`.

## Working Directory And Filenames

Use the working directory:

```text
~\.test\<lambda-directory-name>
```

Create it if it does not exist. Use a timestamp such as `yyyyMMdd-HHmmss` in generated filenames.

Recommended names:

- Local deployment ZIP: `<lambda-directory-name>-local-<timestamp>.zip`
- Live backup ZIP: `<lambda-directory-name>-live-<function-name>-<timestamp>.zip`

Keep both ZIPs in the working directory.

## Prepare ZIPs

Before downloading live code, prepare the local deployment ZIP.

1. Inspect `updateFunction.sh` for the packaging behavior before compressing anything.
2. If the script has clear non-upload build/package commands that create the ZIP used by `update-function-code`, follow those packaging commands without executing the upload command.
3. If no clear packaging command exists, compress all files under the selected Lambda directory into the local deployment ZIP in the working directory.
4. Preserve the Lambda directory contents as the archive root, so files such as `index.js` and `package.json` appear at the ZIP root.
5. Do not include `.git`, `node_modules` generated outside the Lambda package convention, the working directory, or backup ZIPs unless the project's packaging script explicitly includes them.
6. Stop if packaging requires dependency installation, build outputs, or exclusion rules that cannot be confidently inferred.
7. Download the current live Lambda package:

```powershell
aws lambda get-function --function-name <function-name> --region <region> --query 'Code.Location' --output text
```

Use the returned pre-signed URL to download the live ZIP into the working directory.

8. Verify the live backup before upload:
   - The backup ZIP path exists.
   - The backup ZIP size is greater than zero.
   - The backup was created in this run, after parameter parsing.
   - Prefer opening/listing the ZIP to confirm it is a readable archive when local tooling supports it.

## Pre-Upload Confirmation

After both ZIPs are prepared and the live backup is verified, stop and show a concise summary. Do not upload yet.

Include:

- Selected Lambda directory name and path.
- Staged files that will be deployed.
- Live AWS Lambda function name.
- AWS region.
- AWS account and ARN from `aws sts get-caller-identity`.
- Working directory.
- Staged tree hash recorded before ZIP creation.
- Local deployment ZIP path and size.
- Live backup ZIP path and size.
- Exact `aws lambda update-function-code` command to be run, including `fileb://` ZIP path.
- Exact rollback command using the live backup ZIP.
- Confirmation that the latest live Lambda backup has already been downloaded and verified.

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

6. Report the AWS CLI result succinctly, including function name, region, AWS account, local ZIP, backup ZIP, and rollback command:

```powershell
aws lambda update-function-code --function-name <function-name> --region <region> --zip-file fileb://<live-backup-zip>
```

## Do Not

- Do not deploy multiple Lambdas in one run.
- Do not deploy when non-Lambda files are part of the staged change set.
- Do not stage files for the user.
- Do not use `--profile`.
- Do not use a different region or function name than the values parsed from `updateFunction.sh` unless the user explicitly updates the script or provides a new verified source.
- Do not proceed from a missing, empty, stale, or unverifiable live backup.
- Do not treat a local ZIP as a live backup.
