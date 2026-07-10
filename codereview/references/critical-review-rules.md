# Critical Code Review Rules

## Finding Threshold

Report a finding only when all of these are true:

- The reviewed change introduces the defect or directly makes an existing defect reachable.
- The code provides a concrete execution path, data flow, or failure mode that demonstrates the problem.
- The impact can cause a production outage, security breach, data loss or corruption, severe performance degradation, or equivalent operational harm.
- A concrete code-level fix direction can be given.

Do not report style, naming, formatting, maintainability, minor cleanup, speculative risk, or unrelated pre-existing problems. Treat the technology-specific checks below as investigation prompts, not automatic findings.

## General Critical Checks

- Crashes, infinite loops, or resource leaks that can exhaust the process.
- Sensitive data exposure, injection, XSS, missing authorization, or privilege escalation.
- Data corruption, data loss, or incorrect irreversible operations.
- Race conditions, deadlocks, or unsafe concurrent access.
- Demonstrably severe performance failures, such as unbounded work, production-scale N+1 queries, or avoidable quadratic processing of large collections.
- Error handling that loses work, hides a failed operation as success, or creates an uncontrolled retry loop.

## Angular and TypeScript Checks

- Subscriptions, listeners, or timers that accumulate across component lifecycles and create an unbounded leak.
- Direct NgRx state mutation that breaks state consistency.
- Recursive updates or change-detection feedback loops that cannot terminate.
- Unsafe rendering or DOM access that creates an exploitable XSS path.

## ASP.NET Core and Entity Framework Checks

- Blocking asynchronous work with `.Result` or `.Wait()` where it can deadlock or exhaust request threads.
- N+1 or unbounded database queries on a production-scale request path.
- Missing authorization on sensitive endpoints or resources.
- Lazy loading or client-side evaluation that makes a request path unexpectedly unbounded.
- Swallowed exceptions or incorrect success responses that hide failed writes or external operations.

## AWS Lambda Checks

- Error handling that loses events, acknowledges failed work, or causes uncontrolled retries.
- Secrets or credentials embedded in source code.
- Connections, streams, temporary resources, or child processes that leak across invocations.
- Non-idempotent retry behavior that duplicates irreversible work.

## SQL and Migration Checks

- Destructive `UPDATE` or `DELETE` statements without an appropriately restrictive predicate.
- Migrations that irreversibly discard or corrupt required data.
- Table rewrites or long-held locks that can block a large production table.
- Non-idempotent migration logic that can corrupt state when retried.
