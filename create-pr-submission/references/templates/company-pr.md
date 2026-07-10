# Company PR Template

Generate the PR body in this structure.

Required sections:

```md
## Ticket

[<TICKET_KEY>](<TICKET_URL>)

## Description

<Briefly explain the requirement or reported problem and the user-visible or operational outcome of this PR.>

## Changes

- <Reviewer-relevant summary of a behavior, rule, API, workflow, or data-contract change>
- <Another material change only when useful>
```

Optional sections

```md
## Validation

- <Requirement, task, acceptance criterion, or bug scenario exercised and the observed result.>

## Impact / Risk

- <Only include useful impact, risk, or reviewer attention points.>
```

Rules:

- Omit optional sections when there is no useful content.
- Do not add empty sections.
- Keep `Changes` at behavior and review-decision level. Omit file lists, class names, routine refactors, generated files, dependency restoration, and other implementation inventory unless they change behavior or require reviewer attention.
- Include `Validation` only for validation that was actually performed. Tie each bullet to requirement completion, task completion, an acceptance criterion, bug reproduction, API/UI/job/workflow behavior, authorization or validation rule, or relevant failure path, and include the observed outcome.
- Do not include build, compile, lint, static-analysis, dependency-install, or generic test-suite success as PR validation. If the work itself changes CI, build, or configuration behavior, describe the changed pipeline or operational outcome instead of the command result.
- Do not infer successful validation from code inspection or diffs. Omit `Validation` when no behavior-level result is available.
- Include `Impact / Risk` only for a concrete compatibility concern, rollout/migration requirement, known limitation, data effect, or area needing focused review.
