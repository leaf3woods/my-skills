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

## Base Branch Policy

Company PRs must target a long-lived development or staging-equivalent branch. Discover remote branches and classify them by meaning instead of requiring only two exact names.

Accepted semantic groups include:

- Development: `dev`, `develop`, `development`, `integration`.
- Staging: `stage`, `staging`, `preprod`, `pre-production`, `preproduction`, `uat`.

Allow a remote namespace such as `origin/`, `upstream/`, or `env/` around a clear alias. Compare case-insensitively and normalize `-`, `_`, and `.` only for alias matching. Treat a branch as a candidate only when it appears to be a long-lived environment/integration branch; do not accept a feature branch just because its description contains one of these words.

Reject primary or production-equivalent branches, including `main`, `master`, `trunk`, `prod`, `production`, `live`, and `stable`. This rejection also applies to user-provided base branches. Do not treat `release` as automatically allowed or rejected because repository conventions vary; ask the user when its role is unclear.

When multiple branches are allowed, prefer:

1. The branch named by the user or reusable context, after validation.
2. A staging-equivalent branch when the current branch forked from it or the ticket/workflow indicates staging delivery.
3. A development-equivalent branch otherwise.

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

Always include the required default reviewers. Then accumulate relevant additional reviewers from all applicable sources:

1. User-provided additional reviewers.
2. CODEOWNERS matched by changed files.
3. Reviewers from recent merged PRs that changed the same primary modules or ownership areas.
4. Git history candidates from changed files.

Add enough reviewers to cover materially different ownership areas represented by the PR; do not impose a fixed one-reviewer cap. Avoid adding multiple inferred reviewers for the same area when they provide no additional coverage.

When using PR or git history, inspect only directly changed files or their owning modules. Prefer active reviewers with repeated recent involvement. Treat verified GitHub usernames or team handles as higher confidence than display names or email local-parts. Exclude the author, bots, inactive accounts, duplicates, and uncertain identity mappings.

## Template

Default template:

```text
company-pr
```

Use [../templates/company-pr.md](../templates/company-pr.md).
