---
name: psci-create-jira-issue
description: Draft or create PSCI Jira issues from user input, light codebase analysis, and live Jira context through jira-cli. Use when the user asks to create Jira tickets, write Jira stories/tasks/bugs, or build an epic with linked child issues.
---

# PSCI Create Jira Issue

Create clear PSCI Jira work items that an engineer can pick up without guessing. Use the installed `jira` CLI for all Jira reads and writes. Do not use Atlassian or Jira MCP tools.

## Defaults

- Jira site: `https://procurementsciences.atlassian.net`.
- Project: ask if ambiguous. Use `DEV` (`Core Development`) when the request concerns engineering or product development.
- Board: `Win Team Development` (ID `499`). `All Teams Development` (ID `834`) is the cross-team DEV board, but it is not the default.
- Issue type: `Story` for user-facing behavior, `Task` for technical work, `Bug` for defects, and `Epic` for parent initiatives.
- Priority: `Medium`.
- Team: Win.
- Assignee: Luke, using `luke@procurementsciences.com` or the live value from `jira me`.
- Sprint: the active sprint on the configured Win board. Resolve it immediately before creation. Never cache a sprint ID.
- Team field: `customfield_10001`, exposed by jira-cli as the custom key `team`.
- Sprint field: `customfield_10020`. Assign sprints with `jira sprint add`, not the custom-field flag.

Cached team values:

| Team | Jira value | Team ID |
| --- | --- | --- |
| Win Team | Win | `cfd50fdb-9687-4f3d-9e7c-410bed9ef11f` |
| Find Team | Find | `f3f0c9fd-b5e8-4100-9439-58e715402e84` |
| Enterprise Team | Enterprise | `355be569-43d1-4029-a40f-ec7494225b5f` |

Use `--custom team=<team-id>` when creating or editing an issue. Do not query Jira again for a cached team unless the command fails or the user names another team.

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

Default to Luke when the user does not name an owner. Pass an exact Jira display name or email to `--assignee`. `Gon` is unresolved. Ask for the full name instead of guessing.

Apply Luke, Win, Medium, and the current active sprint to every created issue unless the user explicitly overrides a field or asks to leave it unset. Resolve all defaults before mutation. Do not silently create a ticket without one of these defaults.

## CLI Setup and Safety

The tracked config is `~/.config/.jira/.config.yml`. Authentication comes from `JIRA_API_TOKEN`, generated from the dotfiles 1Password template. Never print the token, place it in an argument, or write it to a ticket body or tracked file.

Before Jira work:

1. Confirm `jira version` succeeds.
2. Confirm `JIRA_API_TOKEN` is non-empty without printing it. In a non-interactive shell, source `~/.config/zsh/secrets.zsh` first when needed.
3. If the CLI or token is missing, stop and report the setup problem. Do not fall back to MCP.

Prefer non-interactive commands and machine-readable output. Use `--raw` for issue reads and creates when JSON is useful. Use `--plain --no-headers` with explicit columns for stable tabular output.

## Workflow

1. Parse the request into one issue, peer issues, or an epic with children.
2. Do light codebase analysis:
   - Search relevant terms, routes, components, services, tests, configs, and docs with `rg`.
   - Read only the files needed to understand the work.
   - Record likely impacted areas and useful file references.
3. Search Jira when related issues, epics, assignees, or current sprint context would improve the draft.
4. Ask at most one concise clarification when missing information would materially change the tickets. Otherwise make a labeled assumption.
5. Draft tickets first unless the user explicitly asked to create them immediately.
6. Before any Jira mutation, get explicit approval unless the user already clearly asked for that mutation.
7. Resolve the active sprint and all requested field values before the first create.
8. After each create, add that issue to the resolved sprint, then verify the issue with `jira issue view <key> --raw`.

## Jira CLI Commands

Search for related work:

```sh
jira issue list -p DEV \
  --jql 'project = DEV AND text ~ "search terms"' \
  --order-by updated \
  --raw
```

Do not put `ORDER BY` inside `--jql`. jira-cli appends ordering from `--order-by`, and using both produces invalid JQL.

Resolve the active sprint on the configured Win board:

```sh
jira sprint list -p DEV \
  --state active \
  --table --plain --no-headers \
  --columns ID,NAME,STATE
```

Use the single active sprint ID. If none or several are returned, do not guess and do not create the issue. Ask the user to resolve the sprint unless they explicitly requested no sprint.

Create an issue with a Markdown description supplied through stdin:

```sh
jira issue create -p DEV \
  --type Story \
  --summary "$summary" \
  --priority Medium \
  --assignee luke@procurementsciences.com \
  --custom team=cfd50fdb-9687-4f3d-9e7c-410bed9ef11f \
  --no-input \
  --raw \
  --template -
```

Pipe the complete description to that command. Replace the assignee, team, priority, or sprint only when the user requests an override. Do not place a multiline description directly in `--body`.

Create an epic first, then attach each child during creation:

```sh
jira issue create -p DEV --type Epic --summary "$summary" --priority Medium \
  --assignee luke@procurementsciences.com \
  --custom team=cfd50fdb-9687-4f3d-9e7c-410bed9ef11f \
  --no-input --raw --template -

jira issue create -p DEV --type Story --parent "$epic_key" \
  --summary "$child_summary" --priority Medium \
  --assignee luke@procurementsciences.com \
  --custom team=cfd50fdb-9687-4f3d-9e7c-410bed9ef11f \
  --no-input --raw --template -
```

Immediately assign each created issue to the resolved sprint:

```sh
jira sprint add "$sprint_id" DEV-123
```

Create ordinary issue relationships when needed:

```sh
jira issue link DEV-123 DEV-124 Blocks
```

For multiple issues, create them sequentially. Add each returned key to the sprint and verify its defaults before creating the next issue. jira-cli has no batch-create command. Stop on the first failed create, sprint assignment, or verification instead of continuing with an incomplete hierarchy. Report any issue that was created before the failure.

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

jira-cli accepts GitHub-flavored Markdown and converts it for Jira Cloud. Use Markdown, not Jira wiki markup.

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
