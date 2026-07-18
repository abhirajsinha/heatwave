#!/bin/sh
# Heatwave gate for Gemini CLI hooks (BeforeAgent): wraps GATE.md in the
# hookSpecificOutput envelope so the gate text is injected as additional
# context on every agent turn. Emits nothing if the gate file is missing.

[ -f .heatwave/GATE.md ] || exit 0
python3 - <<'PYEOF'
import json
text = open(".heatwave/GATE.md").read()
print(json.dumps({"hookSpecificOutput": {"hookEventName": "BeforeAgent", "additionalContext": text}}))
PYEOF
