# Review Report

task_id: 2026-08-11-benchmark-runtime-fix | artifact_type: review-report | iteration: 1 | review_type: PLAN_REVIEW | produced_by: REVIEWER (claude-fable-5) | timestamp: 2026-08-11

## Verdict

GATE_MET — **APPROVED**
Blockers: 0 open | Majors: 0 open | Minor: 5 | Nit: 3

## Scope Evaluated

Full §4.2 plan review against the approved spec `docs/specs/2026-08-11-benchmark-runtime-fix-design.md`, ground-truthed against the repo at HEAD `5d4562f` (verified: matches the plan's claim; `sh build-protocol.sh --check` → `OK`; `check-corpus.sh` → ALL TASKS PASS, re-run by this reviewer). Focus areas per dispatch: diagnosis soundness, scoring honesty (spec §3), termination guarantee, tier correctness, scope/regression. Plan Review Scope table checked — category selections and ✗ justifications are sound.

## Scope Changes

None.

## Reconciliation

Iteration 1 — no prior findings. Late findings: None.

## Acceptance Status

N/A at PLAN_REVIEW (AC verifiability assessed under Findings/Verification instead: all 12 ACs carry exact commands or named evidence and are independently verifiable; AC-F-04 has one edge, F-003 below).

## Findings

### F-001 (Minor, correctness) — `RESULT_ESC` substring match can override a genuinely APPROVED run
Plan §Architecture, "Outcome classification" block + `parse-result.py` (plan lines ~140, ~172–176). Classification checks `RESULT_ESC=1` **before** the `graded` branch, and the parser sets it on `"ARM_OUTCOME: ESCALATED" in result`. A run that reaches APPROVED but *mentions* the literal marker anywhere in its final prose (e.g. explaining the unattended instruction it was given) is misclassified `escalated` even with `LAST_STATE=APPROVED`. Direction is conservative (deflates HEATWAVE completion, never inflates), hence Minor not Major. Fix: match the marker on the final line only, and/or require `LAST_STATE != APPROVED` for the `RESULT_ESC` leg.

### F-002 (Minor, error-handling) — harness crash / operator interrupt still loses the in-flight row
NFR-4 claims "no lost rows by construction," but the row is written only after classification; a mid-arm `set -eu` abort, SIGINT, or operator steer still loses the started trial — exactly the class that lost pilot-1's in-flight t05 RAW row (`benchmark/RESULTS.md:106`, "recorded nowhere"). The spec's termination guarantee (G2) covers arm hang/timeout, which the plan does fix; this residual is external, hence Minor. Cheap hardening: `trap` INT/TERM in `run.sh` to emit an `outcome=error,notes=interrupted` row for any started-but-unwritten trial.

### F-003 (Minor, verification-integrity) — AC-F-04 has no carve-out for a legitimately empty `tier`
AC-F-04 requires "every HEATWAVE row … non-empty `tier`," but the plan's own Error Handling section admits `state.yaml` may be absent (arm timed out before intake wrote it, or driver never opened a run) → `TIER` empty. The AC as written then fails on an honestly-recorded row. Mirror the STANDARD/FULL clause: an empty tier passes only with the row unedited and RESULTS disclosing it as a finding.

### F-004 (Minor, verification-integrity) — AC-F-02/03's orphan check cannot see a leaked stub
`pgrep -f 'claude -p'` matches the real binary name; the forced-outcome tests run `CLAUDE_BIN=<stub>`, so a leaked stub (or its `sleep 300` child) would not match the pattern and the "no orphan processes" assertion is vacuous for exactly the processes those tests spawn. The group-kill mechanism itself is E-verified (F-004 in E), so Minor. Fix: also `pgrep -f` the stub path / `sleep 300` in the stub tests' evidence.

### F-005 (Minor, verification-integrity) — R-113 red leg is archival, not the executable check run red
AC-F-03's "Red" is pilot-1's retained kill evidence (0-byte transcripts, verified real by this reviewer), not the green command run against pre-fix code — and it *cannot* be as written: pre-fix `run.sh` hardcodes `HW_DEADLINE=2700` (run.sh:10) and calls literal `claude` (run.sh:52), so `CLAUDE_BIN=… HW_DEADLINE=20` has no effect on it; a faithful red would be a 45-minute paid run. The archival red is the pragmatic, honest choice, but R-113 (planner half, protocol/planner.md:55) expects this stated explicitly. Add one sentence to AC-F-03 declaring the red leg is the retained pilot-1 artifact per R-64, with the reason above.

### F-006 (Nit, docs) — sanitizer mangles model names in a public CSV
Verified by running the plan's `parse-result.py` verbatim on the real t03 result: `modelUsage` key `claude-opus-5[1m]` → `ST_MODEL=claude-opus-51m` (brackets stripped). In a credibility artifact a nonexistent-looking model name invites doubt. Allow `[]` in the charset (safe — no shell metacharacter risk inside a quoted assignment consumed by this parser's own `KEY=value` lines) or map the name.

