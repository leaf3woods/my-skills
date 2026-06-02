# Company Self-Test Preset

Default preset for `developer-self-test-report`.

## Ticket Rules

- Branch ticket key pattern: `(?i)RWC-\d+`.
- Sprint branch example: `RWC-sprint-57/RWC-3932-fix-order-filter`.
- Ticket URL template:

```text
https://sprintray.atlassian.net/browse/<TICKET_KEY>
```

If no full ticket link is provided but a key is found, generate:

```md
[<TICKET_KEY>](https://sprintray.atlassian.net/browse/<TICKET_KEY>)
```

Ask for a ticket link only when no full ticket link exists and no key can be extracted.

## Base Branch Policy

Compare against a long-lived development or staging-equivalent branch. Discover and classify remote branches by meaning rather than requiring exact names.

- Development aliases include `dev`, `develop`, `development`, and `integration`.
- Staging aliases include `stage`, `staging`, `preprod`, `pre-production`, `preproduction`, and `uat`.
- Reject primary or production-equivalent branches such as `main`, `master`, `trunk`, `prod`, `production`, `live`, and `stable`.

Allow remote namespaces around clear aliases, compare case-insensitively, and ask when a branch such as `release` is ambiguous. Prefer the branch with the most reasonable fork point and smallest divergence.

Never compare company work against a primary or production-equivalent branch.

## Default Template

Use [../templates/qa-handoff.md](../templates/qa-handoff.md).

## Analysis Style

- Use business-level English.
- Focus on the ticketed work item and directly changed behavior.
- Treat `Self-Test Result` as the developer's own verification of the delivered change, not as a summary of code edits.
- Center the report on whether the ticketed requirement or directly changed behavior is implemented, usable, and observable at the product, API, service, job, workflow, or integration boundary.
- In `Verification`, lead with concrete behavior evidence: what surface was exercised, what action or input was used, and what expected outcome was observed.
- Build success, compile success, lint/static analysis, code review, or "implementation added" statements are only supporting evidence unless the change itself is build/config/test-only.
- For runtime, API, UI, service, job, or integration changes, do not mark the result as `Passed` from build/static/code-level validation alone. Use `Needs verification` or `Not run` if functional self-test evidence is unavailable.
- Do not assume the ticket is a bug. Describe feature work, refactors, configuration changes, docs-only changes, and test-only changes using their actual change type.
- By default, set developer self-test result to `Passed` only when the report includes at least one concrete requirement-level or changed-behavior verification, or when build/config/test-only validation is the changed behavior itself.
- Evidence is provided separately by the developer as screenshots or videos unless user-provided context says otherwise.
- Regression suggestions should be concise focus areas, not step-by-step QA instructions.
