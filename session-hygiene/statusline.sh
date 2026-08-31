#!/usr/bin/env bash
# Claude Code statusline: model | context (absolute tokens + %) | cost | duration.
# Also persists the session's used-token count so session-age.sh can nudge on context.
IN="$(cat)"
python3 - "$IN" <<'PY'
import json, sys, os
try: d = json.loads(sys.argv[1] or "{}")
except Exception: d = {}

m = d.get("model") or {}
model = m.get("display_name") if isinstance(m, dict) else (m or "?")

cw = d.get("context_window") or {}
used  = int(cw.get("used") or 0)
total = int(cw.get("total") or cw.get("max_tokens") or 0)
pct   = cw.get("percentage")
if pct is None and used and total:
    pct = round(100 * used / total)

cost = d.get("cost") or {}
usd  = cost.get("cost_usd") or cost.get("total_cost_usd") or 0
dur  = int(cost.get("total_duration_ms") or 0)

sid = d.get("session_id")
if sid:  # bridge: let the (context-blind) hook read the current token count
    try:
        sd = os.path.expanduser("~/.claude/.session-state"); os.makedirs(sd, exist_ok=True)
        open(os.path.join(sd, f"{sid}.ctx"), "w").write(str(used))
    except Exception:
        pass

def k(n):
    n = int(n)
    return f"{n/1000:.0f}k" if n >= 1000 else str(n)

warn = int(os.environ.get("CLAUDE_CTX_WARN_TOKENS", "150000"))
mins = dur // 60000
dstr = f"{mins//60}h {mins%60}m" if mins >= 60 else f"{mins}m"
ctx  = f"ctx {k(used)}" + (f"/{k(total)}" if total else "") + (f" ({pct}%)" if pct is not None else "")
if used >= warn:
    ctx += " CLEAR?"
parts = [str(model), ctx, f"${float(usd):.2f}", dstr]
print(" | ".join(p for p in parts if p))
PY