### F-007 (Nit, docs) — METHODOLOGY control 7 canary wording not explicitly in T5's edit list
The canary adaptation ("fails to reach a terminal state" → `outcome != graded`) changes METHODOLOGY §4 control 7's text; T5 lists §1/§4-control-6/§5 edits but not control 7. The 45-min leg is subsumed by the timeout outcome, so behavior matches — just name the edit so run.sh and METHODOLOGY stay verbatim-synced per the plan's own docs-consistency category.

### F-008 (Nit, completeness) — strongest slow-not-stuck datum uncited in the plan's evidence list
The killed rows t01/t02 both graded `visible_pass=1, oracle_pass=1` (verified in `benchmark/results/pilot-20260811.csv`) — the code work was *complete* when the watchdog fired, which is materially stronger evidence for H1 (slow-but-progressing, loop in review ceremony) than anything in the plan's §"Evidence already in hand." RESULTS.md:52–60 records it; T1(a) should cite it.

## Verification Log

Machine evidence (R-110, PLAN_REVIEW posture — checks executable at plan stage run by this reviewer):

| Rung | Tool | Verdict | Evidence |
|---|---|---|---|
| build/drift | `sh build-protocol.sh --check` | PASS | `OK: PROTOCOL.md matches protocol/ shards` |
| corpus gate | `sh benchmark/check-corpus.sh` | PASS | `check-corpus: ALL TASKS PASS` (8/8) |
| sast / mutation | — | NOT_AVAILABLE | sh/awk/Markdown, no declared tool — matches plan's Tooling Declaration; leaves no AC unverified |

