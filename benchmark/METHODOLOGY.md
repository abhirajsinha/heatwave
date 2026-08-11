# Methodology — Heatwave Credibility Benchmark

This document is the honest-reading contract for every number in `RESULTS.md`.
It states how the corpus was built, what controls keep the comparison fair, and
every threat to validity we know about. If a claim is not defensible from this
file plus the committed CSV and transcripts, it should not be quoted.

## 1. What is measured

**Primary metric — escaped-defect rate per arm:** an *escaped defect* is a
solution that **passes the task's visible check but fails the withheld
oracle** — the class of bug a lazy verification loop ships to production.
Rate = escaped defects ÷ graded tasks for that arm.

**Secondary metrics:** oracle pass rate, mean wall-clock seconds, and total
cost in USD where the CLI reports it (`total_cost_usd` in the result JSON;
best-effort — subscription auth may not report cost, in which case the field
is empty and only wall-time bounds spend).

Metrics are computed from the run CSV by `summarize.awk`. Tasks not run are
**absent from every denominator** and listed in `RESULTS.md` as
`NOT RUN (cost-bounded)` with the exact command to complete them.

## 2. Corpus selection criteria

- 8 tasks, two per generic defect class: **off-by-one** (t01, t02),
  **unhandled error path** (t03, t04), **missing input validation** (t05, t06),
  **spec-implied edge case** (t07, t08). The classes come from the spec, not
  from anything Heatwave is known to be good at.
- Each task: an agent-visible `SPEC.md` + starter `repo/` (stub for features,
  planted-bug code for bugfixes) with a **happy-path-only visible check**, and
  a **withheld** deterministic oracle (`unittest`, Python stdlib only).
- **Traceability rule:** every oracle test method carries a `# SPEC:` comment
  quoting the SPEC sentence it enforces. No oracle asserts behavior the SPEC
  does not state or directly imply. Enforced by `check-corpus.sh`.
- **Discrimination gate:** for every task, `solutions/good.py` must pass the
  oracle, `solutions/bad.py` must fail it, and `solutions/bad.py` must pass
  the visible check (i.e. the trap genuinely escapes naive verification).
  A task failing any leg is a broken task, not data. `check-corpus.sh` proves
  all three legs for all 8 tasks and is run before any paid arm.
- **Corpus freeze:** the corpus + harness are committed before any paid arm
  runs; the freeze SHA is recorded in `RESULTS.md`. No task is edited after
  observing any arm's output — such an edit would be a new corpus version and
  restarts the pilot (or drops the task, noted in RESULTS.md).

## 3. Arms

Both arms get an identical scratch working copy (`repo/*` + `SPEC.md`, fresh
`git init` + initial commit), the same model via the same CLI, the same flags,
and deadlines below. Only the *process* differs. Arm order is fixed in
advance: the full RAW sweep first, then HEATWAVE (canary task first).

**RAW** — one plain agent call, no protocol files present:

```sh
claude -p --setting-sources project --dangerously-skip-permissions \
  --output-format json "<RAW_PROMPT>"
```

**HEATWAVE** — `sh install.sh <scratch> claude` (installs `.heatwave/`,
`CLAUDE.md` adapter block, protocol subagents, gate hooks), then one headless
session:

```sh
claude -p --setting-sources project --dangerously-skip-permissions \
  --output-format json "<HW_PROMPT>"
```

**Verbatim prompts** (constants in `run.sh`):

- `RAW_PROMPT`: "Implement the task described in SPEC.md by editing the files
  in this directory. Make the visible tests pass and satisfy the SPEC
  completely. When done, stop."
- `HW_PROMPT`: "Implement the task described in SPEC.md. This project uses the
  Heatwave protocol (CLAUDE.md); follow it, driving the run to a terminal
  state. Make the visible tests pass and satisfy the SPEC completely."

**Fixture arms** (`fixture-good` / `fixture-bad`) copy the reference solutions
instead of calling any model: a zero-token deterministic self-test of the whole
pipeline. They are excluded from all results claims.

## 4. Controls

1. **Oracle unreachability (out-of-repo scratch):** every arm executes in a
   per-trial scratch under a `mktemp -d "${TMPDIR:-/tmp}/hw-bench.XXXXXX"`
   sweep root. The harness fatally refuses a scratch root under the repo path.
   Only `repo/*` + `SPEC.md` are copied in — never `oracle/`, `solutions/`, or
   `TASK.yaml` — and a fatal assert re-checks the scratch surface. The oracle
   file is copied into scratch only **after the arm's process has exited**.
