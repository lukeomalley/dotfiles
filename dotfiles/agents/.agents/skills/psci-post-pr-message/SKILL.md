---
name: psci-post-pr-message
description: Post a PR announcement message to the #pr-review Slack channel using agent-browser with a fixed format (bold title line on top, blockquoted GitHub link, Jira link, team mentions, t-shirt size + diff stats). Use when the user asks to post a PR message, announce a PR in Slack, share a PR in pr-review, or mentions posting to #pr-review.
---

# Post PR Message to #pr-review

Posts a structured PR announcement in the `#pr-review` Slack channel using agent-browser over CDP. The first line is bold; the four detail lines sit inside a single blockquote block. Team mentions must resolve to actual Slack user groups (not plain text) and custom emojis must render as emojis (not literal `:name:` text).

## Exact Message Format

Five lines, in this order, no extra blank lines. The title line is **bold**; lines 2-5 are grouped inside a **single blockquote**:

```
*{TICKET} {type}: {short description}*
> :github:  {github_pr_url}
> :jira:  {jira_ticket_url}
> :eyes:  @{team1} @{team2}
> :shirt:  {size} +{additions}-{deletions}
```

Rendered example:

> *DEV-9694 fix: harden integration token refresher against transient failures*
> > :github:  https://github.com/procurement-sciences/chatbot-ui/pull/7089
> > :jira:  https://procurementsciences.atlassian.net/browse/DEV-9694
> > :eyes:  @team-win-engineers @team-aiml-engineers
> > :shirt:  Medium +403-132

Formatting rules:
- Two spaces after each emoji (`:github:  `, `:jira:  `, etc.)
- T-shirt sizes: XS, Small, Medium, Large, XL
- Diff stats come from `git diff --shortstat main...HEAD` or the PR's files-changed count
- Default team mentions: `@team-win-engineers` and `@team-aiml-engineers` (ask user to confirm or override)
- ASCII hyphen-minus only; never substitute an em dash

## Required Inputs

Gather these before posting. Ask the user for anything missing.

| Input | Example | How to infer |
|-------|---------|--------------|
| Ticket ID | `DEV-9694` | From branch name, PR title, or user |
| Commit type | `fix`, `feat`, `chore`, `refactor` (scope OK) | From PR title or commits |
| Description | `harden integration token refresher...` | From PR title |
| PR URL | `https://github.com/procurement-sciences/chatbot-ui/pull/7089` | `gh pr view --json url -q .url` |
| Jira URL | `https://procurementsciences.atlassian.net/browse/DEV-9694` | Build from ticket ID |
| Team mentions | `@team-win-engineers @team-aiml-engineers` | Default; confirm with user |
| T-shirt size | `Medium` | Ask user (judgment call) |
| Diff stats | `+403-132` | `git diff --shortstat main...HEAD` or `gh pr view --json additions,deletions` |

If the user just says "post a PR message", try to infer as much as possible from the current git branch and open PR, then confirm the full message before sending.

## Prerequisites

Slack must be running with CDP enabled on port `9222`:

```bash
curl -s http://localhost:9222/json/version | head -1
```

If that fails, relaunch Slack with the debugging flag (this closes the current Slack instance):

```bash
osascript -e 'quit app "Slack"' && sleep 2
open -a "Slack" --args --remote-debugging-port=9222
sleep 5
```

See the `electron` skill for details on Electron app CDP setup.

## Connecting agent-browser

**Always pass `--cdp 9222` on every command.** The `AGENT_BROWSER_CDP` env var is read inconsistently by the daemon -- if the daemon was started without it, a later `export` will be ignored and you'll get `about:blank`. `--cdp 9222` on the command line is the only reliable form. All example commands below omit it for readability; prefix every one.

**Do not use `agent-browser connect 9222`.** The `connect` subcommand reports "Done" but can leave the session attached to `about:blank` in some builds. `--cdp 9222` on each call is equivalent and more predictable.

### Preflight diagnostic (run this first, every time)

Before doing anything else, verify the full stack in one shot. This takes ~2 seconds and saves 10+ minutes of debugging later:

```bash
# 1. Slack is actually listening on 9222 with a real page target.
curl -s http://localhost:9222/json/list \
  | python3 -c "import sys,json;[print(t['type'],'|',t['title'][:60]) for t in json.load(sys.stdin)]"
# expect: a "page" row with your Slack workspace title
# if connection refused -> Slack isn't running with the debug flag; go to Prerequisites

# 2. agent-browser attaches to THAT target (not its own spawned Chrome).
agent-browser --cdp 9222 get title
# expect: your Slack window title (e.g. "pr-review (Channel) - ...")
# if "" or about:blank -> go to "Full reset" below

# 3. No rogue spawned Chrome.
pgrep -lf "agent-browser-chrome-" || echo "clean"
# expect: "clean"
# if it lists any Chrome PID -> agent-browser launched its own headless Chrome
# and is ignoring --cdp 9222; go to "Full reset"
```

If all three pass, skip to the Posting Workflow.

