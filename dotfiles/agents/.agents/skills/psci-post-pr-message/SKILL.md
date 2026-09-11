---
name: psci-post-pr-message
description: "Post a PR announcement message to the #pr-review Slack channel with a fixed format (bold title line on top, blockquoted GitHub link, Jira link, team mentions, t-shirt size + diff stats). Ships a script that composes, verifies, and sends the message through the running Slack desktop app in a few seconds. Use when the user asks to post a PR message, announce a PR in Slack, share a PR in pr-review, or mentions posting to #pr-review."
---

# Post PR Message to #pr-review

Posts a structured PR announcement in `#pr-review`. All the browser work is done by
`scripts/post-pr-message.sh`, which drives the Slack desktop app over CDP with
agent-browser and refuses to send unless the composed message has the exact
expected structure (1 bold line, 4 blockquote lines, 4 rendered emojis, one real
mention chip per team). Do not hand-drive agent-browser for this task unless the
script fails and you are debugging why.

## Exact Message Format

```
*{TICKET} {type}: {short description}*
> :github:  {github_pr_url}
> :jira:  {jira_ticket_url}
> :eyes:  @{group or person} [@{group or person} ...]
> :shirt:  {size} +{additions}-{deletions}
```

Rendered example:

> *DEV-9694 fix: harden integration token refresher against transient failures*
> > :github:  https://github.com/procurement-sciences/chatbot-ui/pull/7089
> > :jira:  https://procurementsciences.atlassian.net/browse/DEV-9694
> > :eyes:  @team-win-engineers
> > :shirt:  Medium +403-132

Rules the script enforces:
- Two spaces after each emoji
- T-shirt sizes: XS, Small, Medium, Large, XL (derived from total changed lines when not given: XS <50, Small <200, Medium <500, Large <1000, XL otherwise)
- ASCII hyphen-minus only; the script rejects em/en dashes in any field
- Default mention: `@team-win-engineers`. The old `@team-aiml-engineers` user group no longer exists in the workspace (checked 2026-09-04). Any other group or person can be tagged; nothing is hardcoded, see Mentions below.

## Workflow

The script lives at `scripts/post-pr-message.sh` next to this file. Resolve its
path from the skill directory (for example `~/.agents/skills/psci-post-pr-message/scripts/post-pr-message.sh`).

### 1. Build and show the message (no browser)

From the repo with the PR checked out:

```bash
post-pr-message.sh --infer --print
```

`--infer` fills the PR URL, title, diff stats, and ticket from `gh pr view` and
the branch name, parses `<type>[(scope)]: <desc>` from the title, builds the Jira
URL, and derives the size. Override anything with explicit flags:

```
--ticket DEV-9694  --type fix  --desc "..."  --pr-url URL  --jira-url URL
--teams team-win-engineers,team-data  --people "Ray Poulton,Ben Stoker"
--size Medium  --stats +403-132  --title "raw PR title"  --pr 7089
```

### Mentions

Groups go in `--teams` (handles, comma or space separated, `@` optional). People
go in `--people` (comma separated, names may contain spaces). Pass `--teams ""`
to tag no group. Every entry is resolved live against Slack's autocomplete, so new
groups and people work without touching the script:

- A group matches by handle (`team-data`) or display name (`Data Team`).
- A person matches by full name as Slack shows it (`Ray Poulton`) or by display
  handle when they have one (`Ben Stoker` for Benjamin Stoker).
- A partial name is accepted only if it narrows the popup to exactly one person,
  and the script logs which one it picked. `Ben` alone fails because several
  people match; `Stoker` succeeds.
- Anything that does not resolve makes the script exit 4 with the options Slack
  offered, leaving the draft in the composer. It never posts a plain-text `@name`.

If the user names someone in a form the script rejects, rerun with the name
exactly as it appears in Slack rather than guessing.

Show the printed message to the user. Ask them to confirm the t-shirt size and
the team mentions (size is a judgment call; the derived value is only a default).

### 2. Send

After the user approves, rerun the same flags with `--send`:

```bash
post-pr-message.sh --infer --size Medium --send
```

This navigates to `#pr-review`, clears the composer, types the message with the
right Slack shortcuts, waits for each mention to resolve in the autocomplete
popup, checks the structure, writes a composer screenshot to
`/tmp/pr-message-preview.png`, presses Enter, and confirms the composer emptied.
Total time is a few seconds. Exit code 0 means it posted.

