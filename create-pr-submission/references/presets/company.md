# Company PR Preset

Default preset for `create-pr-submission`.

## Ticket Rules

- Branch naming convention: `{sprint}/{ticket}-description`.
- Ticket key pattern: `(?i)(RWC|SDS|DSS)-\d+`.
- Sprint example: `dss-sprint-49` -> `DSS-Sprint-49`.
- Ticket example: `sds-10871` -> `SDS-10871`.
- Ticket URL template:

```text
https://sprintray.atlassian.net/browse/<TICKET_KEY>
```

Ask for a ticket link only when no full ticket link exists and no ticket key can be extracted.

Do not search repository files or git history for ticket links.

## Base Branch Candidates

Use these candidates when the user does not provide a base branch:

```text
origin/staging
origin/develop
```

Prefer the branch with the most reasonable fork point and smallest divergence.

## Title Rule

Preferred title format:

```text
<SPRINT>/<TICKET_KEY> <MOST_RELEVANT_COMMIT_MESSAGE>
```

Example:

```text
RWC-Sprint-56/RWC-3932 fix: fix order status filtering
```

If sprint is unavailable, use:

```text
<TICKET_KEY> <MOST_RELEVANT_COMMIT_MESSAGE>
```

## Reviewer Policy

Reviewer assignment is required by default.

Required default reviewers:

```text
soonsolidshenhuangjiang
tianmingxiang1031
```

Use the first non-empty additional reviewer source:

1. User-provided additional reviewers.
2. CODEOWNERS matched by changed files.
3. Git history candidates from changed files.

When using git history, inspect only changed files. Treat GitHub username evidence as higher confidence than display names or email local-parts.

## Template

Default template:

```text
company-pr
```

Use [../templates/company-pr.md](../templates/company-pr.md).