### Full reset (when `about:blank` won't go away)

`agent-browser close --all` alone is NOT always enough -- it closes the daemon's session state but can leave a spawned headless Chrome running, and the next daemon start will re-attach to its own Chrome instead of your Slack CDP port. The complete reset:

```bash
pkill -f "agent-browser"                      # kill the daemon
pkill -f "agent-browser-chrome-"              # kill any spawned headless Chrome
rm -f ~/.agent-browser/default.*              # clear daemon socket, pid, engine marker
sleep 2

# First call after reset sometimes exits 1 silently while the daemon initializes.
# Retry up to 3 times before giving up.
for i in 1 2 3; do
  if out=$(agent-browser --cdp 9222 tab list 2>&1); then
    echo "$out"
    break
  fi
  sleep 1
done
```

After this, re-run the preflight. You should see your Slack tab with a real URL.

## Posting Workflow

Follow these steps in order. Re-snapshot after every action that changes the UI.

### 1. Navigate to #pr-review

```bash
agent-browser press "Meta+k"
sleep 1
agent-browser snapshot -i | head -40          # find the Query combobox ref
agent-browser fill @<query-ref> "pr-review"
sleep 1
agent-browser press "Enter"
sleep 2
agent-browser snapshot -i | rg -i "pr-review|message to"   # find the composer ref, verify channel
```

Verify the channel header shows `#pr-review` before continuing.

### 2. Focus and clear the composer

Clicking the composer ref works sometimes but can miss (especially if a right-hand panel like a Slackbot DM is open). The reliable pattern is to focus via eval, then hard-clear with `execCommand`:

```bash
# focus the main composer (always index 0 in Slack's contenteditable list)
agent-browser eval 'document.querySelectorAll("[contenteditable=\"true\"]")[0]?.focus(); "ok"'

# hard-clear any draft or stray newlines
agent-browser eval '(() => { const el = document.querySelectorAll("[contenteditable=\"true\"]")[0]; el.focus(); document.execCommand("selectAll"); document.execCommand("delete"); return el.innerHTML; })()'
# expect: "<p><br></p>"
```

`Meta+a` + `Delete` often only partially clears Slack's composer (you'll see lingering `<p><br></p>` repeats). Prefer `execCommand`.

### 3. Type the message

Two critical gotchas:

