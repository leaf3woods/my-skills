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

## Base Branch Candidates

Use these candidates when the user does not provide a base branch:

```text
origin/staging
origin/develop
```

Prefer the branch with the most reasonable fork point and smallest divergence.

Never default to `main` or `master`.

## Default Template

Use [../templates/qa-handoff.md](../templates/qa-handoff.md).

## Analysis Style

- Use business-level English.
- Focus on the ticketed work item and directly changed behavior.
- Do not assume the ticket is a bug. Describe feature work, refactors, configuration changes, docs-only changes, and test-only changes using their actual change type.
- By default, set developer self-test result to `Passed`.
- Evidence is provided separately by the developer as screenshots or videos unless user-provided context says otherwise.
- Regression suggestions should be concise focus areas, not step-by-step QA instructions.
