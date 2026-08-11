# Planning Document — Benchmark Runtime Fix + Conclusive Rerun (Heatwave v4, Sub-project E2)

task_id: 2026-08-11-benchmark-runtime-fix | artifact_type: planning-document | iteration: 1 | produced_by: PLANNER (claude-fable-5) | timestamp: 2026-08-11

Spec (source of truth): `docs/specs/2026-08-11-benchmark-runtime-fix-design.md` (APPROVED).
Repo: `/Users/abhirajsinha/Projects/heatwave`, branch `main` (A–F merged; verified: HEAD `5d4562f`, `sh build-protocol.sh --check` prints `OK: PROTOCOL.md matches protocol/ shards`).
Builds on: E (`benchmark/`), plan `docs/superpowers/plans/2026-08-11-credibility-benchmark.md`. E's F-001 oracle isolation, corpus freeze (`cfeaf8f`), canary + cumulative breaker are preserved unchanged.

## Tier

**FULL** — the diff is mostly `benchmark/` (harness + docs), which alone would argue STANDARD. It is FULL for the same reason E was: the artifact is the project's **public credibility number**. E2 rewrites `RESULTS.md` from a fresh paid rerun and locks the scoring rule that decides what counts as a defect versus a completion failure — a subtly wrong scoring rule or a fabricated/hidden row breaks the project's central claim in public, the reputational equivalent of "anything touching money" (§0.5 FULL). Additionally, the diagnosis task MAY prove a genuine headless-orchestrator defect, in which case this run touches `protocol/` (a real rule change + `PROTOCOL.md` regen + drift check) — a cross-cutting change that is FULL by definition. FULL's mutation rung is NOT AVAILABLE honestly (shell + awk + Markdown; see Tooling Declaration).

Change class: **bugfix** — E's pilot demonstrated a concrete defect: the HEATWAVE arm fails to reach a recorded terminal outcome (t01 killed at 3236 s with a **lost** row — empty `agent.json`/`agent.err`). R-113 applies: the plan includes a failing reproduction criterion (AC-F-03 red-then-green: the old harness loses the row on deadline kill; the fixed harness records a terminal `timeout` row — demonstrated with a zero-cost stub, so the reproduction is deterministic and free).

## Problem Statement

E's pilot was honest but inconclusive: HEATWAVE t01 ran 3236 s and t02 2709 s before being watchdog-killed, leaving **empty transcripts and no recorded terminal outcome** — so the RAW-vs-HEATWAVE escaped-defect delta is uncomputable, and worse, the evidence needed to say *why* those runs didn't finish was destroyed by the kill (`--output-format json` buffers everything; a killed process writes nothing). E2 must: (1) **diagnose** the actual non-termination cause with evidence; (2) make the HEATWAVE arm **always terminate with a recorded outcome** when unattended — escalation/owner-decision → terminal `escalated` row, wall-clock expiry → terminal `timeout` row with elapsed + cost + last protocol state, never a lost row; (3) verify the arm runs the tier a real user gets (single-file fixes → LIGHT/EXPRESS, recorded, never forced); (4) **rerun** the bounded pilot so every arm terminates, and rewrite `RESULTS.md` conclusively with the locked scoring rule (spec §3): escaped-defect rate over gradable runs AND a separate completion rate — never scoring "didn't finish" as a shipped defect, never hiding a timeout.

## Evidence already in hand (pre-read; the diagnosis task confirms or refutes)

Read during planning from the retained pilot artifacts — recorded here so the IMPLEMENTER starts from facts, not the spec's hypothesis:

1. **Killed runs left zero transcript.** `benchmark/results/transcripts/20260811T115121Z-heatwave/t01-pagination-trial1/agent.json` and `agent.err` are both **0 bytes**; same for t02. `--output-format json` writes only at process exit, so the watchdog kill destroyed all in-flight evidence. Consequence (a): the pilot transcripts **cannot** distinguish escalation-wait from slow-but-progressing — this is an instrumentation defect in the harness that E2 must fix regardless of the hang cause. Consequence (b): the spec's §1 statement "stops at escalation/owner-decision … waits forever" is a *hypothesis*, not yet an evidenced diagnosis.
2. **The one terminal HEATWAVE run argues "slow, not stuck."** t03 terminated on its own: `subtype: success`, `terminal_reason: completed`, 32 turns, 2602 s, $12.37, result text "reached **APPROVED** — stopping point (1) of R-95" (`.../t03-log-summary-trial1/agent.json`). t02 was killed at 2709 s ≈ the 2700 s deadline — i.e. it may have simply needed a few more minutes.
3. **A literal wait-for-human is unlikely in this mode.** `claude -p` is one-shot: when the model stops to ask a question, the process **exits** (with the question as the result) — it cannot block on stdin. So "waits forever for the OWNER" would manifest as a *short* session ending with a question (non-empty agent.json), which is not what t01/t02 show. The plausible causes are: **H1 slow-but-progressing** (many role subagent dispatches ≈ 40+ min even on trivial tasks), **H2 mid-run stall** (a subagent/API call hung), **H3 tier inflation** (intake classified the single-file task STANDARD/FULL, multiplying dispatches), **H4 escalation loop** (driver re-prompting itself around an owner decision). The fix below is robust under all four (spec requirement), and T1 determines which actually occurred.
4. **The kill path itself is imperfect:** t01's recorded wall is 3236 s against a 2700 s deadline — 536 s unaccounted after TERM/KILL should have landed. The graceful-timeout rework must also verify enforcement latency (AC-F-03 checks wall ≈ deadline + grace).

## Functional Requirements

