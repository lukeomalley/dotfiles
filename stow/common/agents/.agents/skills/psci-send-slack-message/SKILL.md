---
name: psci-send-slack-message
description: Send an arbitrary Slack message to any channel or person (DM, group DM, public/private channel) using agent-browser over CDP against the running Slack desktop app. Use when the user asks to send a Slack message, DM someone on Slack, post to a Slack channel, or message a person/group in Slack. For the specific PR-review announcement format, use psci-post-pr-message instead.
---

# Send Slack Message

Sends an arbitrary message to any Slack destination (channel, DM, group DM) using the Slack Electron app via Chrome DevTools Protocol. Reuses the same CDP + agent-browser stack as `psci-post-pr-message`, but generalized: the destination and message body are user-supplied.

## Required Inputs

Gather these before sending. Ask the user for anything missing.

| Input | Example | Notes |
|-------|---------|-------|
| Destination | `#pr-review`, `@luke`, `Alice Smith`, `proj-foo` | Channel name, user handle, or person's display name. Strip leading `#`/`@` when typing into Slack's quick switcher. |
| Message body | Free-form text, may include `*bold*`, `_italic_`, `` `code` ``, `:emoji:`, `@mentions`, links, multi-line | Plain Slack markdown. |
| Mentions inside body? | `@team-win-engineers`, `@alice` | Each `@mention` must be picked from the autocomplete listbox to render as a real mention chip, not literal text. |

If the user gives only the destination and message text, confirm both verbatim before sending. Always show a preview and get explicit approval before pressing Enter.

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

**Always pass `--cdp 9222` on every command.** The `AGENT_BROWSER_CDP` env var is read inconsistently by the daemon. `--cdp 9222` on the command line is the only reliable form. Example commands below omit it for readability; prefix every one.

**Do not use `agent-browser connect 9222`.** It can leave the session attached to `about:blank`. Use `--cdp 9222` on each call instead.

### Preflight diagnostic (run this first, every time)

```bash
# 1. Slack is actually listening on 9222 with a real page target.
curl -s http://localhost:9222/json/list \
  | python3 -c "import sys,json;[print(t['type'],'|',t['title'][:60]) for t in json.load(sys.stdin)]"
# expect: a "page" row with your Slack workspace title

# 2. agent-browser attaches to THAT target.
agent-browser --cdp 9222 get title
# expect: your Slack window title

# 3. No rogue spawned Chrome.
pgrep -lf "agent-browser-chrome-" || echo "clean"
# expect: "clean"
```

If any check fails, see the "Full reset" section in the `psci-post-pr-message` skill -- the recovery procedure is identical.

## Sending Workflow

Follow these steps in order. Re-snapshot after every action that changes the UI.

### 1. Open the quick switcher and navigate to the destination

```bash
agent-browser press "Meta+k"
sleep 1
agent-browser snapshot -i | head -40          # find the Query combobox ref
agent-browser fill @<query-ref> "<destination>"   # e.g. "pr-review", "luke", "Alice Smith"
sleep 1
agent-browser press "Enter"
sleep 2
agent-browser snapshot -i | rg -i "<destination>|message to"
```

Verify the channel/DM header matches the intended destination before continuing. The quick switcher can match multiple results; if the wrong one is selected, re-open with `Meta+k` and refine the query (e.g. include the workspace prefix or a more specific term).

### 2. Focus and clear the composer

```bash
# focus the main composer (always index 0 in Slack's contenteditable list)
agent-browser eval 'document.querySelectorAll("[contenteditable=\"true\"]")[0]?.focus(); "ok"'

# hard-clear any draft or stray newlines
agent-browser eval '(() => { const el = document.querySelectorAll("[contenteditable=\"true\"]")[0]; el.focus(); document.execCommand("selectAll"); document.execCommand("delete"); return el.innerHTML; })()'
# expect: "<p><br></p>"
```

`Meta+a` + `Delete` often only partially clears Slack's composer. Prefer `execCommand`.

### 3. Type the message

Two critical rules:

1. **Use `keyboard type`, not `type`.** `type` without a selector fails silently.
2. **Never chain multiple `@mentions` in one `keyboard type` call.** Once the mention popup opens on `@`, subsequent characters filter the popup instead of going to the composer. Handle mentions one at a time.

#### Plain single-line message

```bash
agent-browser keyboard type "Hey team, deploy is starting in 5 minutes."
```

#### Multi-line message

Use `Shift+Enter` for newlines (bare `Enter` sends in Slack):

