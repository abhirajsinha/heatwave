#!/usr/bin/env bash
# Claude Code statusline: model | context (absolute tokens + %) | cost | duration.
# Context is bounded automatically by auto-compact (autoCompactWindow), so this is
# an informational readout only — no CLEAR? marker.
IN="$(cat)"
python3 - "$IN" <<'PY'
import json, sys
try: d = json.loads(sys.argv[1] or "{}")
except Exception: d = {}

m = d.get("model") or {}
model = m.get("display_name") if isinstance(m, dict) else (m or "?")

cw = d.get("context_window") or {}
used  = int(cw.get("total_input_tokens") or 0) + int(cw.get("total_output_tokens") or 0)
total = int(cw.get("context_window_size") or 0)
pct   = cw.get("used_percentage")
if pct is None and used and total:
    pct = round(100 * used / total)

cost = d.get("cost") or {}
usd  = cost.get("total_cost_usd") or cost.get("cost_usd") or 0
dur  = int(cost.get("total_duration_ms") or 0)

def k(n):
    n = int(n)
    return f"{n/1000:.0f}k" if n >= 1000 else str(n)

mins = dur // 60000
dstr = f"{mins//60}h {mins%60}m" if mins >= 60 else f"{mins}m"
ctx  = f"ctx {k(used)}" + (f"/{k(total)}" if total else "") + (f" ({pct}%)" if pct is not None else "")
parts = [str(model), ctx, f"${float(usd):.2f}", dstr]
print(" | ".join(p for p in parts if p))
PY