1. **Use `keyboard type`, not `type`.** The `type` command requires a selector; without one, `agent-browser` reports `Element not found` silently. `keyboard type` sends real keystrokes to the focused element.
2. **Never chain multiple `@mentions` in a single `keyboard type` call.** When the mention popup opens on `@`, subsequent characters filter the popup instead of going to the composer -- characters from the second mention end up in the wrong order (you'll get `team-aiml-engineers@` as literal text). Handle mentions one at a time with explicit `sleep` and listbox verification between them.

Build the message line by line:

```bash
# line 1 - bold title (wrap in *...*; Slack auto-formats to <strong> on the closing *)
agent-browser keyboard type "*DEV-9694 fix: harden integration token refresher against transient failures*"
agent-browser press "Shift+Enter"

# enter blockquote mode BEFORE the emoji lines.
# typing bare ">" at line start does NOT work -- it's swallowed by Slack's
# emoji auto-replace when followed by " :name:". Use Slack's blockquote shortcut instead:
agent-browser press "Meta+Shift+9"
sleep 0.3

# line 2 - github link (blockquote mode is active; it persists across Shift+Enter)
agent-browser keyboard type ":github:  https://github.com/procurement-sciences/chatbot-ui/pull/7089"
agent-browser press "Shift+Enter"

# line 3 - jira link
agent-browser keyboard type ":jira:  https://procurementsciences.atlassian.net/browse/DEV-9694"
agent-browser press "Shift+Enter"

# line 4 - eyes emoji + first mention
agent-browser keyboard type ":eyes:  @team-win-engineers"
sleep 2
# verify the mention listbox picked the right group before confirming
agent-browser snapshot -i -s '[role="listbox"]'
# expect: option "Team Win Engineers, @team-win-engineers (N members)"
agent-browser press "Enter"
sleep 1

# second mention - type the space separately, then the handle
agent-browser keyboard type " "
sleep 0.3
agent-browser keyboard type "@team-aiml-engineers"
sleep 2
agent-browser snapshot -i -s '[role="listbox"]'
# expect: option "AI and ML Engineering Team, @team-aiml-engineers (N members)"
agent-browser press "Enter"
sleep 1

agent-browser press "Shift+Enter"

# line 5 - shirt
agent-browser keyboard type ":shirt:  Medium +403-132"
```

### 4. Verify before sending

Don't rely on full-page screenshots -- with `~/.agent-browser/config.json` set to `--force-device-scale-factor=0.8` they render too small to read. Verify structurally via `innerHTML`, then capture a composer-scoped screenshot for the user:

```bash
# structural check: should find 1 <strong>, 4 <blockquote>, 4 emoji <img>, 2 <ts-mention>
agent-browser eval '(() => {
  const el = document.querySelectorAll("[contenteditable=\"true\"]")[0];
  const html = el.innerHTML;
  return JSON.stringify({
    bold: (html.match(/<strong>/g) || []).length,
    quotes: (html.match(/<blockquote>/g) || []).length,
    emojis: (html.match(/class=\\\"emoji\\\"/g) || []).length,
    mentions: (html.match(/<ts-mention/g) || []).length,
  });
})()'
# expect: {"bold":1,"quotes":4,"emojis":4,"mentions":2}

# tight screenshot of just the composer (readable at 0.8 DPR)
agent-browser screenshot '[contenteditable="true"]' /tmp/pr-message-preview.png
```

Show the preview to the user and get explicit confirmation before pressing Enter.

If any count is off:
- `mentions` < 2 -> a mention posted as plain text. Backspace-deconstructing a mention chip turns it into malformed plain text (`@team-win-engineer@` with a trailing `@`). Safer to `execCommand("selectAll"); document.execCommand("delete")` and restart the typing flow.
- `emojis` < 4 -> the workspace may not have that custom emoji installed. Confirm with the user before sending.
- `quotes` < 4 -> you forgot `Meta+Shift+9` before line 2, or it fired too early. Clear and restart.
- `bold` != 1 -> the `*...*` wrapping didn't take (usually because the closing `*` was typed before the opening one registered). Clear and retype line 1.

### 5. Send

After the user confirms:

```bash
agent-browser press "Enter"
sleep 2
# verify the posted message landed (look for the shirt line at the bottom of the channel)
agent-browser snapshot -i | rg -iB 2 "XS|Small|Medium|Large|XL" | tail -15
```

## Common Pitfalls

**`connect 9222` vs `--cdp 9222`.** The `connect` subcommand attaches but creates its own `about:blank` context in some builds. Always use `--cdp 9222` on every command. The `AGENT_BROWSER_CDP` env var is read inconsistently and is not a substitute.

**Silent spawned Chrome.** If `--cdp 9222` still produces `about:blank` after `agent-browser close --all`, run `pgrep -lf "agent-browser-chrome-"`. If it returns any Chrome PID, agent-browser launched its own headless Chrome (visible as a process with `--headless=new --remote-debugging-port=0 --user-data-dir=/var/folders/.../agent-browser-chrome-...`) and is talking to that instead of your CDP port. The full reset (`pkill -f agent-browser && pkill -f agent-browser-chrome- && rm -f ~/.agent-browser/default.*`) is the only fix -- the standard `close --all` will not clear this state.

**First call after reset may need retries.** After a clean daemon reset, the first one or two `agent-browser --cdp 9222 ...` calls may exit 1 with empty output while the daemon initializes and attaches. Wrap the first invocation in a small retry loop (see Full reset above), or just run it twice.

**`type` vs `keyboard type`.** `agent-browser type "text"` without a selector fails silently with `Element not found`. Use `keyboard type` for focused-element typing.

**Double-send from `fill`.** `agent-browser fill` on Slack's composer appends rather than replacing. Never use `fill` for the composer; use `keyboard type` after an `execCommand("selectAll"); execCommand("delete")`.

**Chained mention typing.** Never put multiple `@handles` (or `@handle + more text`) in one `keyboard type` call. The autocomplete popup eats characters and they come out reordered. One mention per call, `sleep 2` for the popup, verify the listbox, then `Enter`.

**Plain `>` for blockquote.** `>` at line start gets swallowed by Slack's emoji replacement when followed by ` :emoji:`. Use `Meta+Shift+9` instead -- it enters a proper `<blockquote>` block that persists across `Shift+Enter`.

**Broken mention recovery.** Backspacing through a `<ts-mention>` chip doesn't produce clean plain text; you get garbled artifacts like `@team-win-engineer@`. Don't try to patch up a broken composer line by line -- hard-clear and restart.

**Plain Enter sends early.** In Slack's composer, `Enter` alone submits. Use `Shift+Enter` for line breaks inside the message. Only press bare `Enter` when ready to send.

**Wrong channel.** Always verify the channel header shows `#pr-review` before typing. The quick switcher can match multiple channels if more than one contains "pr-review".

**Em dash in PR titles.** Never substitute an em dash for a hyphen. Use ASCII `-` only.

## Minimal Prompt Shortcut

If the user invokes this skill with just a ticket ID (e.g. "post-pr-message DEV-9694"), try this inference chain before asking:

1. `gh pr view --json url,title,additions,deletions -q .` for PR URL, title, diff stats
2. Parse `{type}: {description}` from the PR title (keep any scope like `feat(web-scraper)`)
3. Build Jira URL as `https://procurementsciences.atlassian.net/browse/{TICKET}`
4. Default teams: `@team-win-engineers` and `@team-aiml-engineers`
5. Infer t-shirt size from total line changes (XS <50, Small <200, Medium <500, Large <1000, XL otherwise) and confirm with the user

Always show the final message for approval before sending.
