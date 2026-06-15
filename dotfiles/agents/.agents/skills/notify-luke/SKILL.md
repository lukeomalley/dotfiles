---
name: notify-luke
description: Send Luke a push notification via the `notify` command (ntfy to his iPhone). Use when a long-running task finishes, you need his input or a decision before continuing, you hit an error you cannot recover from, or you reach a milestone worth surfacing. Triggers include "notify me when done", "let me know when this finishes", "ping me", "text me when ready", or any request to be alerted.
---

# Notify Luke

Send Luke a push notification using the `notify` command. It POSTs to a
self-hosted ntfy server and delivers a push to his iPhone and any other
subscribed device.

## The command

`notify` is on `$PATH` (symlinked from his dotfiles).

```sh
notify "message"
notify -t "Title" -p high -g white_check_mark "message"
printf 'line one\nline two\n' | notify -t "Title"   # multi-line via stdin
```

### Flags

- `-t, --title` -- bold heading. Default: "Agent notification".
- `-p, --priority` -- `min` | `low` | `default` | `high` | `urgent`.
  Default is `default`. Reserve `urgent` for genuinely time-sensitive things;
  it bypasses Do Not Disturb.
- `-g, --tags` -- comma-separated emoji words, rendered as emoji on the
  notification. Common ones: `white_check_mark` (success), `warning` (caution),
  `rotating_light` (failure/alert), `hourglass` (waiting), `tada` (milestone).
  Full list: https://docs.ntfy.sh/emojis/

Run `notify --help` for the full reference.

## When to use it

Send a notification when:

- A long-running task finished, so Luke does not have to babysit it.
- You need Luke's input or a decision before you can continue.
- You hit an error or failure you could not recover from.
- You reached a milestone worth surfacing (deploy succeeded, large job done).

If Luke asks you to "notify me when done" (or similar), do exactly that: send
one `notify` call at the end with a clear summary of the outcome.

## How to write a good notification

- One notification per meaningful event. Do not spam. Bundle related info into
  a single message rather than firing several.
- Make the title and body self-contained. Luke reads it on his phone with no
  surrounding context, so include what finished and the result.
- Match priority to importance. Most things are `default`. Use `high` for
  failures or things needing attention. Reserve `urgent` for true emergencies.
- Pick a tag that signals the outcome at a glance (success vs failure).

Good:

```sh
notify -t "Test suite passed" -g white_check_mark "All 412 tests green on main. Safe to deploy."
notify -t "Build failed" -p high -g rotating_light "TypeScript errors in api/handlers.ts. Need your call on the type fix."
notify -t "Migration done" -g tada "Backfilled 1.2M rows in 14m. No errors."
```

Avoid:

```sh
notify "done"          # no context: done with what? what happened?
```

## Credentials and failures

The command reads its bearer token from `$NTFY_TOKEN` (set in Luke's shell via
1Password). Never print, log, or hard-code the token; just call `notify` and
let it read the environment.

If `notify` exits non-zero, report the failure to Luke rather than retrying
endlessly:

- `NTFY_TOKEN is not set` -- the secret did not load; tell Luke to reload his
  shell or run `update-secrets`.
- HTTP error (curl exit 22) -- 401 is bad/missing auth, 403 is a wrong token.
- connection error (curl exit 7) -- the ntfy server is unreachable.
