---
name: psci-create-jira-issue
description: Draft or create PSCI Jira issues from user input, light codebase analysis, and live Jira context through Atlassian TWG CLI. Use when the user asks to create Jira tickets, write Jira stories/tasks/bugs, or build an epic with linked child issues.
---

# PSCI Create Jira Issue

Create clear PSCI Jira work items that an engineer can pick up without guessing. Use the installed `twg` CLI for all Jira reads and writes. Read the `twg` and `twg-jira` skills for command discovery and Jira semantics. Keep the PSCI defaults and description template below. Do not fall back to another Jira client.

## Defaults

- Jira site: `https://procurementsciences.atlassian.net`.
- Project: ask if ambiguous. Use `DEV` (`Core Development`) when the request concerns engineering or product development.
- Board: `Win Team Development` (ID `499`). `All Teams Development` (ID `834`) is the cross-team DEV board, but it is not the default.
- Issue type: `Story` for user-facing behavior, `Task` for technical work, `Bug` for defects, and `Epic` for parent initiatives.
- Priority: `Medium`.
- Team: Win.
- Assignee: Luke, account ID `712020:4110baba-7778-4e0d-8549-12f13af9b21f` (`luke@procurementsciences.com`). Use this ID rather than `me`, which depends on the authenticated user.
- Sprint: the active sprint on the configured Win board. Resolve it immediately before creation. Never cache a sprint ID.
- Team field: `customfield_10001`, set by its field ID with the Win Team UUID below.
- Sprint field: `customfield_10020`. Assign after creation through `twg jira workitem update` with this field ID.

Cached team values:

| Team | Jira value | Team ID |
| --- | --- | --- |
| Win Team | Win | `cfd50fdb-9687-4f3d-9e7c-410bed9ef11f` |
| Find Team | Find | `f3f0c9fd-b5e8-4100-9439-58e715402e84` |
| Enterprise Team | Enterprise | `355be569-43d1-4029-a40f-ec7494225b5f` |

Use `--field 'customfield_10001=<team-id>'` when creating or editing an issue. Discover field metadata before writing; reuse these team IDs unless rejected or the user names another team.

Known assignee names and aliases:

| User input | Exact Jira display name |
| --- | --- |
| Luke | Luke O'Malley |
| Tyler, Hatch | Tyler Hatch |
| Kyle | Kyle Astroth |
| Jacob | Jacob Gahn |
| Ray, Poulton | Ray Poulton |
| Brandon Poe | Brandon Poe |
| Dallen Davis, Dallin Davis | Dallin Davis |

Default to Luke when the user does not name an owner. Resolve other owners to an Atlassian account ID with `twg user search`; pass that ID to `--assignee`. `Gon` is unresolved. Ask for the full name instead of guessing.

Apply Luke, Win, Medium, and the current active sprint to every created issue unless the user explicitly overrides a field or asks to leave it unset. Resolve all defaults before mutation. Do not silently create a ticket without one of these defaults.

## CLI Setup and Safety

Authentication uses TWG OAuth. No Jira API token or jira-cli config is needed. Confirm `twg --version` succeeds and perform a read against `--site procurementsciences.atlassian.net`. If the command is not on PATH, try `$HOME/.local/bin/twg`. If authentication or installation fails, report the setup problem; do not run login or setup unless authorized for that repair.

Use explicit site selection for every Jira command. Consult `twg help describe '<command path>'` before unfamiliar mutations. Prefer native Jira reads and field metadata; broader graph context is optional.

## Workflow

1. Parse the request into one issue, peer issues, or an epic with children.
2. Do light codebase analysis with `rg` and relevant file reads. Ground technical notes in the actual code.
3. Search related Jira work when it improves the draft.
4. Ask one concise clarification only when missing information materially changes the tickets. Otherwise label assumptions.
5. Draft first unless creation was explicitly requested. An explicit create request authorizes the mutation without another approval round.
6. Resolve all defaults and requested overrides before creation. Discover create metadata for each issue type.
7. Resolve the active sprint on board 499 immediately before creation. If the user names a future sprint, query future sprints and match the exact returned name and ID. If no unique match exists, ask before creating. Never reuse a sprint ID from a previous task.
8. Create one issue, read its state and update metadata, assign the resolved sprint, and verify its fields before creating the next issue. Create the epic first and pass its returned key as the parent for each child.
9. Stop on a failed create, assignment, or verification. Report any created keys. Never blindly retry a create after an ambiguous timeout; search for the existing record first.

