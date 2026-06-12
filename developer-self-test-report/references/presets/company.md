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
- Center the report on whether the ticketed requirement, acceptance criteria, or reported bug is implemented and usable.
- Do not assume the ticket is a bug. Describe feature work, refactors, configuration changes, docs-only changes, and test-only changes using their actual change type.
- Set the result to `Passed` only when the supplied context contains actual behavior-level verification and its observed outcome. Otherwise use `Needs verification` or `Not run`.
- Do not include compile, build, lint, static-analysis, dependency-install, or generic test-suite results. For CI/build/config tickets, report the intended pipeline or operational behavior that was observed.
- Include evidence references only when the user provides or identifies an actual screenshot, video, log excerpt, request/response, or other artifact.
- Add concise QA focus areas when there is a plausible adjacent regression or risk; do not turn them into step-by-step test cases.