```bash
agent-browser keyboard type "First line of the message"
agent-browser press "Shift+Enter"
agent-browser keyboard type "Second line"
agent-browser press "Shift+Enter"
agent-browser press "Shift+Enter"   # blank line
agent-browser keyboard type "Third paragraph"
```

#### Bold / italic / code / blockquote

Slack auto-formats inline markdown as you type:
- `*bold*` -> **bold** (the closing `*` triggers the conversion)
- `_italic_` -> _italic_
- `` `code` `` -> inline code
- Triple backticks on their own line -> code block (use `Shift+Enter` to enter, type fenced content, then `Shift+Enter` to exit)
- For a blockquote block, press `Meta+Shift+9` before the line. Do not type a literal `>` -- it gets swallowed by Slack's emoji replacement when followed by ` :name:`.

#### Mentions (one at a time)

For each `@mention` in the body, break the typing into: text-before, then the mention, then continue:

```bash
agent-browser keyboard type "Heads up "
agent-browser keyboard type "@alice"
sleep 2
agent-browser snapshot -i -s '[role="listbox"]'
# expect: the intended user/group as the top option. If not, type more characters to narrow.
agent-browser press "Enter"
sleep 1
agent-browser keyboard type " can you take a look?"
```

If the message has multiple mentions, repeat the same pattern for each one. Type any separators (spaces, punctuation) in a separate `keyboard type` call after the mention is confirmed.

#### Custom emojis

Type `:emoji-name:` and Slack will replace it with the rendered emoji on the trailing `:`. If the workspace doesn't have a custom emoji installed, it stays as literal text -- confirm with the user before sending.

### 4. Verify before sending

```bash
# structural sanity check (counts will vary by message)
agent-browser eval '(() => {
  const el = document.querySelectorAll("[contenteditable=\"true\"]")[0];
  const html = el.innerHTML;
  return JSON.stringify({
    text: el.innerText,
    bold: (html.match(/<strong>/g) || []).length,
    quotes: (html.match(/<blockquote>/g) || []).length,
    emojis: (html.match(/class=\\\"emoji\\\"/g) || []).length,
    mentions: (html.match(/<ts-mention/g) || []).length,
    codeBlocks: (html.match(/<pre>/g) || []).length,
  });
})()'

# tight screenshot of just the composer
agent-browser screenshot '[contenteditable="true"]' /tmp/slack-message-preview.png
```

Compare `text` and the structural counts against what the user asked for. Show the preview screenshot and get explicit confirmation before sending.

If mentions came out as plain text (`mentions` count is lower than expected), don't try to backspace-fix individual chips -- the artifacts are messy. Hard-clear with `execCommand("selectAll"); execCommand("delete")` and restart typing.

### 5. Send

After the user confirms:

```bash
agent-browser press "Enter"
sleep 2
# verify the posted message landed
agent-browser snapshot -i | tail -30
```

## Common Pitfalls

**Wrong destination.** Always verify the channel/DM header after the quick switcher lands. The switcher can match multiple results; refine the query if the wrong one is selected. For DMs to people with common names, prefer the full display name or username.

**`type` vs `keyboard type`.** `agent-browser type "text"` without a selector fails silently with `Element not found`. Use `keyboard type` for focused-element typing.

**Double-send from `fill`.** `agent-browser fill` on Slack's composer appends rather than replacing. Never use `fill` for the composer body; use `keyboard type` after an `execCommand` clear.

**Chained mention typing.** Never put multiple `@handles` (or `@handle + more text`) in one `keyboard type` call. The autocomplete popup eats characters and reorders them. One mention per call, `sleep 2` for the popup, verify the listbox, then `Enter`.

**Plain Enter sends early.** In Slack's composer, `Enter` alone submits. Use `Shift+Enter` for line breaks inside the message. Only press bare `Enter` when ready to send.

**Plain `>` for blockquote.** `>` at line start gets swallowed by Slack's emoji replacement when followed by ` :emoji:`. Use `Meta+Shift+9` instead.

**Broken mention recovery.** Backspacing through a `<ts-mention>` chip produces garbled plain text. Hard-clear and restart instead of patching.

**Em dashes.** If the user's message contains em dashes, ask whether to keep them or substitute ASCII hyphens. Never silently substitute either direction.

**`connect 9222` vs `--cdp 9222`.** Always use `--cdp 9222` on every call. See `psci-post-pr-message` for the full reset procedure if `about:blank` keeps appearing.

## When to Use a Different Skill

- **PR announcement in `#pr-review`** with the standard bold-title + blockquoted-link format -> use `psci-post-pr-message` instead. That skill has the exact format, default team mentions, and inference chain for PR metadata.
- **General Slack browsing / reading unreads / searching** -> use the `slack` skill.