## TWG Commands

Search related work with complete JQL, including ordering:

```sh
twg jira workitem query --site procurementsciences.atlassian.net \
  --jql 'project = DEV AND text ~ "search terms" ORDER BY updated DESC' \
  --fields summary,status,assignee --limit 20
```

Discover fields and the current sprint:

```sh
twg jira workitem field create-metadata --space DEV --type Story \
  --site procurementsciences.atlassian.net
twg jira board sprints query --board-id 499 --state active \
  --site procurementsciences.atlassian.net
```

Use `--state future` for a requested upcoming sprint. Require one matching sprint unless the user explicitly requests no sprint.

Create from a Markdown body file. Write the description to that file first; pass its contents as a single quoted argument or use a subprocess argument list. Do not interpolate ticket text into shell source.

```sh
twg jira workitem create --space DEV --type Story \
  --site procurementsciences.atlassian.net \
  --summary "$summary" --priority Medium \
  --assignee '712020:4110baba-7778-4e0d-8549-12f13af9b21f' \
  --field 'customfield_10001=cfd50fdb-9687-4f3d-9e7c-410bed9ef11f' \
  --description "$(cat "$body_file")" --description-format markdown --yes
```

Use `--type Epic` for the parent initiative and `--parent "$epic_key"` for its child stories/tasks. Add requested labels through `--labels`.

Before assigning the sprint, read the new issue and its editable fields:

```sh
twg jira workitem get "$issue_key" --fields parent,customfield_10001,customfield_10020 \
  --site procurementsciences.atlassian.net
twg jira workitem field update-metadata --id "$issue_key" \
  --site procurementsciences.atlassian.net
twg jira workitem update --id "$issue_key" \
  --field "customfield_10020=$sprint_id" --site procurementsciences.atlassian.net
```

Keep the sprint ID numeric. TWG 1.3.1 rejected a valid future sprint through its `--sprint` shortcut on this site, while direct `customfield_10020` assignment succeeded and persisted. Use the direct field path after confirming it is editable.

Verify the returned values:

```sh
twg jira workitem get "$issue_key" \
  --fields summary,issuetype,parent,assignee,priority,customfield_10001,customfield_10020,description \
  --site procurementsciences.atlassian.net
```

Check the actual Team ID, sprint ID, assignee account ID, priority, parent key, and description. Compact output may omit requested fields: inspect the referenced output file when needed. Descriptions are ADF documents. A single read and a batched read have different output shapes; inspect the envelope before parsing. Batch reads accept multiple keys.

For ordinary issue relationships, discover the supported link command and link types with live help. Parent relationships use `--parent`, not an ordinary issue link.

## Ticket Quality Bar

Each ticket must describe one coherent outcome. Include:

- A concise summary that names the user-visible outcome or technical deliverable.
- A short problem statement and intended outcome.
- User stories when user behavior is involved.
- Specific, testable acceptance criteria.
- Technical notes grounded in codebase analysis.
- Local file paths and external resources.
- Dependencies or sequencing when relevant.
- Only material open questions.

For bugs, include observed behavior, expected behavior, known reproduction steps, likely code paths, and criteria that prove the fix.

For epics, include the goal, non-goals, success criteria, child issues, and relevant rollout or migration notes.

## Description Format

TWG converts Markdown descriptions to Jira ADF when `--description-format markdown` is explicit. Its default is HTML. Use Markdown, not Jira wiki markup.

```markdown
Brief description of the work and outcome.

## User Stories
- As a [role], I want to [action], so that [benefit].

## Acceptance Criteria
- [Specific, measurable criterion]

## Technical Notes
- [Relevant implementation context]

## Resources
- path/to/file.ts - why it matters
- [External Doc](https://example.com)
```

Use `##` headings, ordinary Markdown lists, fenced code blocks, and Markdown links.

## Output Before Creation

For one issue, show issue type, summary, priority, team, sprint, assignee, and the full description.

For an epic and children, show the epic, numbered children with issue types, the parent-linking plan, and sprint assignment plan.

## Final Response After Creation

Report:

- Created issue keys and `https://procurementsciences.atlassian.net/browse/<key>` links.
- Epic-child relationships created.
- Sprint assignment.
- Team, priority, and assignee values applied.
- Any assumptions, skipped fields, or failed operations.