- FR-1 **Diagnosis (first, evidence-producing).** Before any fix lands: read the retained pilot transcripts and run ONE instrumented HEATWAVE arm on the smallest corpus task (t01-pagination) with streaming transcript + a 30 s `state.yaml` sampler, bounded at 2700 s / $15. Deliverable: a Diagnosis section in the Implementation Package identifying the terminal/hang point (H1–H4) with quoted transcript/state-timeline evidence, and the harness-only vs protocol-touch decision it forces.
- FR-2 **Unattended termination.** The HEATWAVE arm runs with an unattended profile (verbatim `--append-system-prompt`, disclosed in METHODOLOGY): no human exists; reaching ESCALATED or any blocking OWNER decision (R-95 points 2–3) means write the Escalation Report + `state: ESCALATED`, emit a final `ARM_OUTCOME: ESCALATED - <reason>` line, and end the session. The harness classifies the row `outcome=escalated` (terminal, reason in `notes`) from `state.yaml` and/or the result marker. This is harness-level; `protocol/` is untouched unless FR-1's diagnosis proves a driver defect (then T9).
- FR-3 **Graceful terminal timeout.** Per-task wall-clock expiry (HW 2700 s default, env-overridable) SIGTERMs the arm's process group (grace 10 s, then KILL) **and records a terminal `timeout` row** with elapsed, best-effort cost, and last protocol state — never a lost/killed row. The streaming transcript (`agent.ndjson`) survives the kill as evidence.
- FR-4 **Instrumentation that survives death.** Both arms switch `--output-format json` → `--output-format stream-json --verbose` (same flags both arms — symmetry preserved), transcript streamed to `agent.ndjson`; the HEATWAVE arm additionally gets a background `state.yaml` sampler (`state-timeline.log`) and `.heatwave/runs/` copy-back into `benchmark/results/transcripts/`.
- FR-5 **Tier recorded, not forced.** The harness reads the tier the driver actually chose from the scratch's `.heatwave/runs/*/state.yaml` into a `tier` CSV column. Expected: LIGHT or EXPRESS (single-file fixes, R-101/R-103). Nothing in the invocation dictates a tier; if the driver classifies higher, that is recorded honestly and reported in RESULTS as a Heatwave intake finding — not overridden, not hidden.
- FR-6 **Disclosed optional model.** `HW_MODEL` env var optionally routes the HEATWAVE arm to a configured model via `--model` (C's R-116 spirit: disclosed speedup, protocol gates unchanged). The serving model is recorded per row (`stage_model`, parsed from the result JSON's `modelUsage`, so it is recorded even when `HW_MODEL` is unset). Default: unset — both arms on the session model. If used in the rerun, RESULTS discloses the asymmetry explicitly.
- FR-7 **Scoring (spec §3, locked).** New CSV columns `outcome` (`graded|timeout|escalated|error`) and `terminal`. `summarize.awk` computes: escaped-defect rate **over `graded` rows only**; a separate **completion rate** (graded ÷ attempted) per arm; an outcome breakdown. Timeout/escalated/error rows are completion failures — excluded from the escape denominator, always reported, never scored as shipped defects.
- FR-8 **Conclusive bounded rerun.** After free self-tests pass (check-corpus 8/8, fixture sweeps, stub-forced timeout + escalation rows): rerun RAW on all 8 tasks (fresh rows under the new schema; ~$1.70 at pilot rates), then HEATWAVE canary t01 first, remainder gated by E's canary rule (adapted: canary `outcome != graded` or cost > $15 → pre-committed first-3 subset) and the unchanged cumulative breaker ($60 / 4 h / 3× canary). Every row terminal-outcome-recorded.
- FR-9 **RESULTS.md rewritten conclusively** from the rerun CSV: per-arm escaped-defect rate over gradable runs, HEATWAVE completion rate K/M, mean wall + cost, outcome table, and a plain honest reading — including "delta still uncomputable, here is the completion/cost profile" if that is what the data shows. The old pilot files stay committed as history, referenced as pilot 1.
- FR-10 **E invariants preserved:** out-of-repo `mktemp` scratch + fatal path assert, oracle copied in only post-exit, corpus manifest immutability check, transcript grep (now covering `agent.ndjson` and the copied `.heatwave/runs/` artifacts), fixture arms, `--only/--tasks/--trials` interface.

## Non-Functional Requirements

- NFR-1 **Zero new runtime dependencies:** `/bin/sh`, `python3` (stdlib), `git`, `shasum`, `awk`, `claude` — all verified present (claude CLI 2.1.227 exposes `--output-format stream-json`, `--verbose`, `--append-system-prompt`, `--model`). One new small file (`benchmark/parse-result.py`, stdlib-only) is code, not a dependency.
- NFR-2 **Bounded spend:** diagnosis run ≤ $15 / 2700 s; rerun under E's caps (per-task 2700 s HW / 900 s RAW; cumulative $60 / 14400 s / 3× canary). All forced-condition tests (timeout, escalation) use a stub binary — $0.
- NFR-3 **Determinism of the free path:** fixture-good/fixture-bad sweeps and the stub-forced outcome tests are deterministic and complete in < 5 min total.
- NFR-4 **No lost rows:** every started (task, arm, trial) produces exactly one CSV row with a definitive `outcome` — enforced by construction (row written after classification, classification total).

## Architecture

No new components. `benchmark/run.sh` is extended (ponytail: extend E's harness, don't rewrite), `summarize.awk` reworked for the new schema, one new helper `benchmark/parse-result.py`, docs updated. Control flow per (task, arm, trial):

