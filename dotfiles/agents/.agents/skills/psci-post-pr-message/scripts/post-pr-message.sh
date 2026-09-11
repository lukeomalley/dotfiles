#!/usr/bin/env bash
# Compose (and optionally send) the standard PSCI PR announcement in Slack.
#
# Drives the running Slack desktop app over CDP via agent-browser. Encodes every
# gotcha from SKILL.md: sidebar navigation, execCommand clearing, one-mention-
# per-keystroke-burst, Meta+Shift+9 blockquotes, structural verification before
# any Enter is pressed.
#
# Default action is compose-only: the message is left as a draft in the composer,
# a screenshot is written, and a summary is printed. Pass --send to post it.
#
# Exit codes: 0 ok, 1 usage, 2 preflight (Slack/agent-browser), 3 navigation,
# 4 composition/verification mismatch, 5 send not confirmed.

set -uo pipefail

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
PORT=9222
CHANNEL="pr-review"
CHANNEL_ID=""
JIRA_BASE="https://procurementsciences.atlassian.net/browse"
TEAMS="team-win-engineers"
PEOPLE=""
SCREENSHOT="/tmp/pr-message-preview.png"
EMOJI_GITHUB="github"
EMOJI_JIRA="jira"

TICKET="" TYPE="" DESC="" PR_URL="" JIRA_URL="" SIZE="" STATS="" TITLE="" PR_NUM=""
INFER=0 PRINT=0 SEND=0 CLEAR=0 RESET=0 JSON=0 RELAUNCH=0 ALLOW_MISSING_EMOJI=0

usage() {
  cat <<'EOF'
Usage: post-pr-message.sh [fields] [action] [target]

Fields (each required unless --infer can derive it):
  --ticket ID        Jira key, e.g. DEV-9694
  --type TYPE        fix | feat | chore | refactor ... (scope allowed: feat(api))
  --desc TEXT        short description (from the PR title)
  --pr-url URL       GitHub PR URL
  --jira-url URL     default: https://procurementsciences.atlassian.net/browse/<ticket>
  --teams a,b        Slack user-group handles without '@' (comma or space separated)
                     default: team-win-engineers; pass --teams "" to tag no groups
  --people "A B,C D" people to tag, comma separated. Use the full name as Slack
                     shows it ("Ray Poulton") or their display handle ("Ben Stoker").
                     Matched live against Slack's autocomplete, so any user works.
  --size SIZE        XS | Small | Medium | Large | XL   (default: derived from --stats)
  --stats +A-D       e.g. +403-132
  --title TEXT       raw PR title to parse "<type>: <desc>" from
  --infer            fill anything missing from `gh pr view` and the branch name
  --pr N             PR number/branch/url to pass to `gh pr view` (default: current branch)

Actions (pick one; default is compose-only, leaving a draft plus a screenshot):
  --print            print the message text and exit; no browser interaction
  --send             compose, verify structure, then press Enter
  --clear            clear the composer in the target conversation and exit

Target / plumbing:
  --channel NAME     sidebar channel name (default: pr-review)
  --channel-id ID    Slack conversation ID (C.../D...); used if NAME is not in the sidebar
  --port N           Slack CDP port (default: 9222)
  --screenshot PATH  composer screenshot path (default: /tmp/pr-message-preview.png)
  --reset            full agent-browser daemon reset before starting
  --relaunch-slack   if Slack is not listening on the CDP port, quit and relaunch it with the flag
  --allow-missing-emoji  do not fail if :github:/:jira: custom emojis are absent
  --json             print a JSON summary on stdout (logs go to stderr regardless)
  -h, --help

Examples:
  post-pr-message.sh --infer --print
  post-pr-message.sh --infer --size Medium --send
  post-pr-message.sh --ticket DEV-9694 --type fix --desc "harden token refresher" \
    --pr-url https://github.com/procurement-sciences/chatbot-ui/pull/7089 \
    --stats +403-132 --send
EOF
}

log()  { printf '%s\n' "$*" >&2; }
die()  { local code=$1; shift; log "error: $*"; exit "$code"; }

