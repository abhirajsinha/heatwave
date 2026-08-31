#!/usr/bin/env bash
# One-shot session-age nudge for Claude Code: when a session gets old, remind ONCE
# (not every turn) to /clear before a NEW/unrelated task. Context bloat is handled
# automatically by auto-compact (autoCompactWindow), so this no longer warns on tokens.
#   SessionStart     -> stamp the session start time
#   UserPromptSubmit -> warn at most once when age >= CLAUDE_SESSION_WARN_MIN (default 60)
# Self-test: bash session-age.sh --selftest
set -euo pipefail

DIR="$HOME/.claude/.session-state"; mkdir -p "$DIR"
WARN_MIN="${CLAUDE_SESSION_WARN_MIN:-60}"

msg_for() {  # age_min -> prints message (rc 0) or nothing (rc 1)
  [ "$1" -ge "$WARN_MIN" ] || return 1
  printf 'SESSION HYGIENE: this session is %s min old. If your NEXT request is a new or unrelated task, run /clear first for a fresh session; auto-compact already keeps context bounded within the current task. Ignore this if you are continuing the same task.' "$1"
}

if [ "${1:-}" = "--selftest" ]; then
  msg_for 65 >/dev/null || { echo "FAIL: old session should warn"; exit 1; }
  msg_for 30 >/dev/null && { echo "FAIL: fresh session should be silent"; exit 1; }
  echo "selftest OK"; exit 0
fi

EVENT="${1:-}"
IN="$(cat 2>/dev/null || true)"
read -r SID SRC < <(printf '%s' "$IN" | python3 -c 'import json,sys
try: d=json.load(sys.stdin) or {}
except Exception: d={}
print(d.get("session_id",""), d.get("source",""))' 2>/dev/null || echo " ")
[ -z "$SID" ] && exit 0
STAMP="$DIR/$SID.start"; WARNED="$DIR/$SID.warned"

if [ "$EVENT" = "SessionStart" ]; then
  case "$SRC" in
    clear|startup) date +%s > "$STAMP"; rm -f "$WARNED" ;;   # fresh session -> reset age + re-arm
    *)             [ -f "$STAMP" ] || date +%s > "$STAMP" ;; # resume/compact/fork -> keep age
  esac
  find "$DIR" -type f -mtime +7 -delete 2>/dev/null || true  # prune old state
  exit 0
fi

# UserPromptSubmit: warn at most once per session
[ -f "$WARNED" ] && exit 0
now=$(date +%s); start=$(cat "$STAMP" 2>/dev/null || echo "$now")
[ -f "$STAMP" ] || echo "$start" > "$STAMP"
age_min=$(( (now - start) / 60 ))
if msg="$(msg_for "$age_min")"; then
  : > "$WARNED"
  python3 - "$msg" <<'PY'
import json,sys
print(json.dumps({"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":sys.argv[1]}}))
PY
fi
exit 0
