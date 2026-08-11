# Design Spec — Credibility Benchmark (Heatwave Protocol v4, Sub-project E)

- **Date:** 2026-08-11
- **Status:** Draft, awaiting owner review
- **Scope:** Sub-project E of the Heatwave v4 redesign. A reproducible benchmark harness + bespoke seeded-bug corpus + methodology + a small pilot run.
- **Depends on:** A–D merged to main (the protocol the benchmark measures). Isolated: E adds a `benchmark/` directory and changes NO protocol shard, so it cannot destabilize the shipped protocol. No new rules, no PROTOCOL.md regeneration.

---

## 1. Context & problem

Heatwave's rigor claim is currently unfalsifiable — there's no number showing protocol-built code beats raw single-agent code. That number is the adoption + sellability lever (a first enterprise buyer or a GitHub star needs it). But a benchmark done badly is worse than none: vendor claims (Devin's self-reported 67% vs an independent ~15%) show unaudited numbers don't convert and can backfire. E must be **honest, reproducible, and self-critical** first, impressive second.

## 2. Goals / non-goals

**Goals:**
- G1. A **bespoke seeded-bug corpus**: a controlled fixture repo with ~8 tasks, each with (a) a starting state, (b) a *visible* spec the agent sees, (c) a *hidden oracle* test suite the agent never sees that objectively decides pass/fail, (d) a documented failure-mode/trap.
- G2. A **reproducible harness** (POSIX shell): per task per arm, set up a clean scratch copy, run the arm, run the hidden oracle, record pass/fail + wall-time (+ token cost where obtainable). Deterministic, re-runnable, one command.
- G3. **Two arms, fair by construction:** RAW (single agent, no protocol) vs HEATWAVE (the full loop via the claude adapter, headless). Same model, same task spec, same starting repo — only the *process* differs.
- G4. An honest **METHODOLOGY.md**: task-selection criteria (fair, not cherry-picked), what's controlled, threats to validity, sample size, how to scale, the explicit Devin lesson (don't over-claim).
- G5. A **small pilot run** (hard-bounded, below) producing a preliminary, caveated **RESULTS.md** — a first signal, labeled a pilot, not a leaderboard claim.

**Non-goals (deferred):**
- A statistically robust, large-N, multi-trial benchmark (expensive; E ships the rig that makes it runnable later).
- Existing public benchmarks (SWE-bench etc.) — bespoke-only for control this round.
- Positioning/README use of the number — that's F.
- Any protocol rule change.

## 3. Locked decisions (owner brainstorm)

- **Scope = harness + corpus + small pilot.** Build the rig and corpus; run a small pilot for a first honest signal; expandable later.
- **Corpus = small bespoke seeded-bug set** (~8 tasks), controlled, with hidden oracles.

## 4. Cost bound (explicit — the owner flagged token spend)

The HEATWAVE arm runs a full multi-agent loop per task, which is the expensive part. To bound spend:
- **Pilot = up to 8 tasks × 1 trial per arm.** No multi-trial in the pilot.
- The harness MUST support `--tasks N` and `--trials K` for later scaling, but the pilot invocation is fixed at K=1.
- **Feasibility escape (honest):** if running a full headless HEATWAVE loop per task inside the harness proves infeasible or runaway-expensive in the build environment, the implementer runs the pilot on a **reduced subset (≥3 tasks) end-to-end** to prove the harness works, records actual cost, and declares the remainder `NOT RUN (cost-bounded)` in RESULTS.md with the exact command to complete it. Honesty over a padded number (R-64/R-65). A working rig + a small real signal is the deliverable; a big number is not required to pass.

## 5. Design

### 5.1 Corpus (`benchmark/corpus/<task-id>/`)

Each task directory contains:
- `repo/` — the starting fixture code (small, self-contained, one language for the pilot — POSIX shell or Python, no heavy deps).
- `SPEC.md` — the *visible* task the agent is given (a feature to add or a bug to fix).
- `oracle/` — the *hidden* test suite (the agent never sees this dir; the harness copies it in only to grade). Includes edge cases the visible spec implies but doesn't spell out — this is where raw agents typically escape defects.
- `TASK.yaml` — metadata: id, type (bugfix|feature), the planted trap/failure-mode, difficulty, oracle command + expected exit.

Tasks are authored to realistic traps (off-by-one, unhandled error path, missing input validation, an edge case the spec implies) — **selection criteria documented in METHODOLOGY.md; not chosen to favor either arm.**

### 5.2 Harness (`benchmark/run.sh`, POSIX)

`sh benchmark/run.sh --arm <raw|heatwave> --tasks <N> --trials <K>`:
1. For each task: copy `repo/` to a fresh scratch dir (never the corpus original); withhold `oracle/`.
2. Run the arm on the scratch copy with `SPEC.md` as the task:
   - **RAW:** one `claude` invocation, plain "implement this task" prompt, no protocol files present.
   - **HEATWAVE:** the claude adapter installed, the loop run headless to a terminal state.