If the user wants to see the rendered message before it goes out, run without
`--send` first. That leaves the message as a draft in the composer and writes
the screenshot; show it, then run `--send` (which re-composes from scratch).

### Other actions

```bash
post-pr-message.sh --clear                 # wipe whatever is in the #pr-review composer
post-pr-message.sh ... --json              # machine-readable summary on stdout
post-pr-message.sh ... --reset             # full agent-browser daemon reset first
post-pr-message.sh ... --relaunch-slack    # quit + relaunch Slack with the CDP flag if it is not listening
post-pr-message.sh ... --allow-missing-emoji
post-pr-message.sh ... --channel NAME --channel-id C0XXXX   # different destination
```

Exit codes: 1 usage or missing fields, 2 Slack/agent-browser preflight, 3 could
not navigate, 4 structure mismatch (draft left in place for inspection), 5 Enter
was pressed but the composer did not empty.

## Prerequisites

Slack must be running with CDP enabled on port `9222`:

```bash
curl -s http://localhost:9222/json/version | head -1
```

If that fails, either pass `--relaunch-slack` or do it by hand (this closes the
current Slack instance):

```bash
osascript -e 'quit app "Slack"' && sleep 2
open -a "Slack" --args --remote-debugging-port=9222
sleep 5
```

The script also resets agent-browser automatically when it detects it is not
attached to Slack (empty or `about:blank` title, or a rogue spawned Chrome).

## Troubleshooting

**Exit 4 with `mention autocomplete never offered 'X'`.** The group or person does
not exist under that name, or the name is ambiguous. The error lists what Slack
offered; pick the exact label from that list and rerun with `--teams`/`--people`.
Do not try to send a plain-text mention.

**Exit 4 with `emojis=N (want 4)`.** A custom emoji (`:github:` or `:jira:`) is
not installed in the workspace. Confirm with the user; `--allow-missing-emoji`
sends anyway with literal text.

**Exit 3 (navigation).** `#pr-review` is not in the sidebar and the quick
switcher did not open. Pass `--channel-id C04KP0TJWSD` (the pr-review
conversation id as of 2026-09-04) or open the channel in Slack and rerun.

**Exit 2 and `about:blank` will not go away.** The full reset the script runs:

```bash
pkill -f "agent-browser"; pkill -f "agent-browser-chrome-"
rm -f ~/.agent-browser/default.*
sleep 2
agent-browser --cdp 9222 tab list    # may need 2-3 tries while the daemon starts
```

## Manual fallback (only if the script is broken)

Everything below is what the script does; keep it in sync if you change either.

- Always pass `--cdp 9222` on every agent-browser call. Never `connect 9222`; the env var is read inconsistently.
- Navigate by real click on the sidebar entry: `agent-browser --cdp 9222 click '[data-qa="channel_sidebar_name_pr-review"]'`. JS `.click()` does nothing (React handlers), and `Meta+k` is ignored when the composer holds focus or the window is not frontmost.
- Verify the destination through the composer's `aria-label` (`Message to pr-review`), not a snapshot.
- Clear with `execCommand("selectAll"); execCommand("delete")` on `document.querySelectorAll('[contenteditable="true"]')[0]`; `Meta+a` + Delete leaves fragments.
- Type with `keyboard type` (real keystrokes). `type` without a selector fails silently; `fill` appends.
- `Shift+Enter` for newlines. Bare `Enter` sends.
- `Meta+Shift+9` to enter blockquote mode before line 2; a literal `>` is eaten by emoji auto-replace. The blockquote persists across `Shift+Enter`.
- One `@mention` at a time, one word per `keyboard type` call with a pause between words (Slack drops the popup if a multi-word name arrives in one burst). Poll `[role="listbox"] [role="option"]` and match on `aria-label`: groups look like `Team Win Engineers, @team-win-engineers (4 members)`, people like `Ray Poulton (not in channel)` or `Benjamin Stoker, @Ben Stoker (away), ...`. Click the matching option by its `#tab_complete_ui_item_N` id rather than trusting Enter. Slack inserts a space after the chip; only type a separator if it did not.
- Verify with counts on `innerHTML`: `<strong>` 1, `<blockquote>` 4, `class="emoji"` 4, `<ts-mention` one per team. Never backspace through a broken mention chip; clear and restart.
- Element screenshots land at the wrong offset because Slack renders at a non-1 devicePixelRatio. Take a full screenshot and crop to `[data-qa="message_input"]`'s bounding box scaled by `pixelWidth / window.innerWidth`.
