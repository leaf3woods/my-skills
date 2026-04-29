---
name: create-pr-submission
description: Generate and optionally submit concise pull requests in English from git commits, branch metadata, ticket information, reviewers, and reusable conversation context.
---

# Skill: Create Pull Request from Git Commits

## Purpose

Generate a concise PR title and body for code review and merge decision-making.

Use this skill when the user wants to create, prepare, or submit a PR.

It may reuse relevant context from the same conversation.

---

## Inputs

- base_branch: Target merge branch, if known.
- current_branch: Current branch, auto-detected if not provided.
- ticket_link: Full ticket link.
- additional_reviewers: Extra GitHub reviewer usernames or team handles, optional.
- optional_context: Additional business, implementation, validation, or risk context, optional.

---

## Sprint Ticket Resolution

Branch Naming Convention

Pattern: `{sprint}/{ticket}-description`

Example: `dss-sprint-49/sds-10871-feature-description`

- Sprint: `dss-sprint-49` → `DSS-Sprint-49`
- Ticket: `sds-10871` → `SDS-10871`

1. If a ticket key is found, generate the ticket link:

```text
https://sprintray.atlassian.net/browse/<TICKET_KEY>
```

2. Ask the user for the ticket link only if no ticket link exists and no ticket key can be extracted.

Do not search repository files or git history for the ticket link.

---

## Base Branch Detection

The base branch is the target branch into which the PR should be merged.

Resolve it using this priority:

1. User-provided base branch.
2. Reusable conversation context.
3. Inference using fork point and commit difference comparison.
4. Ask the user if still uncertain.

Candidate branches should include:

- `origin/staging`
- `origin/develop`

Never default to `main` or `master`.

---

## Git Commands

Only run commands when the needed information is not already available in context.

### Current branch

```bash
git branch --show-current
```

### Fetch latest branch information

```bash
git fetch --all --prune
```

### Infer base branch if needed

```bash
git merge-base --fork-point origin/staging HEAD
git merge-base --fork-point origin/develop HEAD
```

Compare divergence if needed:

```bash
git log --oneline origin/staging..HEAD
git log --oneline origin/develop..HEAD
```

### Get commits

```bash
git log --no-merges --pretty=format:"%h%n%s%n%b%n---" <base_branch>..HEAD
```

### Get changed files

```bash
git diff --name-status <base_branch>...HEAD
```

### Inspect diff only if necessary

Use diff only when commit messages are unclear or insufficient.

```bash
git diff <base_branch>...HEAD -- <file_path>
```

Do not analyze full diff by default.

---

## PR Title Rule

Preferred title format:

```text
<SPRINT>/<TICKET_KEY> <THE_MOST_RELEVANT_COMMIT_MESSAGE>
```

Example:

```text
RWC-Sprint-56/RWC-3932 fix: fix order status filtering
```

---

## PR Body Structure

Generate the PR body in this structure:

```md
## Ticket

[<TICKET_KEY>](https://sprintray.atlassian.net/browse/<TICKET_KEY>)

## Description

<Required. Briefly explain the problem or requirement and what this PR changes.>

## Changes

- <Reviewer-friendly summary of a key change>
- <Reviewer-friendly summary of another key change>

## Validation

- <Include only if validation information is available.>

## Impact / Risk

- <Include only if there is useful impact, risk, or reviewer attention point.>

---

Submitted by <CURRENT_AGENT>.
```

Required sections:

- `## Ticket`
- `## Description`
- `## Changes`

Optional sections may be omitted when there is no useful content:

- `## Validation`
- `## Impact / Risk`

Do not add empty or meaningless sections.

---

## Current Agent Attribution

End the PR body with:

```text
Submitted by <CURRENT_AGENT>.
```

Resolve `<CURRENT_AGENT>` using runtime, user-provided, or obvious host/tool context.

If unavailable, use:

```text
AI agent
```

---

## Reviewer Rule

Reviewer assignment is required by default.

The PR reviewers must always include these default reviewers:

- `soonsolidshenhuangjiang`
- `tianmingxiang1031`
- `soonsolidquanjiaqi`

Additional reviewers may be appended after the default reviewers using this priority:

1. User-provided additional reviewers
2. CODEOWNERS matched by changed files
3. Git history / blame-based candidates from changed files

Deduplicate reviewers before submitting the PR.

---

### Git history / blame reviewer inference

Use changed files as the source for reviewer inference.

Prefer CODEOWNERS when available. Otherwise, use git history or blame to identify frequent contributors to changed files.

Useful commands:

```bash
git ls-files '*CODEOWNERS'
```

```bash
git diff --name-only -z <base_branch>...HEAD | xargs -0 -I{} git log --format='%an <%ae>' -- "{}" | sort | uniq -c | sort -nr | head -10
```

Do not run expensive blame analysis over the entire repository.

The final reviewer list passed to GitHub CLI must use comma-separated handles, for example:

```text
soonsolidshenhuangjiang,tianmingxiang1031,soonsolidquanjiaqi,<additional_reviewer>
```

---

## Required Pre-Submission Confirmation

Before running the final PR creation command, present the important submission information to the user and wait for confirmation.

The confirmation summary must include:

- current branch
- target/base branch
- ticket
- PR title
- reviewers
- whether additional inferred reviewers were included

Prefer using an interactive user input or confirmation tool if available.

The confirmation must provide these choices:

1. Confirm and submit PR
2. Reject and provide corrections

Do not run `gh pr create` until the user confirms.

If the user rejects and provides corrections, update the PR information, show the confirmation summary again, and wait for confirmation again.

If no interactive input tool is available, ask for confirmation directly in chat.

---

## Submission

For GitHub CLI:

bash

```
gh pr create --base <base> --head <current> --title "<title>" --body-file <file> --reviewer <reviewers>
```

If no supported PR tool, output the title, body, and reviewers for manual submission.

---

## Edge Cases

- No commits → report "No code changes", ask user before creating PR.
- Missing ticket link & branch key → ask user.
- Base branch uncertain → ask user.
- GitHub rejects a required reviewer → stop and report error, do not omit.
