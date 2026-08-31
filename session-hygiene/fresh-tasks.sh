#!/usr/bin/env bash
# Run each task as a FRESH `claude -p` process, so context is bounded per task
# (the only real "auto new session per task" — for batch/autonomous work, not
# interactive coding). Each task starts cold; no context carries between them.
#
# Usage:
#   fresh-tasks.sh "fix auth" "add pagination" "write tests"
#   fresh-tasks.sh -f tasks.txt          # one task per line (blank lines skipped)
# Model override: CLAUDE_TASK_MODEL=claude-opus-4-8 fresh-tasks.sh ...
set -euo pipefail

MODEL="${CLAUDE_TASK_MODEL:-claude-opus-4-8[1m]}"

run_one() {
  local t="$1"
  [ -z "${t// }" ] && return 0
  echo "=== $(date '+%H:%M:%S')  FRESH SESSION  ================================"
  echo ">>> $t"
  claude --model "$MODEL" -p "$t" || echo "!! task failed: $t"
  echo
}

if [ "${1:-}" = "-f" ]; then
  [ -f "${2:-}" ] || { echo "file not found: ${2:-}" >&2; exit 1; }
  while IFS= read -r line; do run_one "$line"; done < "$2"
else
  [ "$#" -gt 0 ] || { echo "usage: $0 \"task\"...  |  $0 -f tasks.txt" >&2; exit 1; }
  for t in "$@"; do run_one "$t"; done
fi
