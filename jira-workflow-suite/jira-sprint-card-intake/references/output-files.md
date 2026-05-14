# Output Files

Use these formats for local artifacts produced by `jira-sprint-card-intake`.

## Note File

Path: `<notes_dir>/<KEY>.md`

If the file is new, create it from the resolved note template. If the file already exists and contains the generated markers, replace only the marked block. If it exists without markers, append a new `## Jira Intake - <YYYY-MM-DD>` section and place the marked block inside it.

Resolve the note template in this order:

1. User-provided path.
2. `$env:JIRA_WORKFLOW_NOTE_TEMPLATE`.
3. Current working directory: `jira-note-template.md`, `note-template.md`, then `card-note-template.md`.
4. Bundled fallback: `references/default-note-template.md`.

Supported placeholders in note templates:

- `{{key}}`
- `{{summary}}`
- `{{jira_link}}`
- `{{generated_at}}`
- `{{sprint_scope}}`
- `{{card_block}}`
- `{{handoff_path}}`
- `{{note_template_path}}`

```markdown
# <KEY> - <summary>

<!-- jira-sprint-card-intake:start -->
Generated: <ISO timestamp with timezone>
Source skill: jira-sprint-card-intake
Sprint scope: <current/open sprint | next/future sprint | explicit keys>
Jira: [<KEY>](<link>)
Note template: `<absolute path or fallback reference>`

## Card

- Type: <issue type or unknown>
- Status: <status>
- Priority: <priority or unknown>
- Assignee: <assignee or unknown>
- Reporter: <reporter or unknown>
- Sprint: <sprint name/id or unknown>
- Updated: <updated timestamp or unknown>
- Labels/components: <compact list or none>
- Parent: <parent key/summary or none>

## Request

<One to three sentences explaining what the card asks for.>

## Description Summary

<Concise summary of the description. Preserve exact acceptance criteria only when they are short and important.>

## Comment Summary

- <Most relevant decision/request/blocker, with commenter and date if useful.>
- <Recent important update.>

## Decisions

- <Known decision or "None found".>

## Blockers

- <Known blocker or "None found".>

## Open Questions

- <Question or unknown that the next skill must resolve, or "None found".>

## Next Handoff

- Handoff file: `<absolute path to _handoffs/<KEY>.handoff.md>`
<!-- jira-sprint-card-intake:end -->
```

## Handoff File

Path: `<notes_dir>/_handoffs/<KEY>.handoff.md`

Keep this file brief. It should be enough for the next skill to decide what to read and what to do next.

```markdown
# Handoff: <KEY>

Generated: <ISO timestamp with timezone>
Source skill: jira-sprint-card-intake
Status: ready

## Sources

- Note: `<absolute path to notes file>`
- Jira: [<KEY>](<link>)
- Sprint scope used: <current/open sprint | next/future sprint | explicit keys>

## Card Snapshot

- Title: <summary>
- Type/status/priority: <type> / <status> / <priority>
- Assignee: <assignee>
- Sprint: <sprint name/id or unknown>

## Checkout Plan

- Checkout branch: <branch name from branch rules, or "Needs rule file">
- Checkout base: <develop/dev/stage/etc., never main/master>
- Rule source: `<absolute path to branch rules file>`
- Safety status: <ready | blocked: unsafe base branch | blocked: missing rules>

## Standard Card Tracking Text

```text
<tracking text generated from tracking text rules>
```

- Rule source: `<absolute path to tracking text rules file>`
- Status: <ready | blocked: missing rules>

## Predicted Work Repository

- Repository: `<absolute path or repo name>`
- Confidence: <high | medium | low>
- Project context source: `<absolute path to project background file>`
- Reason: <one short sentence>

## Essential Context

- <Compact summary of what the next skill must know.>
- <Key acceptance criteria, business rule, or technical constraint.>

## Recent Comments

- <Relevant comment summary with date if useful, or "No relevant comments found".>

## Incremental Jira Comments

<!-- jira-sprint-card-intake:comment-delta:start -->
- Last checked: <ISO timestamp or never>
- State file: `<absolute path to _handoffs/.state/<KEY>.comments.json>`
- New comments since previous handoff: <count>
- Delta summary:
  - <Only newly observed decision/request/blocker/question, or "No new comments">
<!-- jira-sprint-card-intake:comment-delta:end -->

## Decisions And Blockers

- Decisions: <compact list or "None found">
- Blockers: <compact list or "None found">
- Open questions: <compact list or "None found">

## Recommended Next Step

<One sentence naming the likely next action or noting that the user must choose the next workflow skill.>
```

## Batch Index

Path: `<notes_dir>/_handoffs/sprint-intake-index.md`

Create this only when processing multiple cards in one run.

```markdown
# Sprint Intake Index

Generated: <ISO timestamp with timezone>
Source skill: jira-sprint-card-intake
Sprint scope used: <current/open sprint | next/future sprint>

| Key | Status | Note | Handoff | Summary |
| --- | --- | --- | --- | --- |
| <KEY> | <status> | `<path>` | `<path>` | <summary> |

## Assumptions

- <Any sprint selection or Jira link inference assumptions.>

## Skipped Cards

- <KEY>: <reason, or "None">
```
