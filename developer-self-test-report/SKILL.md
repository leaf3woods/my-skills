---
name: developer-self-test-report
description: Generate concise developer self-test reports in English from git commits, branch changes, branch metadata, and ticket information for QA handoff.
---

# Skill: Generate Developer Self-Test Report from Git Commits

## Purpose

Generate a concise developer self-test report based on git commits or branch differences.

Use this skill when the user wants to prepare a QA handoff or generate a developer self-test report.

---

## Input

- base_branch: The branch from which the current branch was created, if known.
- current_branch: Current branch, auto-detected if not provided.
- ticket_link: Full ticket link, optional.
- optional_context: Additional business context, optional.

---

## Required Workflow

1. Get the current branch name.
2. Resolve the ticket link from conversation context or branch name.
3. Determine the correct base branch.
4. Analyze commits first.
5. Analyze changed files only for impact scope.
6. Inspect diff only when commit messages are unclear.
7. Generate a concise developer self-test report in English.

---

## Branch Metadata and Ticket Resolution

Before asking the user for a ticket link, inspect the current branch name.

The branch name may contain:

- Sprint identifier, for example: `RWC-sprint-57`
- Ticket key, for example: `RWC-3932`
- Shortened ticket title or description

### Ticket Key Extraction

Extract the ticket key from the current branch name using:

```text
RWC-\d+
```

Examples:

```text
RWC-sprint-57/RWC-3932-fix-order-filter
```

Extracted ticket key:

```text
RWC-3932
```

If no full ticket link is provided but a ticket key is found, generate the ticket link as:

```text
https://sprintray.atlassian.net/browse/<TICKET_KEY>
```

Example Markdown output:

```md
[RWC-3932](https://sprintray.atlassian.net/browse/RWC-3932)
```

Only ask the user for the ticket link if:

- no full ticket link exists in the conversation context, and
- no ticket key can be extracted from the branch name.

Do not search the repository or git history for the ticket link.

### Branch Title Context

After removing the sprint identifier and ticket key from the branch name, the remaining text may be used as weak business context.

Rules:

- Treat branch title context as weak evidence only.
- Commit messages have higher priority.
- If branch title context conflicts with commits or changed files, ignore it.
- If the branch title is truncated, unclear, or misleading, ignore it.

---

## Base Branch Detection

The base branch is the branch from which the current branch was created.

Determine it using this priority:

1. If explicitly provided by the user, use it.
2. Otherwise, infer using `git merge-base --fork-point` and commit difference comparison.
3. Candidate branches should include:
   - `origin/staging`
   - `origin/develop`
4. Prefer the branch with the most reasonable fork point and smallest divergence.
5. If still uncertain, ask the user.

Never default to `main` or `master`.

---

## Git Commands

### Get current branch

Run this before asking for a ticket link, because the ticket key may be derived from the branch name.

```bash
git branch --show-current
```

### Fetch latest branch information

```bash
git fetch --all --prune
```

### Infer base branch if not provided

```bash
git merge-base --fork-point origin/staging HEAD
git merge-base --fork-point origin/develop HEAD
```

Compare divergence if needed:

```bash
git log --oneline origin/staging..HEAD
git log --oneline origin/develop..HEAD
```

### Get commit list

```bash
git log --oneline --decorate --no-merges <base_branch>..HEAD
```

### Get full commit details

```bash
git log --no-merges --pretty=format:"%h%n%s%n%b%n---" <base_branch>..HEAD
```

### Get changed files

```bash
git diff --name-status <base_branch>...HEAD
```

### Inspect diff only if necessary

Only inspect diff when commit messages are unclear or insufficient.

```bash
git diff <base_branch>...HEAD -- <file_path>
```

Do not analyze full diff by default.

---

## Analysis Rules

Use information in this priority order:

1. User-provided context
2. Commit messages and commit bodies
3. Ticket key and ticket link
4. Branch title context
5. Changed files
6. Diff, only when necessary

Rules:

- Prefer commit messages over diff.
- Aggregate commits into business-level changes.
- Ignore non-functional changes unless they affect behavior:
  - formatting
  - comments
  - rename-only changes
  - chore-only changes
- Use business-level English.
- Avoid code-level descriptions.
- If the change remains unclear, mention it in the report.

---

## Report Structure

Generate the report in this exact structure:

```md
# Self-Test Report

## 0. Related Requirement

- Ticket: [<TICKET_NAME>](<TICKET_URL>)

## 1. Summary of Changes

<Briefly summarize the fix or change in business-level English. Focus on what issue was fixed or what behavior was changed.>

## 2. Affected Modules

- <Directly affected module, API, page, job, or process>

## 3. Developer Self-Test Result

- Result: Passed
- Verification:
  - The issue described in the ticket has been re-tested.
  - The issue no longer reproduces.
  - The directly affected behavior works as expected.
- Evidence:
  - Screenshot / video will be attached by the developer.

## 4. Regression Suggestions

- <Concise directly related regression focus area>
```

---

## Self-Test Rules

This is a developer self-test report, not a QA test plan.

The report should focus only on:

- Verifying that the ticket issue or bug has been fixed.
- Verifying the directly affected behavior.
- Mentioning minimal related impact when necessary.

Rules:

- Keep the report concise.
- Do not generate exhaustive QA test coverage.
- Do not provide step-by-step QA instructions.
- By default, the developer self-test result is `Passed`.
- Evidence is provided separately by the developer as screenshots or videos.

---

## Regression Suggestion Rules

Regression Suggestions may be included, but must stay concise.

They should describe focus areas only, not detailed QA steps.

---

## Edge Cases

- No commits → report `No code changes`.
- Only formatting or comment changes → report `No functional impact`.
- Ticket link missing and no ticket key found in branch name → ask the user for ticket link.
- Base branch uncertain → ask the user for base branch.
- High-risk logic → briefly emphasize related risk in Regression Suggestions.
