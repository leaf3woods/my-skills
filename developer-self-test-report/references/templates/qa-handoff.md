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
  - <Start with one or more checks that prove the changed requirement or behavior is implemented: API endpoint call and observed result, UI/workflow behavior, service/job behavior, bugfix re-test, refactor preserved behavior, config/build behavior, docs/test-only validation, or mixed-change coverage.>
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
- For API, UI, service, job, or integration changes, verification should focus on the changed behavior being usable and meeting the requirement. Do not use build success as the primary proof.
- Do not generate exhaustive test cases.
- Mention Impact / Risk only when directly related.
- Mention test suggestions only when user ask to.
