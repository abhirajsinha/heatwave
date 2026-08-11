#!/usr/bin/env python3
"""Parse the last type=result event from a stream-json transcript.
Emits shell-assignable lines (single-quoted; charset-stripped — the allowed set
contains no quote, so the quoting cannot be broken). Tolerates a truncated
final line (killed run): unparseable lines are skipped, absent result event
leaves every field empty and the harness classifies from other evidence."""
import json
import re
import sys

cost = sub = model = ""
esc = "0"
try:
    for line in open(sys.argv[1], errors="replace"):
        try:
            d = json.loads(line)
        except ValueError:
            continue  # truncated tail line from a killed process
        if d.get("type") == "result":
            v = d.get("total_cost_usd")
            cost = "" if v is None else str(v)
            sub = str(d.get("subtype", ""))
            mu = d.get("modelUsage") or {}
            model = ";".join(sorted(mu))
            # plan-review F-001: marker counts only on the FINAL line of the
            # result text, so prose that merely mentions it cannot match.
            lines = str(d.get("result", "")).strip().splitlines()
            esc = "1" if lines and "ARM_OUTCOME: ESCALATED" in lines[-1] else "0"
except OSError:
    pass

# plan-review F-006: allow [] so claude-opus-5[1m] survives verbatim.
clean = lambda s: re.sub(r"[^A-Za-z0-9._$;\[\]-]", "", s)
print(f"COST='{clean(cost)}'")
print(f"SUBTYPE='{clean(sub)}'")
print(f"ST_MODEL='{clean(model)}'")
print(f"RESULT_ESC='{esc}'")