```
scratch = mktemp outside repo  (unchanged, F-001)
copy repo/* + SPEC.md          (unchanged; withheld-set assert unchanged)
[heatwave] install.sh + skill pre-create (unchanged, F-002/F-005)
[heatwave] start state sampler (30s) ────────────┐ new
run arm: claude -p … --output-format stream-json │ new (both arms)
         [heatwave] --append-system-prompt UNATTENDED, optional --model $HW_MODEL
         under with_deadline(+ DL_MARK marker file)  ← new: expiry leaves a marker
classify OUTCOME/TERMINAL/TIER/STAGE_MODEL       │ new (total function, §State Mgmt)
grade visible + oracle (unchanged; supplementary for non-graded outcomes)
CSV row (new schema) + copy-back (+ agent.ndjson, state-timeline.log, .heatwave/runs/)
breaker / canary check (adapted to outcome)
```

### Harness changes — actual code

**Top of `run.sh` (new knobs; defaults reproduce real-run behavior):**

```sh
RAW_DEADLINE=${RAW_DEADLINE:-900} HW_DEADLINE=${HW_DEADLINE:-2700}   # env-overridable: stub tests use tiny values
CLAUDE_BIN=${CLAUDE_BIN:-claude}   # self-test seam: stub binary for zero-cost forced-outcome tests (disclosed)
HW_MODEL=${HW_MODEL:-}             # optional disclosed model for the heatwave arm (FR-6); unset = session model

HW_UNATTENDED="UNATTENDED RUN: no human OWNER is available and none will respond, ever. If this run reaches ESCALATED or any blocking OWNER decision (R-95 stopping points 2-3), do NOT wait and do NOT end with an open question: write the Escalation Report artifact, set state: ESCALATED in state.yaml, make your final output line exactly 'ARM_OUTCOME: ESCALATED - <one-line reason>', and end the session. A run reaching APPROVED ends with final line 'ARM_OUTCOME: APPROVED'."
```

**`with_deadline` — marker on expiry (grace unchanged):**

```sh
with_deadline() {  # $1=secs, rest=cmd. Kills the PROCESS GROUP (F-004). On expiry
                   # touches "$DL_MARK" (when set) BEFORE TERM — the timeout is
                   # recorded even if the arm dies uncleanly.
  secs=$1; shift
  set -m
  "$@" & pid=$!
  set +m
  ( t0=$(date +%s)
    while kill -0 "$pid" 2>/dev/null; do
      if [ $(( $(date +%s) - t0 )) -ge "$secs" ]; then
        [ -n "${DL_MARK:-}" ] && : > "$DL_MARK"
        kill -TERM -- -"$pid" 2>/dev/null; sleep 10; kill -KILL -- -"$pid" 2>/dev/null; exit 0
      fi
      sleep 5
    done ) & wd=$!
  st=0; wait "$pid" || st=$?
  kill "$wd" 2>/dev/null || true
  return "$st"
}
```

**`run_agent` — streaming output, optional model + system prompt, result parse:**

```sh
run_agent() {  # $1=scratch $2=deadline-secs $3=prompt [$4=append-system-prompt].
               # Sets COST SUBTYPE ST_MODEL RESULT_ESC. Returns arm exit status.
  _scratch=$1; _deadline=$2; _prompt=$3; _sys=${4:-}
  _st=0
  ( cd "$_scratch" && DL_MARK="$_scratch/deadline.expired" with_deadline "$_deadline" \
      "$CLAUDE_BIN" -p --setting-sources project --dangerously-skip-permissions \
        --output-format stream-json --verbose \
        ${ARM_MODEL:+--model "$ARM_MODEL"} \
        ${_sys:+--append-system-prompt "$_sys"} \
        "$_prompt" > agent.ndjson 2> agent.err ) || _st=$?
  eval "$(python3 "$BENCH/parse-result.py" "$_scratch/agent.ndjson")"
  return "$_st"
}
```

**`benchmark/parse-result.py` (new; stdlib; emits shell-safe `KEY=value` only — values sanitized to `[A-Za-z0-9._$-]`, everything else stripped):**

```python
#!/usr/bin/env python3
"""Parse the last type=result event from a stream-json transcript.
Emits shell-assignable lines. Tolerates a truncated final line (killed run)."""
import json, re, sys
cost = sub = model = ""
esc = "0"
try:
    for line in open(sys.argv[1], errors="replace"):
        try:
            d = json.loads(line)
        except ValueError:
            continue  # truncated tail line from a killed process
        if d.get("type") == "result":
            v = d.get("total_cost_usd"); cost = "" if v is None else str(v)
            sub = str(d.get("subtype", ""))
            mu = d.get("modelUsage") or {}
            model = ";".join(sorted(mu))
            if "ARM_OUTCOME: ESCALATED" in str(d.get("result", "")): esc = "1"
except OSError:
    pass
clean = lambda s: re.sub(r"[^A-Za-z0-9._$;-]", "", s)
print(f"COST={clean(cost)}"); print(f"SUBTYPE={clean(sub)}")
print(f"ST_MODEL={clean(model)}"); print(f"RESULT_ESC={esc}")
```

**Arm dispatch in the task loop (replaces the current `raw)`/`heatwave)` branches):**

```sh
      raw)      ARM_MODEL= run_agent "$SCRATCH" "$RAW_DEADLINE" "$RAW_PROMPT" || NOTE="agent-nonzero" ;;
      heatwave) mkdir -p "$SCRATCH/.claude/skills/ui-ux-pro-max"     # F-002: no network clone
                sh "$REPO/install.sh" "$SCRATCH" claude > "$SCRATCH/install.log" 2>&1 \
                  || NOTE="install-failed"                           # F-005
                if [ "$NOTE" != "install-failed" ]; then
                  ( while :; do { date -u +%FT%TZ; cat "$SCRATCH"/.heatwave/runs/*/state.yaml 2>/dev/null; echo --; } \
                      >> "$SCRATCH/state-timeline.log"; sleep 30; done ) & SAMPLER=$!
                  ARM_MODEL="$HW_MODEL" run_agent "$SCRATCH" "$HW_DEADLINE" "$HW_PROMPT" "$HW_UNATTENDED" \
                    || NOTE="agent-nonzero"
                  kill "$SAMPLER" 2>/dev/null || true
                fi ;;
```

