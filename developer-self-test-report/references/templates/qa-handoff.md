# QA Handoff Self-Test Template

Use for company QA handoff.

```md
# Self-Test Report

## 0. Related Work Item

- Ticket: [<TICKET_NAME>](<TICKET_URL>)

## 1. Summary of Changes

<Briefly summarize the change in business-level English. Describe the feature, fix, refactor, configuration update, or other work without assuming it is a bug fix.>

## 2. Affected Modules

- <Directly affected module, API, page, job, or process>

## 3. Self-Test Result

- Result: Passed
- Verification:
  - <One or more checks that match the actual change type: bugfix re-test, feature verification, refactor preserved behavior check, config/build verification, docs/test-only validation, or mixed-change coverage.>
- Evidence:
  - Screenshot / video will be attached by the developer.
```

Optional sections

```
## 4. Test Suggestions

- <Concise directly related, Only include useful.>

## 5. Impact / Risk

- <Only include useful impact, risk, or test attention points.>
```

Rules:

- Keep this as a developer self-test report, not a QA test plan.
- Choose verification bullets that match the change type; do not include fix-only statements for features, refactors, config changes, docs-only changes, or test-only changes.
- Do not generate exhaustive test cases.
- Do not provide step-by-step QA instructions.
- Mention risk only when directly related.