# ---------------------------------------------------------------------------
# Args
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ticket)   TICKET=$2; shift 2 ;;
    --type)     TYPE=$2; shift 2 ;;
    --desc)     DESC=$2; shift 2 ;;
    --pr-url)   PR_URL=$2; shift 2 ;;
    --jira-url) JIRA_URL=$2; shift 2 ;;
    --teams)    TEAMS=$2; shift 2 ;;
    --people)   PEOPLE=$2; shift 2 ;;
    --size)     SIZE=$2; shift 2 ;;
    --stats)    STATS=$2; shift 2 ;;
    --title)    TITLE=$2; shift 2 ;;
    --pr)       PR_NUM=$2; shift 2 ;;
    --infer)    INFER=1; shift ;;
    --print)    PRINT=1; shift ;;
    --send)     SEND=1; shift ;;
    --clear)    CLEAR=1; shift ;;
    --channel)  CHANNEL=$2; shift 2 ;;
    --channel-id) CHANNEL_ID=$2; shift 2 ;;
    --port)     PORT=$2; shift 2 ;;
    --screenshot) SCREENSHOT=$2; shift 2 ;;
    --reset)    RESET=1; shift ;;
    --relaunch-slack) RELAUNCH=1; shift ;;
    --allow-missing-emoji) ALLOW_MISSING_EMOJI=1; shift ;;
    --json)     JSON=1; shift ;;
    -h|--help)  usage; exit 0 ;;
    *) usage >&2; die 1 "unknown argument: $1" ;;
  esac
done

for tool in agent-browser jq curl; do
  command -v "$tool" >/dev/null 2>&1 || die 2 "missing required tool: $tool"
done

# ---------------------------------------------------------------------------
# Field inference
# ---------------------------------------------------------------------------
infer_fields() {
  command -v gh >/dev/null 2>&1 || die 1 "--infer needs gh"
  local json
  if ! json=$(gh pr view ${PR_NUM:+"$PR_NUM"} --json url,title,additions,deletions,headRefName 2>/dev/null); then
    die 1 "gh pr view failed; is there an open PR for this branch? (pass --pr N)"
  fi
  local url title adds dels branch
  url=$(jq -r .url <<<"$json"); title=$(jq -r .title <<<"$json")
  adds=$(jq -r .additions <<<"$json"); dels=$(jq -r .deletions <<<"$json")
  branch=$(jq -r .headRefName <<<"$json")

  [[ -z $PR_URL ]] && PR_URL=$url
  [[ -z $TITLE ]] && TITLE=$title
  [[ -z $STATS ]] && STATS="+${adds}-${dels}"
  if [[ -z $TICKET ]]; then
    TICKET=$(grep -oE '[A-Z][A-Z0-9]+-[0-9]+' <<<"$branch $title" | head -1 || true)
  fi
}

parse_title() {
  # Strip a leading ticket key ("DEV-1 fix: x" or "[DEV-1] fix: x"), then split
  # "<type>[(scope)][!]: <desc>".
  local t=$TITLE
  t=$(sed -E 's/^\[?[A-Z][A-Z0-9]+-[0-9]+\]?[[:space:]:-]*//' <<<"$t")
  if [[ $t =~ ^([a-z]+(\([^\)]*\))?!?):[[:space:]]*(.*)$ ]]; then
    [[ -z $TYPE ]] && TYPE=${BASH_REMATCH[1]}
    [[ -z $DESC ]] && DESC=${BASH_REMATCH[3]}
  else
    [[ -z $DESC ]] && DESC=$t
  fi
}

infer_size() {
  local adds dels total
  if [[ $STATS =~ ^\+([0-9]+)-([0-9]+)$ ]]; then
    adds=${BASH_REMATCH[1]}; dels=${BASH_REMATCH[2]}; total=$((adds + dels))
    if   (( total < 50 ));   then SIZE=XS
    elif (( total < 200 ));  then SIZE=Small
    elif (( total < 500 ));  then SIZE=Medium
    elif (( total < 1000 )); then SIZE=Large
    else SIZE=XL; fi
  fi
}

(( INFER )) && infer_fields
[[ -n $TITLE ]] && parse_title
[[ -z $JIRA_URL && -n $TICKET ]] && JIRA_URL="$JIRA_BASE/$TICKET"
[[ -z $SIZE ]] && infer_size

