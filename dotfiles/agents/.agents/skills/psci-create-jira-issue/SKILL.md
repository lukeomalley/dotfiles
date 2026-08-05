---
name: psci-create-jira-issue
description: Draft or create PSCI Jira issues from user input, light codebase analysis, and Jira context. Use when the user asks to create Jira tickets, write Jira stories/tasks/bugs, or build an epic with linked child issues.
---

# PSCI Create Jira Issue

You are a senior engineer and product partner creating clear, actionable PSCI Jira work items. Turn user input plus light codebase analysis into tickets that an engineer can pick up without guessing.

## Defaults

- Default Jira cloud: `829222e9-6269-4863-aac3-8aa9b1487e5f` (`procurementsciences.atlassian.net`).
- Default project: ask if ambiguous. Use `DEV` (`Core Development`, project ID `10007`) when the user implies engineering/product development work or existing context clearly points there.
- Default issue type: `Story` for user-facing behavior, `Task` for technical work, `Bug` for defects, `Epic` for parent initiatives.
- Default priority: `Medium`.
- Default team: Win.
- Default sprint: the current active DEV sprint. Resolve it at creation time, never from a cached sprint ID.
- Team field: `customfield_10001`.
- Sprint field: `customfield_10020`.
- Priority field: `priority`; Medium priority ID is `3`.

Cached team IDs:

| Team | Jira value title | Team ID |
| --- | --- | --- |
| Win Team | Win | `cfd50fdb-9687-4f3d-9e7c-410bed9ef11f` |
| Find Team | Find | `f3f0c9fd-b5e8-4100-9439-58e715402e84` |
| Enterprise Team | Enterprise | `355be569-43d1-4029-a40f-ec7494225b5f` |

Cached Win Team Jira account IDs:

| Person / aliases | Jira display name | Account ID |
| --- | --- | --- |
| Luke | Luke O'Malley | `712020:4110baba-7778-4e0d-8549-12f13af9b21f` |
| Tyler, Hatch | Tyler Hatch | `712020:23fb2ab7-5279-4e63-acc8-2f113d68b446` |
| Kyle | Kyle Astroth | `712020:bd623435-a68c-4efe-a27a-c9edf9310004` |
| Jacob | Jacob Gahn | `712020:54fa1af6-34ac-4ec2-a86c-d93356f0220b` |
| Ray, Poulton | Ray Poulton | `712020:00dc138e-5782-494f-a831-826aed30390b` |
| Brandon Poe | Brandon Poe | `712020:90fe515a-cced-461b-948a-f8ed369a333a` |
| Dallen Davis, Dallin Davis | Dallin Davis | `712020:92f2b3f9-6284-4632-896f-129149ca5ef8` |

Unresolved roster alias:

- `Gon`: Jira lookup for `Gon`, `Gonzalo`, and `Goncalves` returned no account. Do not guess. Ask for the full name before assigning.

Do not query Jira for the cached teams or users above unless a create/update fails or the user clearly wants a different person/team.

Default `additional_fields` for created issues:

```json
{
  "priority": { "name": "Medium" },
  "customfield_10001": "cfd50fdb-9687-4f3d-9e7c-410bed9ef11f"
}
```

If the user names Find Team or Enterprise Team, use the cached team IDs above. If the user names another team, use Jira/MCP lookup before changing the Team field.

Default assignee behavior:

- Leave assignee unset unless the user names an owner.
- If the user names one of the cached Win Team people, set `assignee_account_id` from the table above.
- If the user only says `Tyler` or `Hatch`, use Tyler Hatch for Win Team work.
- If the user says `Ray` or `Poulton`, use Ray Poulton.
- If the user says `Dallen Davis`, use the Jira account for `Dallin Davis`.

## Workflow

1. Parse the request into desired issue shape: single issue, multiple peer issues, or epic plus children.
2. Do light codebase analysis before drafting:
   - Search for relevant terms, routes, components, services, tests, configs, and docs with `rg`.
   - Read only the files needed to understand the work.
   - Identify likely impacted areas and useful file references.
3. Search Jira for related context when useful:
   - Existing similar tickets.
   - Relevant epics.
   - Current active sprint when creating issues.
4. Ask at most one concise clarification when missing information would materially change the tickets. Otherwise make a reasonable assumption and label it.
5. Draft tickets first unless the user explicitly asked to create them immediately.
6. Before creating or updating Jira issues, get explicit user approval unless the user already clearly asked to create the tickets in Jira.

## Jira MCP Usage

Use the Atlassian MCP tools when available.

Useful tools:

- `jira_search_fields` to confirm field IDs.
- `jira_get_agile_boards` to find boards.
- `jira_get_sprints_from_board` to find active or future sprints.
- `jira_create_issue` for one issue.
- `jira_batch_create_issues` for multiple issues.
- `jira_link_to_epic` to link children to an epic after creation.
- `jira_create_issue_link` for related/blocking links.
- `jira_add_issues_to_sprint` to assign created issues to a sprint.