**Outcome classification (new, after `WALL=` and before grading; total — every path assigns):**

```sh
    LAST_STATE=$(sed -n 's/^state:[[:space:]]*//p' "$SCRATCH"/.heatwave/runs/*/state.yaml 2>/dev/null | tail -1)
    TIER=$(sed -n 's/^tier:[[:space:]]*//p' "$SCRATCH"/.heatwave/runs/*/state.yaml 2>/dev/null | tail -1)
    case "$ARM" in fixture-good|fixture-bad) OUTCOME=graded TERMINAL=1 ;; *)
      if [ -f "$SCRATCH/deadline.expired" ]; then
        OUTCOME=timeout TERMINAL=0 NOTE="timeout; last_state=${LAST_STATE:-none}${NOTE:+; $NOTE}"
      elif [ "$ARM" = heatwave ] && { [ "${LAST_STATE:-}" = ESCALATED ] || [ "${LAST_STATE:-}" = ABANDONED ] \
          || [ "${RESULT_ESC:-0}" = 1 ]; }; then
        OUTCOME=escalated TERMINAL=1 NOTE="escalated; state=${LAST_STATE:-unrecorded}${NOTE:+; $NOTE}"
      elif [ "${SUBTYPE:-}" = success ] && { [ "$ARM" = raw ] || [ "${LAST_STATE:-}" = APPROVED ]; }; then
        OUTCOME=graded TERMINAL=1
      else
        OUTCOME=error TERMINAL=0 NOTE="error; subtype=${SUBTYPE:-none}; last_state=${LAST_STATE:-none}${NOTE:+; $NOTE}"
      fi ;;
    esac
```

(`ABANDONED` is a protocol-terminal state that ships no gradable code → completion failure, bucketed `escalated`; noted in METHODOLOGY. A `subtype=success` heatwave exit whose state is neither APPROVED nor ESCALATED is a **stranded** session — R-96 violation, `outcome=error` with the state named. Grading still runs for every outcome; VIS/ORA on non-`graded` rows are supplementary observations, exactly as pilot-1's RESULTS treated them.)

**CSV row + copy-back (schema in Data Design):**

```sh
    echo "$RUN_ID,$ID,$ARM,$trial,$OUTCOME,$TERMINAL,$TIER,${HW_MODEL:-$ST_MODEL},$VIS,$ORA,$ESC,$WALL,$COST,$NOTE" >> "$CSV"
    DEST="$TRANSCRIPTS/$ID-trial$trial"; mkdir -p "$DEST"
    for f in agent.ndjson agent.err visible.log oracle.log install.log state-timeline.log deadline.expired; do
      [ -f "$SCRATCH/$f" ] && cp "$SCRATCH/$f" "$DEST/" || true
    done
    [ -d "$SCRATCH/.heatwave/runs" ] && cp -R "$SCRATCH/.heatwave/runs" "$DEST/heatwave-runs" || true
```

**Canary rule adaptation (breaker `break_tripped` unchanged):** E's canary condition "fails to reach a terminal state" becomes `outcome != graded` — i.e. `if [ "$ARM" = heatwave ] && [ "$count" -eq 1 ] && { [ "$OUTCOME" != graded ] || cost > 15; }` → fall back to the pre-committed first-3 lexical subset (mechanism unchanged from E's T10; the subset was pre-committed before pilot 1 and is not re-chosen).

**Transcript grep (detective control) — extended to the new evidence:**

```sh
if grep -rl -e 'benchmark/corpus' -e 'oracle' \
    "$TRANSCRIPTS"/*/agent.ndjson "$TRANSCRIPTS"/*/agent.err "$TRANSCRIPTS"/*/heatwave-runs 2>/dev/null; then
  echo "WARNING: possible oracle/corpus reference in agent evidence — investigate before using results" >&2
fi
```

### `summarize.awk` — full replacement (new schema, spec-§3 scoring)

```awk
# Metric computation (E2 schema). gradable = outcome "graded"; timeout/escalated/
# error rows are completion failures: excluded from the escape-rate denominator,
# reported as their own rate — never hidden, never scored as shipped defects.
# Columns: 1 run_id 2 task 3 arm 4 trial 5 outcome 6 terminal 7 tier 8 stage_model
#          9 visible_pass 10 oracle_pass 11 escaped_defect 12 wall_secs 13 cost_usd 14 notes
NR > 1 && $2 != "" {
  arm = $3; total[arm]++; oc[arm "," $5]++
  if ($5 == "graded") { graded[arm]++; ora[arm] += $10; esc[arm] += $11 }
  wall[arm] += $12
  if ($13 != "") { cost[arm] += $13; costed[arm]++ }
}
END {
  for (arm in total) {
    printf "%s: completed=%d/%d", arm, graded[arm], total[arm]
    if (graded[arm] > 0)
      printf " escaped_defects=%d/%d gradable (rate=%.3f) oracle_pass=%d/%d", \
        esc[arm], graded[arm], esc[arm] / graded[arm], ora[arm], graded[arm]
    else
      printf " escaped_defects=N/A (0 gradable runs)"
    printf " outcomes[graded=%d timeout=%d escalated=%d error=%d]", \
      oc[arm ",graded"], oc[arm ",timeout"], oc[arm ",escalated"], oc[arm ",error"]
    printf " mean_wall=%.1fs", wall[arm] / total[arm]
    if (costed[arm] > 0) printf " total_cost=$%.4f (over %d costed rows)", cost[arm], costed[arm]
    printf "\n"
  }
}
```

