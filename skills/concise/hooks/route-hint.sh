#!/usr/bin/env bash
# Routes what leaves the conversation through the command that writes it. The
# session's first commit, review comment or PR description is denied with a
# reason naming the command, and the call goes through when it comes again —
# a nudge, never a wall.
#   $1 = opt-out flag file under ~/.claude
#   $2.. = `regex::command::reason`: a call matching the regex is denied once
#          per session, unless the session already ran the command.
# Escape hatch: export CONCISE_NO_ROUTE_HINT=1, or touch the flag file.
flag="${1:-}"
shift 2>/dev/null

[ -n "$flag" ] && [ -f "$HOME/.claude/$flag" ] && exit 0
[ -n "${CONCISE_NO_ROUTE_HINT:-}" ] && exit 0

# The hint names a command, and a Codex plugin ships skills, not commands:
# there the denial would send the session to something it cannot run.
. "${0%/*}/host.sh"
[ "$(concise_host)" = codex ] && exit 0

in=$(cat)
sid=$(printf '%s' "$in" |
  sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
transcript=$(printf '%s' "$in" |
  sed -n 's/.*"transcript_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

for rule in "$@"; do
  re=${rule%%::*}
  rest=${rule#*::}
  cmd=${rest%%::*}
  reason=${rest#*::}
  [ -n "$re" ] && [ -n "$cmd" ] || continue
  printf '%s' "$in" | grep -qE "$re" || continue

  # The command makes this same call: denying it would send the session to run
  # the command it is already running.
  [ -n "$transcript" ] && [ -f "$transcript" ] &&
    grep -qF -e "<command-name>/$cmd</command-name>" -e "\"skill\":\"$cmd\"" "$transcript" &&
    exit 0

  # Once per session and per command: the second attempt is the model deciding
  # to go ahead, and a hook that keeps denying turns into a wall the session
  # cannot leave.
  mark="${TMPDIR:-/tmp}/concise-route-hint.${sid:-default}.${cmd##*:}"
  [ -f "$mark" ] && exit 0
  # Nothing else removes a mark. Dropping one older than a day costs a session
  # resumed after that at most a second hint.
  find "${TMPDIR:-/tmp}" -maxdepth 1 -name 'concise-route-hint.*' -mtime +0 -exec rm -f {} + 2>/dev/null
  : > "$mark"

  esc=${reason//\\/\\\\}
  esc=${esc//\"/\\\"}
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$esc"
  exit 0
done
exit 0
