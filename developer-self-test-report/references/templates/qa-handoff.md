# QA Handoff Self-Test Template

Use for company QA handoff.

```md
# Self-Test Report

## 0. Related Requirement

- Ticket: [<TICKET_NAME>](<TICKET_URL>)

## 1. Summary of Changes

<Briefly summarize the fix or change in business-level English. Focus on what issue was fixed or what behavior changed.>

## 2. Affected Modules

- <Directly affected module, API, page, job, or process>

## 3. Developer Self-Test Result

- Result: Passed
- Verification:
  - The issue described in the ticket has been re-tested.
  - The issue no longer reproduces.
  - The directly affected behavior works as expected.
- Evidence:
  - Screenshot / video will be attached by the developer.

## 4. Regression Suggestions

- <Concise directly related regression focus area>
```

Rules:

- Keep this as a developer self-test report, not a QA test plan.
- Do not generate exhaustive test cases.
- Do not provide step-by-step QA instructions.
- Mention risk only when directly related.
