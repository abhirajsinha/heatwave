#!/bin/sh
# CLAUDE_BIN stub for the forced-escalation self-test: writes a protocol-terminal
# ESCALATED state + a valid stream-json result whose FINAL line is the marker.
mkdir -p .heatwave/runs/stub
printf 'task_id: stub\ntier: LIGHT\nstate: ESCALATED\n' > .heatwave/runs/stub/state.yaml
printf '{"type":"result","subtype":"success","total_cost_usd":0,"modelUsage":{"stub-model":{}},"result":"Escalation Report written.\\nARM_OUTCOME: ESCALATED - budget exhausted"}\n'
exit 0