| Item | Method | Result | Evidence |
|---|---|---|---|
| Plan's HEAD claim | `git rev-parse --short HEAD` | Confirmed | `5d4562f` |
| Killed rows = 0-byte transcripts | `ls -la` transcript dirs | Confirmed | t01 + t02 `agent.json`/`agent.err` all 0 bytes; t03 `agent.json` 3740 bytes |
| t03 terminal at APPROVED, LIGHT, 2602 s, $12.37 | Read `t03-log-summary-trial1/agent.json` | Confirmed | `subtype:success`, `terminal_reason:completed`, result text "reached **APPROVED**", protocol trail shows tier LIGHT |
| Killed rows' wall vs deadline | Pilot CSVs | Confirmed | t01 3236 s (536 s past 2700), t02 2709 s — plan's kill-latency concern (fact 4) is real |
| `claude -p` cannot block on stdin (plan fact 3) | t03 transcript: session *exited* with an open question to the OWNER ("say the word…") as its result | Consistent (not independently exhaustive) | The one observed ask-the-human moment ended the process, exactly as the plan predicts; H4 remains open and T1 covers it |
| `autonomy` is a RESERVED dead knob | Grep protocol/ | Confirmed | core.md:266 "recorded only, no branching (YAGNI)"; core.md:274 "consulted by nothing" — plan's T6 correctly refuses the spec §4.2 suggestion to "use C's autonomy field" and routes termination through the harness |
| `state.yaml` has `state:` + `tier:` fields | orchestrator.md:86–95 | Confirmed | Plan's sed extraction and tier-recording are grounded |
| `CLAUDE_BIN` seam + `${var:+--flag "$var"}` quoting | Executed a stub reproduction of the plan's `run_agent` expansion under `/bin/sh` | Works as described | Multi-word `--append-system-prompt` arrives as ONE arg; stub substitutes for the binary; `install.sh` copies files only (no `claude` invocation), so the seam covers the sole binary call |
| `parse-result.py` on real/truncated/0-byte input | Executed verbatim against t03 result, a 2000-byte truncation, and t01's 0-byte file | Works; graceful | Correct COST/SUBTYPE on t03; empty fields (no crash) on truncated + empty — classification falls through as designed. Also surfaced F-006 |
| Scoring rule vs spec §3 | Read plan awk + METHODOLOGY text | Conforms | `esc`/`ora` summed only for `outcome=="graded"`; completion rate + outcome breakdown always printed; AC-F-06(c) forbids any delta sentence without ≥1 graded row in BOTH arms; timeouts/escalations always in the outcome table — no path found to score "didn't finish" as a defect or to hide a timeout |
| R-95 stopping points 2–3 vs unattended prompt | orchestrator.md:105–115 | Conforms | Prompt converts exactly points 2–3 into terminal recorded outcomes; point 1 unchanged; no gate altered |
| E invariants preserved | Read run.sh (F-001 scratch assert lines 79–82, withheld assert 100–102, post-exit oracle copy 121, manifest 148–149, grep 151) vs plan | Preserved and extended | Grep surface widened to `agent.ndjson` + `heatwave-runs/`; corpus untouched |
| Bounded rerun | Plan FR-8/T7 vs E's breaker (run.sh:63–70) | Conforms | Canary → pre-committed first-3 subset; $60/14400 s/3× canary breaker unchanged; forced-condition tests $0 by stub |

Not verified:

| Item | Reason | Criteria affected |
|---|---|---|
| `claude -p` never blocks on stdin, universally | Would need paid probes across scenarios; single-instance evidence (t03) only | None — the plan itself treats this as a hypothesis-supporting fact, keeps H2/H4 open, and gates the fix decision on T1's instrumented run |
| Actual tier the rerun arms will choose | Future paid runs | AC-F-04 — verifiable then by the AC's own awk command; t03's LIGHT intake makes the expectation grounded |

## Summary

APPROVED. Zero Blockers, zero Majors.

**Diagnosis:** evidence-backed, not assumed — and honestly framed. The plan explicitly demotes the spec's "waits forever for a human" story to a hypothesis, verifies the pilot's killed rows are 0-byte (I confirmed), cites t03's clean APPROVED terminal (confirmed: LIGHT tier, 2602 s — grazing the 2700 s deadline), and keeps four candidate causes open. Critically, the fix is designed to be robust under all four, and T1 orders the instrumented diagnosis run FIRST with "no fix code before its finding is recorded" plus concrete T9 trigger criteria — so nothing is locked on an unverified diagnosis.

**Scoring honesty:** sound. Timeout/escalated/error rows are excluded from the escape denominator and mandatorily reported as a separate completion rate with a full outcome breakdown; the awk enforces it mechanically; AC-F-06(c) blocks any delta sentence unless both arms have graded runs. I found no path to a misleading headline.

**Termination:** guaranteed at the harness level — marker-before-TERM, streaming transcripts that survive the kill, total classification, row-per-started-trial. The residuals are external (operator interrupt, F-002) and small.

**Tier:** recorded, never forced; the plan correctly identifies `autonomy` as a dead reserved knob (verified against core §2.5) and quietly corrects the spec's suggestion to use it — termination comes from the harness prompt + wall-clock, not phantom config.

**Scope:** benchmark-only with T9 properly contingent on T1 evidence; E's oracle isolation, corpus freeze, and breaker preserved and re-verified live.

The five Minors are tightening fixes (classification precedence, interrupt trap, one AC edge, stub-aware orphan check, an R-64 sentence for the archival red leg) — none blocks the gate; carry them into implementation.

## Gate

**APPROVED** — proceed to IMPLEMENTING. Minors F-001..F-005 to be addressed or explicitly dispositioned in the Implementation Package.
