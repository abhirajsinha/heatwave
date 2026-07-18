#!/bin/sh
# Heatwave role gate — PreToolUse hook for Claude Code (Edit|Write matcher).
# Mechanically blocks project-source edits while an active run is in a state
# whose owner should not be writing code (PLANNING, any review state) — the
# "code before plan approval" drift, made impossible instead of discouraged.
# Artifacts (.heatwave/**) are always writable. No active run = no gate.
# Exit 0 allows the tool call; exit 2 blocks it with the stderr message.

set -eu

INPUT=$(cat)

python3 - "$INPUT" <<'PYEOF'
import json, os, sys, glob

try:
    data = json.loads(sys.argv[1])
except (IndexError, json.JSONDecodeError):
    sys.exit(0)

path = (data.get("tool_input") or {}).get("file_path", "")
if not path:
    sys.exit(0)

# Artifacts, run state, and Heatwave's own files are always writable.
allowed_fragments = (".heatwave/", "/CLAUDE.md", "/AGENTS.md", "/GEMINI.md")
if any(f in path for f in allowed_fragments):
    sys.exit(0)

NO_EDIT_STATES = {"PLANNING", "PLAN_REVIEW", "FULL_REVIEW", "TARGETED_REVIEW", "FINAL_REVIEW"}
for state_file in glob.glob(".heatwave/runs/*/state.yaml"):
    state = ""
    try:
        for line in open(state_file):
            if line.strip().startswith("state:"):
                state = line.split(":", 1)[1].strip().strip('"').split()[0]
                break
    except OSError:
        continue
    if state in NO_EDIT_STATES:
        run = os.path.basename(os.path.dirname(state_file))
        print(
            f"Heatwave gate: run '{run}' is in {state} — project source must not be edited "
            f"in this state (R-1/R-37). If you are the driver, dispatch the owning role subagent; "
            f"if the plan is approved, update state.yaml to IMPLEMENTING first.",
            file=sys.stderr,
        )
        sys.exit(2)

sys.exit(0)
PYEOF
