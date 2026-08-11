# Design Spec — Benchmark Runtime Fix + Conclusive Rerun (Heatwave Protocol v4, Sub-project E2)

- **Date:** 2026-08-11
- **Status:** Draft, awaiting owner review
- **Scope:** Make the benchmark's HEATWAVE arm reliably reach a TERMINAL outcome in bounded time, then rerun the pilot for a conclusive result. Builds on E (benchmark/).
- **Depends on:** A–F merged to main. Fixes the failure mode E's pilot surfaced.

---

## 1. Context & problem

E's pilot was honest but **inconclusive**: the HEATWAVE arm on task t01 ran ~3236s (54 min) and never reached a terminal state; t02 was watchdog-killed. Only t03 completed (`$12.37`). Root failure: a headless HEATWAVE arm can **hang** — the Heatwave loop is non-stop but *stops* at escalation / owner-decision points (§9.4, §7.1), and in an unattended benchmark there is no human, so it waits forever. The watchdog then kills it, producing a *lost* row rather than a *recorded* one. Result: the escaped-defect delta is uncomputable. E2 makes every arm terminate with a recorded outcome, tries to make the HEATWAVE arm faster, and reruns.

## 2. Goals / non-goals

**Goals:**
- G1. **Diagnose** why the headless HEATWAVE arm did not terminate (inspect E's retained transcripts + a fresh instrumented single run): which state it hung in (escalation? owner-decision? a genuinely slow but progressing loop?).
- G2. **Never hang:** the benchmark HEATWAVE arm runs fully unattended — any owner-decision / escalation becomes a **terminal** arm outcome (recorded `ESCALATED`/`NO_OUTPUT`), never a wait. Backstopped by a graceful per-task wall-clock that, on expiry, terminates the run and records a **terminal `TIMEOUT`** row (elapsed + cost), not a silent kill.
- G3. **Try to make it faster (honestly):** confirm the small corpus tasks classify to a light tier under adaptive intake (they are single-file fixes → LIGHT/EXPRESS, not FULL); if the arm runs heavier than warranted, correct the invocation so the benchmark exercises the tier a real user would get. Optionally allow a cheap model for the arm via config (C's tiering) — recorded.
- G4. **Rerun** the bounded pilot so every arm reaches a terminal outcome, and produce a **conclusive** RESULTS.md: either real escaped-defect rates per arm, OR an honest, quantified "HEATWAVE did not complete N/M tasks within budget" completion-rate finding (which is itself a real, publishable result about headless cost).
- G5. Keep it honest (E's bar): no fabricated rows; timeouts/escalations recorded, not hidden; no inflated delta.

**Non-goals (deferred):**
- The three-arm (RAW / Protocol / Protocol+Enforcement) benchmark — future, after #1 (enforcement hardening) lands.
- Growing the corpus beyond E's 8 tasks.
- Any protocol rule change (this is a harness + invocation + config fix; touch protocol/ only if the diagnosis proves a real orchestrator headless bug).

## 3. Scoring decision (set, with justification)

A HEATWAVE arm that TIMES OUT or ESCALATES produced **no gradable code**, so it is:
- **Excluded** from the escaped-defect *rate* denominator (an unfinished run is not a defect), AND
- **Recorded** as a distinct **completion-failure** with its own rate ("HEATWAVE completed K/M tasks in budget").
This keeps the escaped-defect metric clean while surfacing the honest, important signal that headless Heatwave may be too slow/expensive to finish some tasks in budget. RESULTS.md reports both. (Rationale: conflating "didn't finish" with "shipped a bug" would be dishonest in the opposite direction.)

## 4. Design

### 4.1 Diagnosis (impl task 1, evidence-producing)

Read E's retained pilot transcripts (`benchmark/results/transcripts/`) + the C battery at `/private/tmp/hw-c-verify` if present; run ONE instrumented HEATWAVE arm on the smallest corpus task with state logging, and identify the terminal/hang point. Record the finding in the impl package. The fix below is designed to be robust whether the cause is escalation-wait, owner-decision-wait, or slow-but-progressing.

### 4.2 Unattended termination (`benchmark/run.sh` + a benchmark run-config)

- The HEATWAVE arm is invoked with an **unattended profile**: autonomy set so the loop never blocks on a human — an escalation or owner-decision immediately writes a terminal arm result (`ESCALATED` with the reason) and the process exits. (Use C's `autonomy` run-config field + the existing §7 escalation path; if the headless adapter currently *waits*, add a benchmark-only "no-human → terminal" shim in the harness, not a protocol change, unless diagnosis shows a real orchestrator bug.)
- **Graceful per-task wall-clock** in the harness: on expiry, SIGTERM the arm's process group, then record a **terminal `TIMEOUT`** row with elapsed + cost + last state — a recorded outcome, never a lost row. (Replaces the old watchdog-kill-with-no-row behavior.)

### 4.3 Right-tier / speed (`benchmark/run.sh`, config)

- Verify the corpus tasks classify to LIGHT/EXPRESS under adaptive intake (single-file fixes). The benchmark HEATWAVE arm should run the tier a real user gets — not force FULL. Record the tier each arm actually ran in the CSV (`tier` column).
- Optionally set a cheap model for the arm (C's tiering) via the unattended profile; record `stage_model`. This is an allowed, disclosed speedup — the arm still runs the real protocol.

### 4.4 Rerun (impl task, bounded)

Rerun the bounded pilot (≤8×1, or the pre-committed ≥3 subset) with the fixed harness so EVERY arm terminates. Keep E's per-task canary + cumulative breaker. Regenerate `benchmark/results/*.csv` and rewrite `RESULTS.md` with: escaped-defect rate per arm over TERMINAL+gradable runs, the HEATWAVE completion-rate (K/M in budget), mean wall-time/cost per arm, and a plain honest reading (state conclusively whatever the data shows — including "still inconclusive on delta but here is the completion/cost profile" if that's the truth).

### 4.5 Metric/CSV additions (`benchmark/run.sh`, METHODOLOGY.md)

CSV gains `terminal?` (already added in E), `outcome` (`graded|timeout|escalated|error`), `tier`, `stage_model`. METHODOLOGY.md documents the scoring decision (§3) and the unattended profile.

## 5. Affected files

**Modified (mostly benchmark/):**
- `benchmark/run.sh` — unattended HEATWAVE profile, graceful terminal-timeout, per-arm tier/model recording, terminal-outcome rows
- `benchmark/METHODOLOGY.md` — scoring decision, unattended profile, completion-rate metric
- `benchmark/RESULTS.md` — rewritten from the fresh conclusive rerun
- `benchmark/summarize.awk` — completion-rate + outcome breakdown
- possibly `heatwave.config.example.yaml` — document a benchmark/unattended autonomy profile (if a config field helps)
- **protocol/ only if** diagnosis proves a genuine headless-orchestrator hang that must be fixed in the driver rules (then it's a real rule fix + PROTOCOL.md regen + drift). Prefer a harness-level fix; escalate to a protocol change only with evidence.

**No new runtime dependencies** (POSIX sh, `claude`, python3/awk already used).

## 6. Alternatives considered

1. **Just raise the watchdog timeout.** Rejected: a longer wait still hangs and still costs; the problem is non-termination, not patience.
2. **Score a timeout as a HEATWAVE "loss"/defect.** Rejected: dishonest — not finishing ≠ shipping a bug. Excluded from escaped-defect, reported as completion-failure (§3).
3. **Drop the HEATWAVE arm / benchmark RAW only.** Rejected: defeats the benchmark's purpose.
4. **Force FULL tier for realism.** Rejected: a real user gets the adaptive tier; forcing FULL over-weights cost and isn't the real workflow.

## 7. Risks & mitigations

| Risk | Mitigation |
|---|---|
| Rerun still expensive | E's canary + cumulative breaker retained; terminal-timeout bounds each arm; run the ≥3 subset if needed |
| Unattended shim masks a real orchestrator bug | diagnosis (4.1) first; if it's a driver bug, fix it as a real protocol change with evidence, not a benchmark band-aid |
| Timeout misattributed | record last state + elapsed + cost per timeout row; outcome column explicit |
| Dishonest headline creep | §3 scoring fixed + reviewer checks; no delta claimed unless both arms have terminal gradable runs |
| Protocol regression if a shard is touched | build-protocol.sh drift check; prefer benchmark-only diff |

## 8. Verification strategy (evidence, not assertion)

1. **Diagnosis recorded:** the hang/terminal point of the old run is identified with transcript evidence in the impl package.
2. **No hang:** a HEATWAVE arm that would escalate/await now terminates with a recorded `ESCALATED`/`TIMEOUT` outcome (force the condition on a scratch task); no process is left running. Evidence: outcome row + `ps` clean.
3. **Graceful timeout:** a deliberately capped run records a terminal `TIMEOUT` row with elapsed+cost, not a lost row. Evidence: CSV row.
4. **Tier correctness:** corpus tasks record LIGHT/EXPRESS (not FULL) in the `tier` column. Evidence: CSV.
5. **Conclusive rerun:** every arm in the rerun has a terminal outcome; RESULTS.md reports escaped-defect (over gradable) + HEATWAVE completion-rate + cost, and states the conclusion honestly. Evidence: CSV + RESULTS.md.
6. **Honesty:** no fabricated rows; timeouts/escalations present; no delta claimed without terminal gradable runs both arms; forbidden-grep (`0/[0-9]` unqualified, %, "fewer bugs") clean in RESULTS. Evidence: grep + row trace.
7. **Oracle isolation still holds** (E's F-001 fix): scratch outside repo, transcript grep zero oracle access. Evidence: recorded.
8. **No regression:** A–F intact; `git diff` scoped (benchmark/ + docs, protocol/ only if diagnosis forced it); drift `OK`; check-corpus 8/8. Evidence: outputs.

## 9. Open questions

None blocking. Whether the fix is harness-only or needs a driver change is answered by the diagnosis (4.1) — the spec covers both paths.