# Mentions: group handles (no spaces, comma/space separated) followed by people
# (names may contain spaces, comma separated). Each entry is what gets typed after
# '@' and what the autocomplete option must be labelled with.
MENTION_ARR=()
TEAMS=${TEAMS//,/ }
for t in $TEAMS; do MENTION_ARR+=("${t#@}"); done
_people=()
[[ -n $PEOPLE ]] && IFS=',' read -r -a _people <<<"$PEOPLE"
for p in "${_people[@]+"${_people[@]}"}"; do
  p=$(sed -E 's/^[[:space:]]+|[[:space:]]+$//g' <<<"$p"); p=${p#@}
  [[ -n $p ]] && MENTION_ARR+=("$p")
done

if (( ! CLEAR )); then
  missing=()
  for f in TICKET TYPE DESC PR_URL JIRA_URL SIZE STATS; do
    [[ -z ${!f} ]] && missing+=("$f")
  done
  (( ${#MENTION_ARR[@]} )) || missing+=("TEAMS/PEOPLE")
  (( ${#missing[@]} )) && { usage >&2; die 1 "missing fields: ${missing[*]} (use --infer or pass flags)"; }
  case "$SIZE" in XS|Small|Medium|Large|XL) ;; *) die 1 "--size must be XS|Small|Medium|Large|XL (got '$SIZE')" ;; esac
  [[ $STATS =~ ^\+[0-9]+-[0-9]+$ ]] || die 1 "--stats must look like +403-132 (got '$STATS')"
  for v in TICKET TYPE DESC PR_URL JIRA_URL; do
    [[ ${!v} == *$'\xe2\x80\x94'* || ${!v} == *$'\xe2\x80\x93'* ]] && die 1 "$v contains an em/en dash; use ASCII '-'"
  done
fi

LINE1="*${TICKET} ${TYPE}: ${DESC}*"
LINE2=":${EMOJI_GITHUB}:  ${PR_URL}"
LINE3=":${EMOJI_JIRA}:  ${JIRA_URL}"
LINE4_PREFIX=":eyes:  "
LINE5=":shirt:  ${SIZE} ${STATS}"
mentions_text=""
for h in "${MENTION_ARR[@]}"; do mentions_text+="@${h} "; done
mentions_text=${mentions_text% }

message_text() {
  printf '%s\n> %s\n> %s\n> %s%s\n> %s\n' "$LINE1" "$LINE2" "$LINE3" "$LINE4_PREFIX" "$mentions_text" "$LINE5"
}

if (( PRINT )); then
  message_text
  exit 0
fi

# ---------------------------------------------------------------------------
# agent-browser plumbing
# ---------------------------------------------------------------------------
ab() { agent-browser --cdp "$PORT" "$@"; }
abq() { ab "$@" >/dev/null 2>&1; }          # quiet: swallow "Done"
# Evaluate JS; print the raw (JSON-encoded) result on stdout.
js() { ab eval "$1" 2>/dev/null; }
# Evaluate JS that returns a string; strip the JSON quoting.
jss() { js "$1" | jq -r '.' 2>/dev/null; }
jsarg() { jq -Rn --arg s "$1" '$s'; }        # bash string -> JS string literal

COMPOSER='document.querySelectorAll("[contenteditable=\"true\"]")[0]'

composer_label() { jss "${COMPOSER}?.getAttribute(\"aria-label\") ?? \"\""; }
composer_html()  { jss "${COMPOSER}?.innerHTML ?? \"\""; }

full_reset() {
  log "-> resetting agent-browser daemon"
  pkill -f "agent-browser" 2>/dev/null || true
  pkill -f "agent-browser-chrome-" 2>/dev/null || true
  rm -f ~/.agent-browser/default.* 2>/dev/null || true
  sleep 2
  local i
  for i in 1 2 3; do
    abq tab list && return 0
    sleep 1
  done
  return 1
}

relaunch_slack() {
  log "-> relaunching Slack with --remote-debugging-port=$PORT"
  osascript -e 'quit app "Slack"' >/dev/null 2>&1 || true
  sleep 2
  open -a "Slack" --args --remote-debugging-port="$PORT"
  local i
  for i in $(seq 1 20); do
    sleep 1
    curl -s -m 1 "http://localhost:$PORT/json/version" >/dev/null 2>&1 && { sleep 3; return 0; }
  done
  return 1
}

preflight() {
  if ! curl -s -m 2 "http://localhost:$PORT/json/list" | jq -e '.[] | select(.type=="page")' >/dev/null 2>&1; then
    if (( RELAUNCH )); then
      relaunch_slack || die 2 "Slack did not come up on port $PORT"
    else
      die 2 "Slack is not listening on CDP port $PORT. Relaunch it with --remote-debugging-port=$PORT (or pass --relaunch-slack)."
    fi
  fi
  (( RESET )) && { full_reset || die 2 "agent-browser did not recover after reset"; }

  local title
  title=$(ab get title 2>/dev/null || true)
  if [[ -z $title || $title == "about:blank" ]] || pgrep -f "agent-browser-chrome-" >/dev/null 2>&1; then
    log "-> agent-browser is not attached to Slack (title='${title}'); resetting"
    full_reset || die 2 "agent-browser did not recover after reset"
    title=$(ab get title 2>/dev/null || true)
    [[ -n $title && $title != "about:blank" ]] || die 2 "agent-browser still not attached to Slack after reset"
  fi
  log "-> attached: $title"
}

# ---------------------------------------------------------------------------
# Navigation
# ---------------------------------------------------------------------------
label_matches() {
  local label lc want
  label=$(composer_label); lc=$(tr '[:upper:]' '[:lower:]' <<<"$label")
  want=$(tr '[:upper:]' '[:lower:]' <<<"$CHANNEL")
  [[ $lc == *"$want"* ]]
}

exists() { [[ $(jss "document.querySelector($(jsarg "$1")) ? \"yes\" : \"no\"") == yes ]]; }

navigate() {
  label_matches && { log "-> already in $(composer_label)"; return 0; }

  # 1. sidebar entry by name
  local sel="[data-qa=\"channel_sidebar_name_${CHANNEL}\"]"
  if exists "$sel"; then
    abq click "$sel"; sleep 1.5
    label_matches && { log "-> navigated via sidebar: $(composer_label)"; return 0; }
  fi
  # 2. sidebar entry by conversation id (DM labels carry the person's name, so trust the id)
  if [[ -n $CHANNEL_ID ]]; then
    sel="[data-qa-channel-sidebar-channel-id=\"${CHANNEL_ID}\"]"
    if exists "$sel"; then
      abq click "$sel"; sleep 1.5
      log "-> navigated via sidebar id: $(composer_label)"; return 0
    fi
  fi
  # 3. quick switcher. Flaky over CDP when the composer holds focus, so blur first
  #    and confirm focus actually left the composer before typing anything.
  js 'document.activeElement && document.activeElement.blur(); "ok"' >/dev/null
  abq press "Meta+k"; sleep 1
  local active_label
  active_label=$(jss 'document.activeElement?.getAttribute("aria-label") ?? ""')
  if [[ $active_label != Message* && $(jss 'document.activeElement?.tagName ?? ""') != BODY ]]; then
    abq keyboard type "$CHANNEL"; sleep 1; abq press "Enter"; sleep 2
    label_matches && { log "-> navigated via quick switcher: $(composer_label)"; return 0; }
  else
    abq press "Escape"
  fi
  die 3 "could not navigate to '$CHANNEL' (composer label now: '$(composer_label)'). Pass --channel-id, or open the conversation in Slack and rerun."
}

# ---------------------------------------------------------------------------
# Composer primitives
# ---------------------------------------------------------------------------
clear_composer() {
  local html
  html=$(jss "(() => { const el = ${COMPOSER}; if (!el) return \"none\"; el.focus(); document.execCommand(\"selectAll\"); document.execCommand(\"delete\"); return el.innerHTML; })()")
  [[ $html == "<p><br></p>" || -z $html || $html == "<p></p>" ]] || {
    # one more pass; Slack sometimes leaves a stray formatting block
    html=$(jss "(() => { const el = ${COMPOSER}; el.focus(); document.execCommand(\"selectAll\"); document.execCommand(\"delete\"); return el.innerHTML; })()")
  }
  [[ $html == "<p><br></p>" || -z $html || $html == "<p></p>" ]] || die 4 "composer did not clear (innerHTML: ${html:0:120})"
}

type_text() { abq keyboard type "$1"; }
newline()   { abq press "Shift+Enter"; }

# Type one @mention and accept the autocomplete option that matches it.
#
# Slack labels options like:
#   "Team Win Engineers, @team-win-engineers (4 members)"      (user group)
#   "Ray Poulton (not in channel)"                              (person, no handle)
#   "Benjamin Stoker, @Ben Stoker (away), status: ..."         (person with display name)
# A strict match requires the query to be the leading name or the @handle. If the
# query has narrowed the popup to exactly one option that merely contains it, that
# is accepted too. Multi-word queries are typed one word at a time, because Slack
# only keeps filtering across a space when it gets a moment between words.
#
# Sets MENTION_MATCH to "strict" or "loose" for logging.
match_option() {  # $1 = JSON array of labels, $2 = query -> prints index or -1
  jq -r --arg q "$2" '
    def strict: test("(^|, )@?\\Q" + $q + "\\E( \\(|,|$)"; "i");
    def loose: ascii_downcase | contains($q | ascii_downcase);
    (to_entries | map(select(.value | strict)) | .[0].key) as $s
    | if $s != null then "\($s) strict"
      elif length == 1 and (.[0] | loose) then "0 loose"
      else "-1 none" end' <<<"${1:-[]}" 2>/dev/null || echo "-1 none"
}

type_mention() {
  local query=$1 labels="[]" idx=-1 how=none typed=0 i w
  local probe="(() => Array.from(document.querySelectorAll('[role=\"listbox\"] [role=\"option\"]')).map(o => o.getAttribute('aria-label') || o.innerText))()"
  for w in $query; do
    if (( typed )); then type_text " $w"; else type_text "@$w"; fi
    typed=1
    for i in $(seq 1 12); do
      sleep 0.25
      labels=$(js "$probe")
      read -r idx how < <(match_option "$labels" "$query")
      [[ $idx != "-1" ]] && break 2
    done
  done
  if [[ $idx == "-1" ]]; then
    die 4 "mention autocomplete never offered '${query}' (Slack offered: $(jq -c . <<<"${labels:-[]}" 2>/dev/null | cut -c1-200))"
  fi
  [[ $how == loose ]] && log "   note: '${query}' accepted as the only match: $(jq -r ".[$idx]" <<<"$labels" | cut -c1-80)"
  if exists "#tab_complete_ui_item_${idx}"; then
    abq click "#tab_complete_ui_item_${idx}"
  elif (( idx == 0 )); then
    abq press "Enter"
  else
    abq click "[role=\"listbox\"] [role=\"option\"]:nth-child($((idx + 1)))"
  fi
  sleep 0.6
}

# Slack inserts a space after an accepted chip; only add our own if it did not.
composer_ends_with_space() {
  [[ $(jss "${COMPOSER}.innerText.slice(-1)") == " " ]]
}

compose() {
  clear_composer
  type_text "$LINE1"
  newline
  abq press "Meta+Shift+9"; sleep 0.3
  type_text "$LINE2"; newline
  type_text "$LINE3"; newline
  type_text "$LINE4_PREFIX"
  local first=1 h
  for h in "${MENTION_ARR[@]}"; do
    (( first )) || { composer_ends_with_space || type_text " "; sleep 0.2; }
    type_mention "$h"; first=0
  done
  newline
  type_text "$LINE5"
  sleep 0.5
}

structure() {
  js "(() => { const el = ${COMPOSER}; const html = el.innerHTML; return {
    bold: (html.match(/<strong>/g) || []).length,
    quotes: (html.match(/<blockquote>/g) || []).length,
    emojis: (html.match(/class=\"emoji\"/g) || []).length,
    mentions: (html.match(/<ts-mention/g) || []).length,
    text: el.innerText }; })()"
}

verify_structure() {
  local s bold quotes emojis mentions want_m=${#MENTION_ARR[@]} problems=()
  s=$(structure)
  bold=$(jq -r .bold <<<"$s"); quotes=$(jq -r .quotes <<<"$s")
  emojis=$(jq -r .emojis <<<"$s"); mentions=$(jq -r .mentions <<<"$s")
  (( bold == 1 ))          || problems+=("bold=$bold (want 1)")
  (( quotes == 4 ))        || problems+=("quotes=$quotes (want 4)")
  (( mentions == want_m )) || problems+=("mentions=$mentions (want $want_m)")
  if (( emojis != 4 )); then
    (( ALLOW_MISSING_EMOJI )) || problems+=("emojis=$emojis (want 4; custom :${EMOJI_GITHUB}:/:${EMOJI_JIRA}: missing? --allow-missing-emoji)")
  fi
  STRUCTURE_JSON=$s
  if (( ${#problems[@]} )); then
    log "structure check failed: ${problems[*]}"
    log "composer text:"; jq -r .text <<<"$s" | sed 's/^/  | /' >&2
    die 4 "refusing to continue; draft left in composer for inspection (rerun with --clear to wipe it)"
  fi
  log "-> structure ok: bold=$bold quotes=$quotes emojis=$emojis mentions=$mentions"
}

send_message() {
  abq press "Enter"
  local i html
  for i in $(seq 1 12); do
    sleep 0.25
    html=$(composer_html)
    [[ $html == "<p><br></p>" || -z $html ]] && break
  done
  [[ $html == "<p><br></p>" || -z $html ]] || die 5 "pressed Enter but the composer is not empty; check Slack"
  sleep 1
  local last
  # The list ends with an empty placeholder item, so look at the last few.
  last=$(jss "(() => Array.from(document.querySelectorAll('[data-qa=\"virtual-list-item\"]')).slice(-5).map(e => e.innerText).join('\\n'))()")
  [[ $last == *"$TICKET"* ]] || log "warning: could not confirm '$TICKET' as the newest message in the channel; verify in Slack"
}

# Element screenshots from agent-browser land at the wrong offset because Slack
# renders at a non-1 devicePixelRatio. Capture the whole window and crop to the
# composer's bounding box instead (best effort; never fatal).
screenshot_composer() {
  local full="${SCREENSHOT%.png}.full.png" pw geom x y w h
  abq screenshot "$full" || return 1
  pw=$(sips -g pixelWidth "$full" 2>/dev/null | awk '/pixelWidth/ {print $2}')
  [[ -n $pw ]] || return 1
  geom=$(jss "(() => { const r = document.querySelector('[data-qa=\"message_input\"]').getBoundingClientRect();
    const s = ${pw} / window.innerWidth, p = 6;
    return [Math.round((r.x - p) * s), Math.round((r.y - p) * s), Math.round((r.width + 2*p) * s), Math.round((r.height + 2*p) * s)].join(' '); })()")
  read -r x y w h <<<"$geom"
  [[ -n $h ]] || return 1
  sips -c "$h" "$w" --cropOffset "$y" "$x" "$full" --out "$SCREENSHOT" >/dev/null 2>&1 || return 1
  rm -f "$full"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
preflight
navigate

if (( CLEAR )); then
  clear_composer
  log "-> composer cleared in $(composer_label)"
  exit 0
fi

log "-> composing:"
message_text | sed 's/^/  | /' >&2
compose
verify_structure
screenshot_composer && log "-> screenshot: $SCREENSHOT"

status="draft"
if (( SEND )); then
  send_message
  status="sent"
  log "-> sent to $(composer_label)"
else
  log "-> left as a draft (not sent). Rerun with --send to post, or --clear to discard."
fi

if (( JSON )); then
  jq -n --arg status "$status" --arg channel "$CHANNEL" --arg screenshot "$SCREENSHOT" \
        --arg ticket "$TICKET" --arg type "$TYPE" --arg desc "$DESC" --arg pr "$PR_URL" \
        --arg jira "$JIRA_URL" --arg size "$SIZE" --arg stats "$STATS" \
        --argjson mentions "$(printf '%s\n' "${MENTION_ARR[@]}" | jq -R . | jq -s .)" \
        --argjson structure "$STRUCTURE_JSON" \
        '{status:$status, channel:$channel, screenshot:$screenshot,
          fields:{ticket:$ticket,type:$type,desc:$desc,pr_url:$pr,jira_url:$jira,size:$size,stats:$stats,mentions:$mentions},
          structure:$structure}'
fi