3. Copy in `oracle/`, run the oracle command, capture pass/fail + exit code.
4. Record a row: task, arm, trial, pass/fail, wall-time, (token cost if the adapter exposes it), notes.
5. Emit `benchmark/results/<timestamp>.csv` (append-only) and a summary.

Deterministic and idempotent per (task, arm, trial); re-running reproduces the setup. No network beyond the model call. No new runtime deps beyond `claude` + the corpus's own test runner.

### 5.3 Metric

- **Primary: escaped-defect rate** — fraction of tasks whose output passes a naive/visible check but FAILS the hidden oracle (the defect the process should have caught). Reported per arm.
- **Secondary: oracle pass rate** and mean wall-time/cost per task.
- The claim E can support is a *delta* between arms on the same tasks/model, explicitly scoped to this pilot's n.

### 5.4 Methodology & results docs

- `benchmark/METHODOLOGY.md` — arms, controls, task-selection criteria, metric definitions, threats to validity (task authorship bias, small n, single trial, model nondeterminism), the Devin over-claim caution, and the exact commands to reproduce and to scale.
- `benchmark/RESULTS.md` — the pilot table + a plain-English, caveated reading. Any `NOT RUN (cost-bounded)` tasks listed with the completion command. No claim beyond what the data supports.

## 6. Affected files

**New (all under `benchmark/`):**
- `benchmark/corpus/<task-id>/{repo/,SPEC.md,oracle/,TASK.yaml}` — ~8 tasks
- `benchmark/run.sh` — the harness
- `benchmark/METHODOLOGY.md`, `benchmark/RESULTS.md`, `benchmark/README.md`
- `benchmark/results/` — CSV output (gitignored except a committed pilot snapshot)

**Modified:** none in `protocol/`; optionally a one-line pointer added to the repo README under F (not E). `.gitignore` for `benchmark/results/*.csv` transient runs.

**No protocol rule changes. No PROTOCOL.md regeneration.** E is additive and isolated.

## 7. Alternatives considered

1. **Big multi-trial benchmark now.** Rejected by owner (cost). Ship the rig + a bounded pilot.
2. **Existing public benchmark.** Rejected this round (heavier, expensive per real-repo run); bespoke gives control. The rig is structured so an existing-benchmark arm can be added later.
3. **Grade with an LLM judge instead of hidden oracle tests.** Rejected: an LLM judge reintroduces the exact bias E exists to escape. Deterministic oracle tests only.
4. **Let the agent see the tests.** Rejected: defeats escaped-defect measurement. Oracle is strictly withheld until grading.

## 8. Risks & mitigations

| Risk | Mitigation |
|---|---|
| Task authorship bias (rigged to favor Heatwave) | selection criteria published; tasks are generic traps; RAW and HEATWAVE get identical spec/repo/model; reviewer checks for cherry-picking |
| Small n / single trial over-read as definitive | RESULTS.md labels it a pilot, states n and variance caveats, claims only the observed delta |
| HEATWAVE arm too expensive to run fully | hard pilot bound (≤8×1); feasibility escape to ≥3 tasks + honest NOT RUN rows |
| Model nondeterminism | trials param exists for later; pilot notes single-trial limitation explicitly |
| Harness contaminates corpus originals | always operate on scratch copies; oracle withheld until grade; assert originals unchanged |
| A number that flatters Heatwave unfairly leaks into marketing | E stays a pilot; F decides what (if anything) is publishable |

## 9. Verification strategy (evidence, not assertion)

1. **Corpus integrity.** Each task has repo/SPEC/oracle/TASK.yaml; the agent-visible surface never includes `oracle/`. Evidence: a check script asserting oracle isolation.
2. **Harness determinism.** Running a task's setup twice yields identical scratch state; corpus originals unchanged after a run. Evidence: hash/diff assertions.
3. **Oracle correctness.** For each task, a known-good solution passes the oracle and a known-bad (the planted bug) fails it — proving the oracle actually discriminates. Evidence: oracle run on both reference solutions.
4. **Both arms run.** RAW and HEATWAVE each complete on ≥3 pilot tasks end-to-end, producing gradable output. Evidence: results CSV + transcripts.
5. **Metric computed honestly.** Escaped-defect rate + pass rate computed from the CSV; any NOT-RUN tasks excluded and labeled. Evidence: RESULTS.md matches the CSV.
6. **Reproducibility.** The documented command reproduces a run from clean. Evidence: a second run’s summary.
7. **No protocol regression.** A–D untouched; `git diff` shows only `benchmark/` additions; build-protocol.sh drift still `OK`. Evidence: diff + drift check.

Cost-bounded omissions are declared explicitly (R-64), never silently skipped. No number is stated beyond what the pilot data supports (R-65/R-66).

## 10. Open questions

None blocking. Whether/what to publish from RESULTS.md is deferred to F.