2. **Transcript grep (detective control):** after every sweep the harness
   greps all `agent.json`/`agent.err` transcripts for `oracle` and
   `benchmark/corpus`. Any hit prints a loud warning and blocks use of that
   row until dispositioned in RESULTS.md.
3. **Corpus immutability:** a `shasum -a 256` manifest of `corpus/` is taken
   before and after every sweep; any difference is a fatal error.
4. **No context leakage:** both arms run with `--setting-sources project` in a
   scratch containing no user-level files. Smoke-tested before the pilot: a
   bare-scratch session asked to list any visible project/user instructions
   answered "NONE." (RAW additionally has no protocol files at all.)
5. **No network beyond the model call:** the HEATWAVE install path would clone
   a companion skill on fresh installs; the harness pre-creates
   `.claude/skills/ui-ux-pro-max` so the installer takes its verified
   "already installed" skip path. No other step performs network I/O.
6. **Deadlines with process-group kill:** RAW 900 s, HEATWAVE 2700 s per task;
   grading checks 120 s. The watchdog kills the arm's whole process group
   (TERM, 10 s grace, KILL) so no orphan process outlives its deadline.
7. **Cost bounds:** pilot ≤ 8 tasks × 1 trial per arm. HEATWAVE canary rule:
   if the first task exceeds 45 min or $15 or fails to reach a terminal state,
   the sweep falls back to the first ≥ 3 tasks in lexical task-id order
   (subset pre-committed before any run — never chosen after seeing results).
   Sweep-cumulative breaker: cumulative cost > $60, cumulative wall > 14400 s,
   or (HEATWAVE, when cost is reported) cumulative cost > 3× canary cost stops
   the sweep; completed rows are kept, the rest become NOT-RUN rows. When cost
   is unreported the wall caps alone bind.
8. **Grading is arm-blind:** the same `test_visible.py`/`test_oracle.py`
   commands grade every arm, and the harness re-copies **both** files from the
   corpus at grading time — the graded checks are always the corpus's, even if
   the agent edited, weakened, or replaced them in scratch.

## 5. Threats to validity (read before quoting numbers)

- **Task-authorship bias:** the corpus was written by the Heatwave project.
  The traceability rule, generic trap classes, bidirectional discrimination
  gate, and pre-run corpus freeze mitigate but cannot eliminate this; an
  independent replication on someone else's corpus would be stronger evidence.
- **Small n, single trial:** ≤ 8 tasks × 1 trial per arm. Model output is
  nondeterministic; a single trial per task cannot separate skill from luck.
  Treat the pilot as a signal, not an estimate.
- **Deadline asymmetry:** RAW gets 900 s, HEATWAVE 2700 s per task. A timed-out
  arm is graded **as-is** — a partial solution can pass the visible check and
  fail the oracle, registering as an escaped defect. Deadline choice therefore
  influences the metric; both values are fixed pre-run.
- **Residual oracle-access possibility:** arms run with
  `--dangerously-skip-permissions`, so an absolute-path read of the corpus is
  physically possible. The preventive control is that no corpus path is
  discoverable from the agent's cwd or inputs; the detective control is the
  transcript grep. Neither is airtight against a deliberately adversarial
  model.
- **Headless HEATWAVE fidelity:** driving the full protocol loop in one
  `claude -p` session may under-represent the interactive protocol; a session
  that dies mid-loop is graded as-is and noted.
- **The Devin caution:** self-reported agent benchmarks have a track record of
  collapsing under independent replication (Devin's reported 67% task success
  vs ~15% found independently by third-party review, 2024). This benchmark is
  self-reported too. That is exactly why the corpus, harness, transcripts, and
  raw CSVs ship in this repo — replicate before believing, and do not quote
  the headline number without the caveats above.

## 6. Reproduce

```sh
# free self-tests
sh benchmark/check-corpus.sh
sh benchmark/run.sh --arm fixture-good      # expect: oracle_pass=8/8, escapes 0
sh benchmark/run.sh --arm fixture-bad       # expect: escaped_defects=8/8

# the pilot (paid; RAW first, then HEATWAVE — canary task first)
sh benchmark/run.sh --arm raw
sh benchmark/run.sh --arm heatwave --only t01-pagination       # canary
sh benchmark/run.sh --arm heatwave --only t02-date-window,t03-log-summary,t04-safe-stats,t05-cart-total,t06-username-policy,t07-slugify,t08-dedupe-contacts

# metrics
awk -F, -f benchmark/summarize.awk benchmark/results/<run-id>.csv
```

Scale up (more trials for confidence intervals): `--trials K` on any arm;
subset: `--only <comma-separated ids>`; fewer tasks: `--tasks N` (lexical
order). Fixture arms are deterministic; model arms are not — expect variance.
