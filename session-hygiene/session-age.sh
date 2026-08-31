#!/usr/bin/env bash
# Session-hygiene nudge for Claude Code.
#   SessionStart      -> stamp the session start time (per session_id)
#   UserPromptSubmit  -> if the session is too OLD or its context too BIG, inject a
#                        warning telling Claude to /clear before a NEW task.
# Context size is read from a file the statusline writes (hooks can't see it directly).
# Time-only if no statusline is installed. All thresholds are env-overridable.
#
# Self-test: `bash session-age.sh --selftest`
set -euo pipefail

DIR="$HOME/.claude/.session-state"
mkdir -p "$DIR"

TIME_WARN_MIN="${CLAUDE_SESSION_WARN_MIN:-60}"
TIME_LOUD_MIN="${CLAUDE_SESSION_LOUD_MIN:-120}"
CTX_WARN="${CLAUDE_CTX_WARN_TOKENS:-150000}"
CTX_LOUD="${CLAUDE_CTX_LOUD_TOKENS:-300000}"

# --- pure logic, used by both the hook and the self-test ---
build_msg() { # args: age_min used_tokens
  local age="$1" used="$2" t="" c=""
  if   [ "$age" -ge "$TIME_LOUD_MIN" ]; then t="This session is ${age} min old (>=${TIME_LOUD_MIN}m)."
  elif [ "$age" -ge "$TIME_WARN_MIN" ]; then t="This session is ${age} min old (>=${TIME_WARN_MIN}m)."
  fi
  if   [ "$used" -ge "$CTX_LOUD" ]; then c="Context is ${used} tokens (>=${CTX_LOUD})."
  elif [ "$used" -ge "$CTX_WARN" ]; then c="Context is ${used} tokens (>=${CTX_WARN})."
  fi
  [ -z "$t$c" ] && return 1
  printf 'SESSION HYGIENE: %s %s If the next request is a NEW task, finish this one and run /clear first (a fresh session bounds context and weekly-usage cost). If it continues the current task, ignore this.' "$t" "$c"
}

if [ "${1:-}" = "--selftest" ]; then
  build_msg 200 0        >/dev/null || { echo "FAIL: old session should warn"; exit 1; }
  build_msg 0   400000   >/dev/null || { echo "FAIL: big context should warn"; exit 1; }
  build_msg 10  1000     >/dev/null && { echo "FAIL: fresh+small should be silent"; exit 1; }
  echo "selftest OK"; exit 0
fi

EVENT="${1:-}"
IN="$(cat 2>/dev/null || true)"
read -r SID SRC < <(printf '%s' "$IN" | python3 -c 'import json,sys
try: d=json.load(sys.stdin) or {}
except Exception: d={}
print(d.get("session_id",""), d.get("source",""))' 2>/dev/null || echo " ")
[ -z "$SID" ] && exit 0
STAMP="$DIR/$SID.start"
CTX="$DIR/$SID.ctx"

if [ "$EVENT" = "SessionStart" ]; then
  case "$SRC" in
    clear|startup) date +%s > "$STAMP" ;;                 # fresh logical session -> reset age
    *)             [ -f "$STAMP" ] || date +%s > "$STAMP" ;; # resume/compact/fork -> keep age
  esac
  find "$DIR" -type f -mtime +7 -delete 2>/dev/null || true  # prune old state
  exit 0
fi

# UserPromptSubmit
now=$(date +%s)
start=$(cat "$STAMP" 2>/dev/null || echo "$now")
[ -f "$STAMP" ] || echo "$start" > "$STAMP"
age_min=$(( (now - start) / 60 ))
used=0; [ -f "$CTX" ] && used=$(tr -cd '0-9' < "$CTX"); [ -z "$used" ] && used=0

if msg="$(build_msg "$age_min" "$used")"; then
  python3 - "$msg" <<'PY'
import json,sys
print(json.dumps({"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":sys.argv[1]}}))
PY
fi
exit 0