### METHODOLOGY.md — the scoring + unattended text (actual wording to land)

```markdown
## Scoring: completion vs escaped defects (E2, locked)

Every started (task, arm, trial) produces exactly one row with an `outcome`:
`graded` (the arm ended at its own terminal state with gradable code),
`timeout` (per-task wall-clock expired; row records elapsed, best-effort cost,
and the last protocol state), `escalated` (the protocol run terminated at
ESCALATED/ABANDONED — no shippable code), or `error` (nonzero exit or a
stranded session). Only `graded` rows enter the escaped-defect denominator:
**escape rate = escaped defects ÷ graded rows, per arm.** All other outcomes
are **completion failures**, reported as their own rate (completed ÷
attempted) and in an outcome table. A run that did not finish is never scored
as a shipped defect, and never dropped from the table. Rationale: "didn't
finish" and "shipped a bug" are different failures; conflating them in either
direction would misstate whichever arm it touches. Visible/oracle results on
non-graded rows, when present, are supplementary observations about partial
work products, not completed-arm results.

## Unattended profile (HEATWAVE arm)

The HEATWAVE arm appends this system prompt verbatim (constant `HW_UNATTENDED`
in `run.sh` — do not edit one without the other): [verbatim HW_UNATTENDED text]
This makes escalation a *recorded terminal outcome* instead of a stranded
session; it does not change any protocol gate. The per-task wall-clock
(RAW 900 s / HEATWAVE 2700 s, env-overridable) is the backstop: expiry writes
a terminal `timeout` row (elapsed + cost + last state), then TERM/KILLs the
process group. Transcripts stream (`agent.ndjson`), so a timed-out run still
leaves full evidence. The tier the driver chose at intake and the serving
model are recorded per row (`tier`, `stage_model`); an optional `HW_MODEL`
override for the HEATWAVE arm is a disclosed asymmetry, off by default.
```

Also updated in METHODOLOGY: §1 metrics (add completion rate), §4 control 6 (graceful timeout replaces kill-with-no-row), §5 threats (drop the now-fixed "empty transcript" blind spot; keep deadline-choice influence; add "unattended prompt is an arm-only instruction — disclosed verbatim").

## API Design

N/A — no service API. The CSV schema (Data Design) and the `run.sh` CLI (`--arm/--tasks/--trials/--only` unchanged; new env knobs `HW_DEADLINE`, `RAW_DEADLINE`, `CLAUDE_BIN`, `HW_MODEL`) are the only contracts.

## Data Design

CSV header (breaking change vs pilot-1 CSVs — old files are untouched history; RESULTS.md pins which schema each file uses):

```
run_id,task,arm,trial,outcome,terminal,tier,stage_model,visible_pass,oracle_pass,escaped_defect,wall_secs,cost_usd,notes
```