Sprint handling:

- Do not hard-code a sprint ID.
- The current active DEV sprint is usually visible on board `8` in `customfield_10020`.
- Find the active sprint at ticket creation time.
- If `jira_get_sprints_from_board` is available, call it for board `8` with active sprints and use the active sprint ID.
- If only the Atlassian Rovo MCP tools are available, run this command and read the active sprint object from `customfield_10020`:

```json
{
  "tool": "mcp__codex_apps__atlassian_rovo._searchjiraissuesusingjql",
  "arguments": {
    "cloudId": "829222e9-6269-4863-aac3-8aa9b1487e5f",
    "jql": "project = DEV AND Sprint in openSprints() ORDER BY updated DESC",
    "fields": ["summary", "customfield_10001", "customfield_10020"],
    "maxResults": 50
  }
}
```

- Prefer an issue whose `customfield_10001.id` matches the selected team, then use the sprint object in `customfield_10020` where `state` is `active`.
- As of 2026-07-08, that command returned active sprint `313`, `2026.Q3.S1 - Croissant`, board `8`, start `2026-06-29T18:49:35.139Z`, end `2026-07-13T06:00:00.000Z`. This is an example only, not a value to hard-code.
- If the user asks for a named or future sprint, search board `8` future and active sprints.
- After creating issues, call `jira_add_issues_to_sprint` with the chosen sprint ID and comma-separated issue keys.
- If `jira_add_issues_to_sprint` is unavailable, set `customfield_10020` in `additional_fields` during create using the resolved active sprint ID.
- If no active sprint is found, leave sprint unset and report that.

Epic handling:

- Create the `Epic` first.
- Create children as `Story`, `Task`, or `Bug`.
- Link each child with `jira_link_to_epic`.
- If creating subtasks, use issue type `Subtask` with `additional_fields` parent set to the parent key.

## Ticket Quality Bar

Each ticket should be scoped to one coherent outcome. Avoid vague implementation buckets like "update backend" unless the surrounding context makes the deliverable precise.

Include:

- A concise summary that names the user-visible outcome or technical deliverable.
- A brief description of the problem and intended outcome.
- User stories when user behavior is involved.
- Acceptance criteria that are testable and specific.
- Technical notes from codebase analysis.
- Resources with local file paths and external links.
- Dependencies or sequencing notes when relevant.
- Open questions only when they matter.

For bugs, include:

- Observed behavior.
- Expected behavior.
- Reproduction notes if known.
- Likely impacted code paths.
- Acceptance criteria that prove the fix.

For epics, include:

- Goal and non-goals.
- Success criteria.
- Suggested child issues.
- Rollout or migration considerations when relevant.

## Description Format

**Always write Jira issue descriptions in Markdown** when calling the MCP `jira_create_issue` / `jira_update_issue` tools. Never write Jira wiki markup (`h3.`, `*bold*`, `{{code}}`) directly into the description field. The tool converts Markdown to wiki markup automatically; passing wiki markup produces literal, unrendered text like `h3.` in the ticket.

Description template (Markdown):

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

Markdown rules:

- Section headings: `## Section Name`. The converter maps `##` to Jira `h2.`; there is no reliable Markdown path to force `h3.`, so standardize on `##` for all section headings.
- Bold: `**bold**`
- Italic: `_italic_`
- Inline code: backtick-wrapped `` `code` ``
- Code blocks: triple-backtick fenced blocks.
- Unordered list: `- item`
- Ordered list: `1. item`
- Nested list: two-space indent under the parent item.
- Local file references: plain path plus a short reason.
- External links: `[Label](https://example.com)`

The wiki markup (`h2.`, `*bold*`, `{{code}}`) is only what the tool produces under the hood from your Markdown; never author it yourself.

The same rule applies to Confluence page creation via the MCP (`confluence_create_page` with `content_format: 'markdown'`) -- write Markdown, not storage/wiki format, unless explicitly using a different `content_format`.

## Output Shape Before Creation

For a single issue:

```text
Issue type: Story
Summary: ...
Priority: Medium
Team: Win
Sprint: Current active DEV sprint, if found

Description:
...
```

For an epic plus children:

```text
Epic
- Summary: ...
- Description: ...

Children
1. [Story] Summary...
2. [Task] Summary...
3. [Bug] Summary...

Linking plan:
- Link all children to the created epic.
- Add selected issues to the current active sprint unless the user asks to leave sprint unset.
```

## Final Response After Creation

Report:

- Created issue keys and links.
- Epic-child links created.
- Sprint assignment, if any.
- Team and priority applied.
- Any assumptions or skipped fields.
