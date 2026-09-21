---
name: psci-work-jira-ticket
description: Work a PSCI Jira ticket end-to-end by creating a ticket-named branch, using subagents for ticket analysis, RPI research, RPI planning, and RPI implementation, then creating a pull request.
---

# PSCI Work Jira Ticket

You are the ticket orchestrator. Take a Jira ticket from request to pull request while keeping the user in the approval loop at the research and plan gates.

This skill is an explicit multi-agent workflow. Use subagents for the ticket analysis, research, planning, and implementation phases in the order below.

Use the installed `jira` CLI for all Jira reads. Do not use Atlassian or Jira MCP tools. Before Jira work, confirm `jira version` succeeds and `JIRA_API_TOKEN` is non-empty without printing it. In a non-interactive shell, source `~/.config/zsh/secrets.zsh` when needed. Stop if the CLI or token is unavailable.

## Phase 1: Resolve Ticket and Create Branch

This phase is done locally, not by a subagent.

1. Extract the Jira ticket key from the user request. Accept keys like `DEV-1234`.
2. If no key is present, search Jira from the user-provided description and ask the user to choose the ticket:

```bash
jira issue list -p DEV "<search terms>" \
  --order-by updated \
  --plain --no-headers \
  --columns KEY,SUMMARY,STATUS \
  --paginate 0:20
```

Do not put `ORDER BY` inside a `--jql` value. Use the CLI's `--order-by` flag.
3. Check for local git safety:

```bash
git status --short --branch
git remote -v
```

Stop if unrelated local changes would be overwritten or confused with the ticket work.

4. Create the work branch from latest `main`. The branch name must exactly match the ticket key, with no prefix:

```bash
git fetch origin
git checkout main
git pull --ff-only origin main
git checkout -b DEV-1234
```

If the branch already exists locally, switch to it after verifying it corresponds to the same ticket. If it exists remotely but not locally, check it out from origin.

## Phase 2: Ticket Intake Subagent

Spawn an `explorer` subagent to read the Jira ticket completely and produce a requirements brief.

The subagent must:

- Read the issue with `jira issue view <TICKET_KEY> --raw --comments 100`.
- Source `~/.config/zsh/secrets.zsh` first if `JIRA_API_TOKEN` is missing from its non-interactive shell. Never print the token.
- Use no Atlassian or Jira MCP tools.
- Read summary, description, rendered fields, comments, acceptance criteria, priority, labels, links, parent/epic, attachments metadata, and related development context when available.
- Identify the actual product/engineering requirement, out-of-scope items, ambiguities, and likely acceptance criteria.
- Confirm it is working on the branch named exactly like the ticket key.
- Make no code changes.

Prompt shape:

```text
Use the Jira ticket <TICKET_KEY> to produce a complete requirements brief for implementation.
You are not alone in the codebase. Do not modify files.
Confirm the current branch is <TICKET_KEY>.
Read the ticket with jira-cli, including raw fields and up to 100 comments. Do not use Jira MCP tools.
Return: summary, requirements, acceptance criteria, linked issues, risks, open questions, and implementation clues from the ticket.
```

Wait for this subagent before moving on. If the ticket is ambiguous, ask the user before research.

## Phase 3: RPI Research Subagent

Spawn an `explorer` subagent using the `rpi-research` skill.

The subagent must:

- Use the requirements brief from Phase 2.
- Research the current codebase only.
- Make no code changes.
- Confirm it is working on the branch named exactly like the ticket key.
- Save the research document under `~/rpi/<project-name>/research/` as required by `rpi-research`.
- Return the full research document path and a concise findings summary.

Prompt shape:

```text
Use the rpi-research skill.
Ticket: <TICKET_KEY>
Branch: <TICKET_KEY>
Requirements brief:
<brief>

Research the codebase for this ticket. Do not modify files. Save the research document and return its path.
```

After the subagent finishes, present the research summary and document path to the user. Ask for approval before planning.

## Phase 4: RPI Plan Subagent

After the user approves the research, spawn a `worker` or `explorer` subagent using the `rpi-plan` skill. Use `worker` only if the app requires workers for file-writing tasks, because `rpi-plan` writes a plan document but must not change product code.

The subagent must:

- Use the approved research document.
- Use the requirements brief from Phase 2.
- Confirm it is working on the branch named exactly like the ticket key.
- Create a plan document under `~/rpi/<project-name>/plans/` as required by `rpi-plan`.
- Ask any necessary clarifying questions through the parent if planning cannot proceed safely.
- Make no product code changes.
- Return the full plan document path and phase summary.

Prompt shape:

```text
Use the rpi-plan skill.
Ticket: <TICKET_KEY>
Branch: <TICKET_KEY>
Approved research document: <research-path>
Requirements brief:
<brief>

Create an implementation plan for this Jira ticket. Save the plan document and return its path.
```

After the subagent finishes, present the plan summary and document path to the user. Ask for approval before implementation.

## Phase 5: RPI Implement Subagent

After the user approves the plan, spawn a `worker` subagent using the `rpi-implement` skill.

The subagent must:

- Use the approved plan document.
- Confirm it is working on the branch named exactly like the ticket key.
- Implement the plan phase by phase.
- Update the plan document checkboxes as work is completed.
- Run the verification listed in the plan.
- Stop and return to the parent if the plan is wrong, verification fails in a non-obvious way, or scope changes are needed.
- Not commit, push, or create a pull request.

Prompt shape:

```text
Use the rpi-implement skill.
Ticket: <TICKET_KEY>
Branch: <TICKET_KEY>
Approved plan document: <plan-path>

Implement the plan. Do not commit, push, or create a pull request. Return changed files, verification results, and any follow-up notes.
```

When the implementation subagent completes, locally review:

```bash
git status --short
git diff --stat
git diff --name-status
```

Inspect relevant diffs enough to verify the implementation is coherent before releasing.

## Phase 6: Commit, Push, and Pull Request

Use the `psci-create-pull-request` skill for the release phase. That skill owns:

- Conventional commit message creation.
- Staging and committing changes.
- Pushing the ticket branch to origin.
- Creating the pull request with the team PR template, written for a reviewer who was not in this conversation.

Provide it with:

- Ticket key and Jira link.
- Ticket summary.
- The problem this change exists to solve, in product terms.
- Requirements brief.
- What is now true that was not true before.
- Verification results a human can repeat.
- Proof It Works: an ephemeral URL if one exists, and any screenshot, GIF, video, or terminal capture of the run.

Do not pass a files-changed list, the implementation plan, or phase-by-phase notes. The PR skill writes at product altitude and must not inventory paths or narrate the code. Do not create the PR with empty Proof It Works.

If `psci-create-pull-request` is unavailable, fall back to:

```bash
git status --short
git add -A
git commit -m "<conventional commit subject>" -m "<body>"
git push -u origin HEAD
gh pr create --base main --head <TICKET_KEY>
```

Never force push without explicit user approval. Never add AI attribution, co-author trailers, or tool watermarks.

## Final Response

Report:

- Ticket key and branch.
- Research document path.
- Plan document path.
- Implementation summary.
- Verification performed.
- Commit hash.
- PR URL.
- Any risks, skipped checks, or follow-up work.
