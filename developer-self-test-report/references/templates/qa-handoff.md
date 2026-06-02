# QA Handoff Self-Test Template

Use for company QA handoff.

```md
# Self-Test Report

## 0. Related Work Item

- Ticket: [<TICKET_NAME>](<TICKET_URL>)

## 1. Requirement / Fix Summary

<State the requirement, acceptance criterion, or reported problem and the delivered behavior in business-level English.>

## 2. Affected Behavior / Test Scope

- <Directly affected API, page, user flow, service behavior, job, integration, data rule, or operational process>

## 3. Self-Test Result

- Result: <Passed / Needs verification / Not run>
- Verification:
  - <Requirement, acceptance criterion, or bug scenario exercised; action/input; observed result.>
```

Optional sections

```md
## 4. QA Focus

- <Concise adjacent behavior, boundary, role, failure path, or compatibility area worth focused QA attention.>

## 5. Impact / Risk

- <Concrete rollout, migration, data, compatibility, known limitation, or residual-risk note.>

## 6. Evidence

- <Actual screenshot, video, request/response, log excerpt, or artifact reference supplied by the developer.>
```

Rules:

- Keep this as a developer self-test report, not a QA test plan.
- Treat `Self-Test Result` as the developer's self-test of the actual change, not an implementation summary.
- Each verification bullet for runtime behavior should name the exercised surface, the action/input, and the observed result.
- Choose verification bullets that match the change type; do not include fix-only statements for features, refactors, config changes, docs-only changes, or test-only changes.
- For a bug fix, state the original failing scenario and the observed corrected result. For a feature, map verification to acceptance criteria. For a refactor, identify the preserved user or system behavior actually exercised.
- For API, UI, service, job, or integration changes, verification must focus on the changed behavior being usable and meeting the requirement.
- Do not include build, compile, lint, static-analysis, dependency-install, or generic test-suite results. For CI/build/config tickets, describe the intended pipeline or operational behavior observed.
- Use `Passed` only when actual behavior-level validation and an observed outcome are available. Code inspection, changed files, and inferred behavior are not completed verification.
- Do not generate exhaustive test cases.
- Omit `QA Focus`, `Impact / Risk`, and `Evidence` when they add no actionable information.
- Avoid file, class, method, package, and routine implementation details.
