#!/usr/bin/env python3
"""token-usage.py — read-only token/wall extractor over harness-retained agent.ndjson (R-146/FR-7, v5.1).

Primary source: modelUsage summed across models in the final type=result event — the WHOLE-RUN figure
that reconciles to total_cost_usd and includes subagent/sidechain spend. Top-level `usage` is a
main-thread PARTIAL and is NEVER used as the token source (plan finding F-001).

Two cross-checks, both reported:
  (a) sum(modelUsage.costUSD) == total_cost_usd  (±$0.01)
  (b) per-message usage summed, deduped by message.id  (the audit's method; walks sidechain messages)

Degrade (R-64): modelUsage absent -> per-message dedup sum, flagged; neither -> cost+wall only,
token classes NOT AVAILABLE.

Usage:
  token-usage.py <agent.ndjson> [<agent.ndjson> ...]   # one row per transcript + a totals line
  token-usage.py --check <agent.ndjson>                # self-test assertions (exit 1 on failure)

stdlib only. Reads files as text; executes nothing.
"""
import json
import sys


def load_result_and_messages(path):
    result = None
    per_msg = {}  # message.id -> usage dict (dedup)
    with open(path, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                o = json.loads(line)
            except ValueError:
                continue
            t = o.get("type")
            if t == "result":
                result = o  # last one wins
            elif t == "assistant":
                m = o.get("message", {})
                mid = m.get("id")
                u = m.get("usage")
                if mid and u and mid not in per_msg:
                    per_msg[mid] = u
    return result, per_msg


def classes_from_model_usage(mu):
    """Sum the four token classes + cost across all models."""
    inp = cw = cr = out = 0
    cost = 0.0
    for v in mu.values():
        inp += v.get("inputTokens", 0)
        cw += v.get("cacheCreationInputTokens", 0)
        cr += v.get("cacheReadInputTokens", 0)
        out += v.get("outputTokens", 0)
        cost += v.get("costUSD", 0.0) or 0.0
    return {"input": inp, "cache_write": cw, "cache_read": cr, "output": out, "modelusage_cost": cost}


def classes_from_per_message(per_msg):
    inp = cw = cr = out = 0
    for u in per_msg.values():
        inp += u.get("input_tokens", 0)
        cw += u.get("cache_creation_input_tokens", 0)
        cr += u.get("cache_read_input_tokens", 0)
        out += u.get("output_tokens", 0)
    return {"input": inp, "cache_write": cw, "cache_read": cr, "output": out}


def top_usage_classes(result):
    u = result.get("usage", {}) or {}
    return {
        "input": u.get("input_tokens", 0),
        "cache_write": u.get("cache_creation_input_tokens", 0),
        "cache_read": u.get("cache_read_input_tokens", 0),
        "output": u.get("output_tokens", 0),
    }


def extract(path):
    result, per_msg = load_result_and_messages(path)
    row = {"path": path}
    if result is None:
        row["source"] = "NONE"
        row["note"] = "no type=result event"
        return row
    row["total_cost_usd"] = result.get("total_cost_usd")
    row["wall_s"] = round(result.get("duration_ms", 0) / 1000.0, 1)
    mu = result.get("modelUsage")
    pm = classes_from_per_message(per_msg) if per_msg else None
    if mu:
        c = classes_from_model_usage(mu)
        row["source"] = "modelUsage"
        row.update({k: c[k] for k in ("input", "cache_write", "cache_read", "output")})
        row["modelusage_cost"] = round(c["modelusage_cost"], 6)
        # cross-check (a)
        tc = row["total_cost_usd"]
        row["xcheck_cost_ok"] = (tc is not None) and abs(c["modelusage_cost"] - tc) <= 0.01
        # cross-check (b)
        row["permsg_cache_read"] = pm["cache_read"] if pm else None
        row["permsg_output"] = pm["output"] if pm else None
    elif pm:
        row["source"] = "per-message (modelUsage ABSENT — flagged, R-64)"
        row.update({k: pm[k] for k in ("input", "cache_write", "cache_read", "output")})
    else:
        row["source"] = "cost+wall only (token classes NOT AVAILABLE, R-64)"
    return row


def fmt(row):
    if row.get("source") == "NONE":
        return f"{row['path']}: NO RESULT ({row.get('note')})"
    if "cache_read" not in row:
        return (f"{row['path']}: source={row['source']} "
                f"cost=${row.get('total_cost_usd')} wall={row.get('wall_s')}s")
    line = (f"{row['path']}: source={row['source']} "
            f"input={row['input']} cache_write={row['cache_write']} "
            f"cache_read={row['cache_read']} output={row['output']} "
            f"cost=${row.get('total_cost_usd')} wall={row.get('wall_s')}s")
    if "xcheck_cost_ok" in row:
        line += f" | xcheck(cost=={row['modelusage_cost']})={'OK' if row['xcheck_cost_ok'] else 'MISMATCH'}"
        line += f" | permsg_cache_read={row['permsg_cache_read']} permsg_output={row['permsg_output']}"
    return line


def self_check(path):
    """Assert the extractor reads the WHOLE-RUN meter, not the partial top-level usage."""
    result, per_msg = load_result_and_messages(path)
    assert result is not None, "no result event"
    mu = result.get("modelUsage")
    assert mu, "modelUsage absent — cannot self-check the primary source on this transcript"
    c = classes_from_model_usage(mu)
    tc = result.get("total_cost_usd")
    # (1) modelUsage cost reconciles to total_cost_usd
    assert tc is not None and abs(c["modelusage_cost"] - tc) <= 0.01, \
        f"cost reconcile FAILED: modelUsage={c['modelusage_cost']} total_cost_usd={tc}"
    # (2) the extracted classes equal the modelUsage sum (identity — guards refactors)
    ex = extract(path)
    assert ex["cache_read"] == c["cache_read"] and ex["output"] == c["output"], "extract != modelUsage sum"
    # (3) the whole-run figure is STRICTLY LARGER than the partial top-level usage (F-001)
    top = top_usage_classes(result)
    assert c["cache_read"] > top["cache_read"], \
        f"modelUsage cache_read ({c['cache_read']}) not > top-level usage ({top['cache_read']}) — wrong meter risk"
    print(f"SELF-CHECK PASS {path}")
    print(f"  modelUsage cache_read={c['cache_read']} output={c['output']} cost=${round(c['modelusage_cost'],6)} == total_cost_usd=${tc}")
    print(f"  top-level usage (PARTIAL, not used) cache_read={top['cache_read']}  (ratio {c['cache_read']/max(top['cache_read'],1):.2f}x)")
    return 0


def main(argv):
    if not argv:
        print(__doc__)
        return 2
    if argv[0] == "--check":
        return self_check(argv[1])
    rows = [extract(p) for p in argv]
    for r in rows:
        print(fmt(r))
    tot = {k: 0 for k in ("input", "cache_write", "cache_read", "output")}
    cost = 0.0
    for r in rows:
        for k in tot:
            tot[k] += r.get(k, 0) or 0
        cost += r.get("total_cost_usd") or 0.0
    print(f"TOTAL: input={tot['input']} cache_write={tot['cache_write']} "
          f"cache_read={tot['cache_read']} output={tot['output']} cost=${round(cost,6)}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
