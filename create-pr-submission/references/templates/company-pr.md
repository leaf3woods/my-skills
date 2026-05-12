# Company PR Template

Generate the PR body in this structure.

Required sections:

```md
## Ticket

[<TICKET_KEY>](<TICKET_URL>)

## Description

<Briefly explain the problem or requirement and what this PR changes.>

## Changes

- <Reviewer-friendly summary of a key change>
- <Reviewer-friendly summary of another key change>
```

Optional sections:

```md
## Validation

- <Only include useful validation information.>

## Impact / Risk

- <Only include useful impact, risk, or reviewer attention points.>
```

Footer:

```md
---

Submitted by <CURRENT_AGENT>.
```

Rules:

- Omit optional sections when there is no useful content.
- Do not add empty sections.
- Resolve `<CURRENT_AGENT>` from runtime, user input, or obvious host/tool context; otherwise use `AI agent`.
