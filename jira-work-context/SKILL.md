---
name: jira-work-context
description: 'Use Atlassian CLI (`acli`) as a compact Jira Cloud command guide: authenticate, discover help, search/view work items, inspect projects/boards/sprints/filters, manage comments, and run explicit user-requested Jira CLI actions safely. Use when Codex needs Jira CLI syntax or safe Jira CLI execution. This skill is not a Jira workflow planner; defer team/process workflows to a separate workflow skill.'
---

# Jira CLI

Use this skill for Jira CLI command knowledge and safety boundaries, not team process or ticket workflow decisions.

## Boundary

- Use for `acli jira` syntax, flags, output shaping, command discovery, and safe execution.
- Do not invent standup/status-report policy, sprint ritual, QA handoff, approval policy, or team workflow. A separate workflow skill owns those choices.
- Prefer local `--help` over web memory during execution. Official Atlassian ACLI docs can be used when maintaining this skill, but this skill must stay useful without loading web references.
- Prefer read-only commands until the user explicitly asks to create, update, assign, transition, delete, archive, link, or comment.
- Before mutations, identify the exact target and action. Prefer `--key` over `--jql` or `--filter`.
- Treat `--jql`, `--filter`, `--paginate`, `--yes`, `create-bulk`, and any delete/archive/transition/assign/edit operation as batch or destructive risk requiring explicit user confirmation unless the request already names that action and scope.

## Discover Commands

If the exact syntax is uncertain, run local help instead of relying on memory:

```powershell
acli jira --help
acli jira <area> --help
acli jira workitem <verb> --help
acli jira workitem comment <verb> --help
```

Verify auth before real queries:

```powershell
acli jira auth status
acli jira auth login --help
```

Prefer `--json` for parsing, `--fields` for small payloads, `--limit` before `--paginate`, and `--web` only when the user wants a browser.

## Command Map

- Root: `auth`, `board`, `dashboard`, `field`, `filter`, `project`, `sprint`, `workitem`.
- Work item read: `search`, `view`, `comment list`, `attachment list`, `link list`, `link type`, `watcher list`.
- Work item comment: `comment create`, `comment update`, `comment visibility`; avoid `comment delete` unless explicitly requested.
- Work item mutation: `create`, `create-bulk`, `edit`, `assign`, `transition`, `clone`, `link create/delete`, `watcher remove`, `attachment delete`, `archive`, `unarchive`, `delete`.
- Project: `list`, `view`; guarded mutations are `create`, `update`, `archive`, `restore`, `delete`.
- Board: `search`, `get`, `list-projects`, `list-sprints`; guarded mutations are `create`, `delete`.
- Sprint: `view`, `list-workitems`; guarded mutations are `create`, `update`, `delete`.
- Filter: `list`, `search`, `get`, `get-columns`; guarded mutations are `add-favourite`, `update`, `reset-columns`, `change-owner`.
- Field: `create`, `update`, `delete`, `cancel-delete`; all are guarded admin-style mutations.
- Dashboard: `search`.

## Read Patterns

```powershell
acli jira workitem search --jql "assignee = currentUser() AND resolution IS EMPTY ORDER BY updated DESC" --fields "key,summary,status,priority,assignee,updated" --limit 20 --json
acli jira workitem search --filter 10001 --fields "key,summary,status,assignee" --limit 50 --json
acli jira workitem view KEY-123 --fields "key,issuetype,summary,status,assignee,reporter,priority,description" --json
acli jira workitem comment list --key KEY-123 --limit 20 --order "-created" --json
```

For repo-derived context, extract Jira keys from branch or recent commits first, then view by key:

```powershell
git branch --show-current
git log -5 --oneline
```

## Mutation Patterns

```powershell
acli jira workitem comment create --key KEY-123 --body "Comment text" --json
acli jira workitem comment create --key "KEY-1,KEY-2" --body-file comment.txt --json
acli jira workitem comment update --key KEY-123 --id 10001 --body-file comment.txt
acli jira workitem create --project TEAM --type Task --summary "New task" --description "Plain text or ADF" --json
acli jira workitem edit --key KEY-123 --summary "New summary" --json
acli jira workitem assign --key KEY-123 --assignee "@me" --json
acli jira workitem transition --key KEY-123 --status "In Progress" --json
```

Use generated JSON for complex create/edit payloads:

```powershell
acli jira workitem create --generate-json
acli jira workitem create --from-json workitem.json
acli jira workitem edit --generate-json
acli jira workitem edit --from-json workitem.json
```

## Output

- For summaries, report only task-relevant fields: key, summary, status, assignee, priority, update signal, relevant description/comment details, blockers, and likely next command.
- If a command fails from syntax drift, rerun the relevant `--help`, adjust, and keep the final answer focused on the successful command/output.