- `outcome`: `graded | timeout | escalated | error` (total classification, §Architecture).
- `terminal`: 1 iff the arm process ended at its own protocol stopping point (`graded`/`escalated`); 0 for harness-enforced (`timeout`) or `error`. The spec's "terminal TIMEOUT row" requirement is satisfied by the row being *recorded with a definitive outcome*; `terminal` distinguishes self-stopped from harness-stopped.
- `tier`: from scratch `state.yaml` (heatwave arm; empty otherwise). `stage_model`: `HW_MODEL` when set, else `modelUsage` keys from the result event (empty for fixtures/killed-before-result).
- Old columns keep their meaning; `notes` carries `timeout; last_state=<STATE>` / `escalated; state=<STATE>` / error detail.
- Evidence tree per row gains `agent.ndjson`, `state-timeline.log`, `deadline.expired` (marker), `heatwave-runs/` (the run's `state.yaml`, `run-record.yaml`, numbered artifacts).

## State Management

All state is per-trial and on disk (scratch + copy-back); no cross-run state beyond the CSV. The classification function is **total**: marker file → `timeout`; protocol-terminal ESCALATED/ABANDONED or result marker → `escalated`; clean success (+ APPROVED for heatwave) → `graded`; everything else → `error`. Multiple `.heatwave/runs/*/state.yaml` files (driver misbehavior) resolve via `tail -1` after sorted glob and are visible in the copied `heatwave-runs/` for the reviewer.

## Error Handling Strategy

- Killed/truncated `agent.ndjson`: `parse-result.py` skips unparseable lines; absent result event → empty COST/SUBTYPE → classification falls through to `timeout` (marker present) or `error` — never a crash, never a lost row.
- `install-failed`: row still emitted (`outcome=error`, note preserved) — pilot-1 behavior kept.
- Sampler/watchdog leaks: sampler killed explicitly post-arm; AC-F-02/03 assert `pgrep -f 'claude -p'` and no stray sampler after each forced test.
- `state.yaml` absent (driver never created a run dir): `LAST_STATE`/`TIER` empty; classification still total; RESULTS flags it (a heatwave session that never opened a run is itself a finding).
- Grading commands keep their own 120 s `with_deadline` (DL_MARK unset there — no marker pollution).
- Breaker math with empty COST: unchanged from E (wall caps bind alone).

## Security Considerations

No new threat surface. The unattended system prompt contains no path, no oracle reference, and is committed verbatim. Oracle isolation is untouched: scratch outside the repo (fatal assert), withheld-set assert, oracle copied post-exit, manifest immutability, detective grep now covering the *larger* evidence surface (`agent.ndjson` + copied run artifacts). `CLAUDE_BIN` is a local test seam, default `claude`; it never runs in the paid rerun (AC-F-08's diff review covers it; METHODOLOGY discloses it as the self-test mechanism).

## Edge Cases

1. Arm escalates politely without writing `state.yaml` (prose only) → caught by `RESULT_ESC` marker grep on the parsed result field (not the raw stream — the system prompt echo can't false-positive).
2. Arm reaches APPROVED but exits nonzero (transient CLI error after result) → SUBTYPE=success + APPROVED → `graded`; the nonzero note is preserved.
3. Timeout lands during a subagent dispatch → group kill (F-004) reaps children; `state-timeline.log` + last state recorded.
4. `ABANDONED` terminal state → `escalated` bucket (completion failure; no gradable code) — documented in METHODOLOGY.
5. Stranded success (R-96 violation: session ends mid-state) → `error` with state named; counts against completion.
6. Driver classifies a corpus task STANDARD/FULL → recorded in `tier`, reported in RESULTS as an intake finding; never overridden by the harness (FR-5).
7. Cost unreported (subscription auth) → empty cost; wall caps bind (unchanged).
8. t0X row exists in pilot-1 CSV → old files untouched; new run-id CSVs only; RESULTS pins provenance.

## Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| Rerun still can't finish in 2700 s even at LIGHT tier | Medium | Now a *recorded* `timeout` outcome, not lost evidence — the completion-rate finding is itself the publishable result (spec G4); canary + subset + breaker bound spend |
| Diagnosis shows a genuine driver headless defect | Low (evidence §"in hand" points to slow-not-stuck) | T9 contingency: real rule change + regen + drift, FULL-tier review; pre-scoped below |
| Unattended prompt nudges the arm's *quality* (not just termination) | Low | Prompt only addresses R-95 stopping points 2–3; verbatim disclosure; reviewer checks wording against gates |
| `eval` of parser output | Low | Parser emits only sanitized `KEY=value` (charset-stripped); reviewer verifies |
| Stub seam (`CLAUDE_BIN`) used in a paid run by mistake | Low | Default `claude`; run header echoes the binary + model into the sweep log; AC evidence includes it |
| Schema break confuses old tooling | Low | Only `summarize.awk` consumes the CSV; replaced in the same commit; old CSVs untouched |
| Cheap-model asymmetry misused for a headline | Low | Default unset; if used, `stage_model` column + RESULTS disclosure are mandatory (AC-F-06) |

## Dependencies

Internal: E's `benchmark/` (present, frozen corpus `cfeaf8f` — manifest re-verified before the rerun), `install.sh` claude adapter path (present), `.heatwave` state layout (R-86). External: `claude` CLI 2.1.227 (verified: `stream-json`, `--verbose`, `--append-system-prompt`, `--model`, `--fallback-model` all present), `python3` `/opt/homebrew/bin/python3`, `awk` `/usr/bin/awk` (verified). No network beyond the model call (F-002 skip path retained). No new dependencies.

## Testing Strategy

Free/deterministic first, paid last (E's ordering kept):

1. **Static:** `sh -n benchmark/run.sh`; `python3 -m py_compile benchmark/parse-result.py`.
2. **Pipeline determinism:** `check-corpus.sh` 8/8; `fixture-good` sweep (0 escapes, all `outcome=graded`), `fixture-bad` sweep (8/8 escapes) — proves grading + new schema end-to-end at $0.
3. **Forced timeout ($0):** stub `CLAUDE_BIN` = a script that `sleep 300`s; `HW_DEADLINE=20` → expect one row `outcome=timeout`, `wall_secs` ≈ 20–35 (deadline + poll + grace), marker present, no orphan processes.
4. **Forced escalation ($0):** stub writes `.heatwave/runs/stub/state.yaml` with `state: ESCALATED`, emits a valid result event whose `result` contains `ARM_OUTCOME: ESCALATED - budget exhausted`, exits 0 → expect `outcome=escalated`, reason in notes, `terminal=1`.
5. **awk unit:** run `summarize.awk` over a hand-written 6-row CSV covering all four outcomes; expected output line committed alongside as evidence.
6. **Paid diagnosis (T1, ≤ $15):** one instrumented t01 run; evidence harvested regardless of outcome.
7. **Paid rerun (T7):** RAW ×8, HEATWAVE canary-gated, breaker-bounded; every AC-F-05/06/07 evidence captured from this sweep.

Reviewer (FULL tier, R-110 ladder): tests rung = items 1–5 re-run by the reviewer; sast/mutation = NOT AVAILABLE (shell/awk/Markdown — no declared tool in this repo); secrets rung at FINAL per R-121 if a scanner is present, else NOT AVAILABLE.

## Rollout Plan

Single-repo docs+benchmark change, committed to `main` after FINAL_REVIEW per house rules. Order: harness+docs commits (T2–T6) → free self-tests green → paid diagnosis already done (T1 precedes fixes; its evidence commits with the impl package) → paid rerun (T7) → RESULTS.md rewrite (T8). No flags, no staging. The old pilot CSVs/transcripts are never edited.

## Rollback Plan

`git revert` the E2 commits (they touch only `benchmark/**`, `docs/**`, and — only if T9 fired — `protocol/** + PROTOCOL.md`); the pre-E2 harness and pilot-1 RESULTS.md are restored intact. New `benchmark/results/*` files from E2 sweeps are additive data and can stay (they document real spend) — RESULTS.md provenance pins schema per file, so reverting docs cannot orphan them silently. If T9 fired and is reverted, run `sh build-protocol.sh` and re-verify `--check` prints `OK` before pushing the revert.

## Implementation task plan (ordered; diagnosis FIRST, paid rerun LAST)

- **T1 — DIAGNOSIS (evidence-producing; no fix code before its finding is recorded).**
  (a) Re-read retained pilot evidence and record the facts already listed in §"Evidence already in hand" with file paths.
  (b) ONE instrumented HEATWAVE run on t01-pagination (smallest task, the pilot's worst case), hand-driven (the fixed harness doesn't exist yet), bounded 2700 s / $15:
  ```sh
  S=$(mktemp -d "${TMPDIR:-/tmp}/hw-diag.XXXXXX")
  cp -R benchmark/corpus/t01-pagination/repo/. "$S"/ && cp benchmark/corpus/t01-pagination/SPEC.md "$S"/
  mkdir -p "$S/.claude/skills/ui-ux-pro-max" && sh install.sh "$S" claude > "$S/install.log" 2>&1
  ( while :; do { date -u +%FT%TZ; cat "$S"/.heatwave/runs/*/state.yaml 2>/dev/null; echo --; } \
      >> "$S/state-timeline.log"; sleep 30; done ) & W=$!
  ( cd "$S" && claude -p --setting-sources project --dangerously-skip-permissions \
      --output-format stream-json --verbose "<HW_PROMPT verbatim from run.sh>" \
      > agent.ndjson 2> agent.err ) ; kill $W
  ```
  (guarded by a 2700 s manual deadline; transcripts + timeline harvested into `benchmark/results/transcripts/diag-<ts>/` either way).
  Deliverable in the Implementation Package: hang/terminal point named (H1–H4) with quoted `state-timeline.log` + `agent.ndjson` evidence; the tier intake chose; per-state wall breakdown; the t01 3236 s-vs-2700 s kill-latency check; and the **decision**: harness-only (expected) or T9 protocol branch (only if the driver provably blocks/loops at an owner-decision point headless — e.g. timeline flat > 10 min at one state with no tool events in the stream, or a self-re-prompting escalation loop).
- **T2 — Harness fix** (`run.sh` + new `parse-result.py`): all §Architecture code — knobs, `DL_MARK`, stream-json, unattended prompt, sampler, classification, new CSV schema, copy-back, canary adaptation, extended grep. `sh -n` + `py_compile` green.
- **T3 — `summarize.awk` replacement** (full file above) + the 6-row unit CSV + expected output committed as evidence.
- **T4 — Forced-outcome self-tests ($0):** fixture-good/fixture-bad sweeps under the new schema; stub timeout test; stub escalation test (Testing Strategy 2–4) — each leaving its CSV + `pgrep` evidence in the impl package.
- **T5 — METHODOLOGY.md update:** scoring section + unattended profile (verbatim texts above), metric/controls/threat edits.
- **T6 — config decision (recorded, no file change expected):** `heatwave.config.example.yaml` untouched — the run-config `autonomy` field is RESERVED and consulted by nothing (core §2.5), so a config key would be a dead knob (YAGNI) and anything active would be a protocol change without diagnosis evidence. If T1's finding contradicts this, it routes through T9 instead. One line in the impl package records the decision.
- **T7 — Conclusive rerun (paid, bounded):** manifest + `check-corpus.sh` 8/8 first; then `sh benchmark/run.sh --arm raw` (8 tasks); then `sh benchmark/run.sh --arm heatwave --only t01-pagination` (canary) and, canary-gated, the remaining tasks (full 8 or pre-committed first-3 subset); cumulative breaker live throughout. `HW_MODEL` stays unset unless the canary's cost forces the disclosed-cheap-model option — recorded either way.
- **T8 — RESULTS.md rewrite** from T7's CSVs: outcome table per arm, escaped-defect rate over gradable, completion rate K/M, mean wall + cost, provenance (schema + freeze SHA + run-ids), honest reading (conclusive statement of whatever the data shows), forbidden-grep run and recorded.
- **T9 — CONTINGENT protocol fix (only if T1 proves a driver headless defect):** the minimal real rule change in `protocol/orchestrator.md` §9.4 (an unattended clause: when no OWNER channel exists, stopping points 2–3 still *end the session with the report* — they never idle), `sh build-protocol.sh` regen, `--check` = OK, drift + adapter text alignment; carried as a Deviation Record if it emerges mid-implementation. Expected: NOT NEEDED (three independent pre-read facts point to slow-not-stuck).

## Acceptance Criteria

### Functional

- **AC-F-01 (spec §8.1 — diagnosis recorded).** The Implementation Package contains a Diagnosis section naming the pilot non-termination cause (H1–H4) with (a) pilot-transcript facts incl. the 0-byte `agent.json` paths, and (b) quoted `state-timeline.log`/`agent.ndjson` evidence from the T1 instrumented run, plus the recorded harness-only/T9 decision. Verify: read the impl package; every quoted file exists under `benchmark/results/transcripts/diag-*/`.
- **AC-F-02 (spec §8.2 — no hang, escalation terminal).** Forced-escalation stub run: `CLAUDE_BIN=<stub> sh benchmark/run.sh --arm heatwave --only t01-pagination` → CSV row with `outcome=escalated`, reason in `notes`; immediately after: `pgrep -f 'claude -p'` empty. Verify: the run's CSV + a captured `pgrep` transcript (expected: no output, exit 1).
- **AC-F-03 (spec §8.3 — graceful terminal timeout; R-113 reproduction).** Red: pilot-1 evidence shows deadline kill ⇒ 0-byte transcripts and no outcome column (files named in AC-F-01). Green: `CLAUDE_BIN=<sleep-stub> HW_DEADLINE=20 sh benchmark/run.sh --arm heatwave --only t01-pagination` → CSV row `outcome=timeout`, `wall_secs` in [20, 40], `notes` contains `last_state=`, `deadline.expired` + `agent.ndjson` copied back; `pgrep -f 'claude -p'` empty. Verify: CSV row + transcript dir listing.
- **AC-F-04 (spec §8.4 — tier correctness).** Every HEATWAVE row in the T7 rerun CSV has a non-empty `tier`; expected value ∈ {EXPRESS, LIGHT} for these single-file tasks. Verify: `awk -F, '$3=="heatwave"{print $2,$7}' benchmark/results/<rerun>.csv`. If any row records STANDARD/FULL, the row stands unedited and RESULTS.md reports it as an intake-classification finding — the AC then passes only with that disclosure present.
- **AC-F-05 (spec §8.5 — conclusive rerun).** In the T7 CSVs every row has `outcome ∈ {graded,timeout,escalated,error}` (no lost rows: started tasks = CSV rows), and RESULTS.md reports per arm: escaped-defect rate over gradable, completion rate K/M, mean wall, cost, outcome table, and an explicit concluding paragraph. Verify: `awk` outcome audit over the CSVs + read RESULTS.md.
- **AC-F-06 (spec §8.6 — honesty).** (a) Forbidden-grep on RESULTS.md: `grep -nE '0/[0-9]|%|fewer bugs' benchmark/RESULTS.md` — every hit sits inside a caveated table/sentence per E's rule or the grep is clean; recorded either way. (b) Row trace: every number in RESULTS tables maps to a CSV row/aggregate (reviewer spot-audit, 100% of headline rows). (c) No delta sentence exists unless both arms have ≥ 1 `graded` row (and the sentence states the n). (d) If `HW_MODEL`/`stage_model` differ between arms, RESULTS discloses it adjacent to every cost/wall comparison. Verify: greps + read.
- **AC-F-07 (spec §8.7 — oracle isolation still holds).** Rerun evidence: `scratch-root.txt` path outside the repo; withheld-set assert untriggered; corpus manifest identical pre/post (harness exits fatally otherwise); transcript grep over `agent.ndjson`/`agent.err`/`heatwave-runs` zero hits (or dispositioned in RESULTS). Verify: recorded outputs in `benchmark/results/transcripts/<rerun>/`.
- **AC-F-08 (spec §8.8 — no regression).** `git diff --stat <pre-E2>..HEAD` touches only `benchmark/**` + `docs/**` (+ `protocol/** & PROTOCOL.md` iff T9 fired, with the diagnosis evidence cited in the commit); `sh build-protocol.sh --check` prints `OK`; `sh benchmark/check-corpus.sh` prints 8/8 PASS. Verify: command outputs captured in the impl package.

### Non-functional

- **AC-N-01 (bounded spend).** T1 ≤ $15 and ≤ 2700 s (recorded cost/wall in the diagnosis evidence). T7 cumulative ≤ $60 and ≤ 14400 s with the breaker armed (breaker constants unchanged in `run.sh`; sweep totals recorded in RESULTS). Verify: recorded numbers + code inspection.
- **AC-N-02 (zero new dependencies).** `git diff` introduces no package manifest, no install step, no binary; `parse-result.py` imports stdlib only (`json`, `re`, `sys`). Verify: diff + `grep -E '^import|^from' benchmark/parse-result.py`.
- **AC-N-03 (deterministic free path).** `fixture-good` sweep: 8/8 `outcome=graded`, 0 escapes; `fixture-bad`: 8/8 escapes; both under the new schema, together < 5 min wall. Verify: the two CSVs + `summarize.awk` output.
- **AC-N-04 (no lost rows, by construction).** Both stub tests and both fixture sweeps show rows-written == tasks-started; the classification `case` has no fall-through without an assignment (code inspection). Verify: CSV row counts + reviewer code read.

## Review Scope

Categories (Appendix C) — ✓ applies / ✗ N/A with reason:

- ✓ **Correctness** — outcome classification totality, awk arithmetic, POSIX sh (set -m, globs, quoting), parser truncation handling.
- ✓ **Verification-integrity** (hunt actively, FULL posture) — scoring rule vs spec §3; no fabricated/edited rows; forbidden-grep; delta discipline; disclosure of any model asymmetry; oracle isolation surface after the new copy-backs.
- ✓ **Error handling** — killed transcripts, absent state.yaml, sampler/watchdog cleanup, install-failed path.
- ✓ **Security** — unattended prompt content (no oracle/path leakage), `eval` of sanitized parser output, `CLAUDE_BIN` seam.
- ✓ **Docs consistency** — METHODOLOGY ↔ run.sh verbatim constants (prompts, unattended text), RESULTS provenance, spec §3 wording landed intact.
- ✓ **Cost-bound** — deadlines, canary adaptation, breaker unchanged.
- ✗ Performance — no latency-sensitive code; the harness's own overhead is seconds against multi-minute arms.
- ✗ Rate limiting — no service surface.
- ✗ Accessibility/UI — no UI.
- ✗ Data migration — CSV schema change creates new files only; old files are immutable history.
- ✗ Concurrency — one sequential sweep; the only background jobs (watchdog, sampler) are reviewed under Correctness/Error handling.

## Tooling Declaration (§6.1 — honest; never claim a tool not present)

- `unit`: none declared — this repo has no test framework; the executable checks are `sh -n`, `python3 -m py_compile`, `benchmark/check-corpus.sh`, fixture sweeps, stub-forced runs, and the awk unit CSV (all commands given in Testing Strategy; the reviewer re-runs them).
- `integration`/`web_e2e`/`load`: NOT AVAILABLE — N/A surface.
- `sast`: NOT AVAILABLE (no `semgrep` configured in this repo) — leaves no AC unverified (no AC depends on SAST); stated per R-64.
- `mutation` (FULL rung): NOT AVAILABLE for sh/awk/Markdown — leaves no AC unverified; the discrimination gate (`check-corpus.sh`) plays the adequacy role for the corpus itself.
- `secrets`: auto-detect at FINAL per R-121; if no scanner present → NOT AVAILABLE, stated.
- Paid tooling: `claude` CLI 2.1.227 (verified present with the exact flags used). Spend authority: bounded per AC-N-01.
- Docker / emulators / device farms: not used.
