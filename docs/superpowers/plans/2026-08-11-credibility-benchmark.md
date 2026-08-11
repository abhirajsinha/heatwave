# Planning Document — Credibility Benchmark (Heatwave v4, Sub-project E)

task_id: 2026-08-11-credibility-benchmark | artifact_type: planning-document | iteration: 2 | produced_by: PLANNER (claude-fable-5) | timestamp: 2026-08-11

Spec (source of truth): `docs/specs/2026-08-11-credibility-benchmark-design.md` (APPROVED).
Repo: `/Users/abhirajsinha/Projects/heatwave`, branch `main` (A–D merged; verified `git log`: HEAD `06cd952`, drift check prints `OK: PROTOCOL.md matches protocol/ shards`).
Revises: iteration 1, rejected at PLAN_REVIEW (`docs/superpowers/reviews/2026-08-11-plan-review-E.md`, 1 Major / 3 Minor / 2 Nit).

## PLAN_REVIEW iteration-1 finding responses (R-34, §3.5 schema adapted to plan findings)

**F-001 | MAJOR | verification-integrity — oracle reachable from in-repo scratch under `--dangerously-skip-permissions`**
Response: **Accepted.** The iteration-1 design withheld the oracle only on the copy surface; the scratch dir sat inside the repo three `cd ..` from `benchmark/corpus/`, so the answer key was discoverable from the agent's own cwd. Disqualifying for this artifact regardless of likelihood.
Action: scratch now lives **outside the repo tree**: the harness creates a per-sweep root via `mktemp -d "${TMPDIR:-/tmp}/hw-bench.XXXXXX"` and works in `$SWEEP_ROOT/$ARM/$ID/trial-N`; the agent-visible surface is only `repo/*` + `SPEC.md` (never `oracle/`, `solutions/`, or `TASK.yaml`); the harness **fatally asserts** the scratch path does not lie under the repo; the oracle is copied into scratch only after the arm's process has exited; transcripts/logs are copied back into `benchmark/results/transcripts/` for evidence and the scratch root is disposable. New **AC-F-10** proves isolation with two independent checks: (a) recorded scratch root outside the repo path, (b) per-row transcript grep — zero occurrences of `oracle` or the corpus path in `agent.json`/`agent.err`. Residual risk (absolute-path reads remain physically possible under skip-permissions; the path is no longer discoverable from cwd; the transcript grep is the detective control) is added to METHODOLOGY threats, and the shasum manifest stays as the mutation backstop.
Where: Architecture (layout + A5-7), harness skeleton (`mktemp`, assert, copy-back), Data Design, Security Considerations, Risks, AC-F-01/AC-F-10, T7/T9/T10 done-checks, FR-9.

**F-002 | MINOR | data-integrity — per-task network `git clone` in the HEATWAVE install path**
Response: **Accepted.** `install.sh` (claude adapter) clones ui-ux-pro-max when absent — always absent in fresh scratch — violating spec §5.2 "no network beyond the model call" and adding nondeterministic wall-time to one arm.
Action: the harness pre-creates `$SCRATCH/.claude/skills/ui-ux-pro-max` before invoking `install.sh`, which triggers the installer's verified "already installed" skip path (install.sh L135–136) — no clone, no network. Noted in METHODOLOGY controls.
Where: harness skeleton (`run_heatwave` setup line), FR-9, Edge Cases.

**F-003 | MINOR | cost-bound — no cumulative circuit breaker after the canary**
Response: **Accepted.** A $14.99 canary authorized ~7 more tasks with no further checkpoint.
Action: the harness tracks `CUM_COST` and `CUM_WALL` across the whole sweep (both arms) and, after each task, trips the feasibility escape when cumulative cost > $60, cumulative wall > 14400 s (4 h), or (HEATWAVE, when cost is reported) cumulative cost > 3× canary cost — remaining tasks become `NOT RUN (cost-bounded)` rows in RESULTS.md with the exact completion command. When cost is unobtainable (subscription auth), the wall breaker still binds; stated in METHODOLOGY.
Where: harness skeleton (breaker in the task loop), NFR-2, AC-N-03, T10.

**F-004 | MINOR | timeouts — `with_deadline` kills only the direct child PID**
Response: **Accepted.** `claude` spawns subprocesses; orphans could outlive the deadline and keep spending.
Action: `with_deadline` enables job control (`set -m`, POSIX) so the backgrounded arm becomes its own process-group leader, and the watchdog kills the group (`kill -- -$pid`, TERM then KILL after grace). T10 canary adds an explicit orphan check: `pgrep -f 'claude -p'` must be empty after each arm completes/times out, recorded as evidence.
Where: harness skeleton (`with_deadline`), Error Handling, T10 done-check.

**F-005 | NIT | error-handling — HEATWAVE install output discarded**
Response: **Accepted.** Action: `install.sh` output goes to `$SCRATCH/install.log` (copied back with transcripts); failure records `notes=install-failed` on the row and the sweep continues.
Where: harness skeleton, Error Handling.

**F-006 | NIT | methodology — deadline asymmetry not listed as a threat**
Response: **Accepted.** Action: FR-9's METHODOLOGY threats list now names the RAW 900 s / HEATWAVE 2700 s asymmetry and the graded-as-is timeout policy (a timed-out partial solution can register as an escaped defect), so readers can weigh deadline choice as a metric influence.
Where: FR-9, METHODOLOGY content list (T8).

No finding disputed; no scope change; everything the review judged sound (trap roster, SPEC-traceable oracles, discrimination-before-pilot ordering, corpus freeze, fixture arms, no LLM judge, honest NOT-RUN rows) is preserved unchanged. E still changes NO protocol shard and adds NO rules.

## Tier

**FULL** — E is additive and isolated (a new `benchmark/` directory, zero protocol-shard changes), which alone would argue STANDARD. It is FULL because of what the artifact *is*: a public credibility instrument whose entire value is honesty, produced by running real paid agent loops. A rigged corpus, a leaky oracle, or a fabricated CSV row does not break a build — it breaks the project's central claim in public, the reputational equivalent of "anything touching money." The reviewer must actively hunt cherry-picking and verification-integrity failures (R-65), which is FULL-tier review posture. FULL's mutation rung will be declared NOT AVAILABLE honestly (see Tooling Declaration).

Change class: **feature** — new capability (benchmark rig + corpus + pilot), not a defect correction. R-113 does not apply to the run (individual corpus tasks are internally typed bugfix/feature; that typing is corpus data, not this run's change class).

## Problem Statement

Heatwave's rigor claim is unfalsifiable: no number shows protocol-built code beats raw single-agent code, and a badly built number (Devin's self-reported 67% vs independent ~15%) is worse than none. E builds: (1) a bespoke 8-task seeded-bug corpus with agent-visible SPECs and strictly-withheld deterministic oracles; (2) a reproducible POSIX harness running two arms — RAW (one plain `claude` call, no protocol files) vs HEATWAVE (the full loop via the claude adapter, headless) — on identical inputs, grading with the hidden oracle, emitting CSV; (3) an honest METHODOLOGY.md; (4) a hard-bounded pilot (≤ 8 tasks × 1 trial per arm, feasibility escape to ≥ 3 tasks) producing a caveated RESULTS.md. A working rig plus a small honest signal is the deliverable; a big number is not required to pass (spec §4, R-64/R-65).

## Functional Requirements

- FR-1. Corpus of 8 tasks at `benchmark/corpus/<task-id>/{repo/,SPEC.md,oracle/,solutions/,TASK.yaml}`; the agent-visible surface is exactly `repo/*` + `SPEC.md` — `oracle/`, `solutions/`, and `TASK.yaml` are withheld, and the working copy lives **outside the repo tree** so no corpus file is discoverable from the agent's cwd (F-001).
- FR-2. Tasks are generic traps, two per class: off-by-one, unhandled error path, missing input validation, spec-implied edge case — not authored to favor either arm; every oracle assertion is traceable to a SPEC.md sentence (anti-rigging traceability rule, Architecture §A5).
- FR-3. Each task carries a *visible* naive check inside `repo/` (happy-path only). Escaped defect = visible check passes AND hidden oracle fails (spec §5.3).
- FR-4. Harness `benchmark/run.sh` (POSIX sh): `sh benchmark/run.sh --arm <raw|heatwave|fixture-good|fixture-bad> [--tasks N] [--trials K] [--only <ids>]`; per (task, arm, trial): fresh `mktemp -d` scratch outside the repo containing only `repo/*` + `SPEC.md`, isolation asserted (path + contents); run the arm under a process-group deadline; copy the oracle in only after the arm exits; grade visible + oracle; append a CSV row; copy transcripts back under `benchmark/results/transcripts/`; print a summary. Fixture arms copy the reference solutions instead of calling `claude` — a zero-token deterministic self-test of the entire pipeline, excluded from any results claim.
- FR-5. RAW arm = one `claude -p` invocation with a plain "implement SPEC.md" prompt, no protocol files present in scratch and no user-level instruction leakage (isolation smoke-tested, T7). HEATWAVE arm = `install.sh <scratch> claude` (network clone suppressed via the pre-created skill dir, F-002) then one headless `claude -p` session driving the loop to a terminal state. Same model, same SPEC, same starting repo — only process differs.
- FR-6. CSV output `benchmark/results/<run-id>.csv`, append-only within a run, schema in Data Design; per-row wall-time always, `total_cost_usd` when the JSON result exposes it, else empty (spec: "where obtainable").
- FR-7. Metric: primary = escaped-defect rate per arm (escapes ÷ graded tasks); secondary = oracle pass rate, mean wall-time/cost. Computed from the CSV by `benchmark/summarize.awk`; NOT-RUN tasks excluded from denominators and labeled.
- FR-8. `benchmark/check-corpus.sh`: per task asserts layout completeness, oracle isolation from the copy surface, good-solution passes oracle, bad-solution fails oracle, bad-solution passes the visible check (8/8 required).
- FR-9. `benchmark/METHODOLOGY.md` (selection criteria, controls incl. out-of-repo scratch isolation + transcript-grep detective control + suppressed installer clone, threats to validity incl. task-authorship bias, small n, single trial, model nondeterminism, **deadline asymmetry (900 s vs 2700 s) + graded-as-is timeout policy** (F-006), **residual absolute-path read possibility under skip-permissions** (F-001), the Devin over-claim caution, exact reproduce + scale commands) and `benchmark/RESULTS.md` (pilot table, plain-English caveated reading, NOT RUN rows with the exact completion command).
- FR-10. Pilot: up to 8 tasks × 1 trial per arm; K=1 fixed for the pilot; feasibility escape = first ≥ 3 tasks **in lexical task-id order** (pre-committed subset rule — no post-hoc selection), remainder `NOT RUN (cost-bounded)`. Escape triggers: canary rule (T10) **or the cumulative breaker (F-003)**.
- FR-11. No protocol change: `git diff` vs pre-E main shows only `benchmark/**` + `.gitignore`; `sh build-protocol.sh --check` stays `OK`.

## Non-Functional Requirements

- NFR-1. Zero new runtime dependencies: `/bin/sh`, `python3` (stdlib only in corpus), `git`, `shasum`, `awk`, `claude`. Nothing installed, no Docker, **no network beyond the model call** (F-002; see AC-N-01).
- NFR-2. Cost bound: pilot ≤ 8×1 per arm; per-task wall ceiling enforced by process-group watchdog (RAW 900 s, HEATWAVE 2700 s); **sweep-cumulative breaker: cost > $60 or wall > 14400 s or (HEATWAVE, cost-reported) > 3× canary cost → escape** (F-003); HEATWAVE canary rule in T10 (see AC-N-03).
- NFR-3. Deterministic non-model path: a full 8-task `fixture-good` sweep completes < 5 min and twice-run setup is byte-identical (AC-F-04, AC-N-04).
- NFR-4. Corpus originals immutable across runs, asserted fatally by the harness (AC-F-04).

## Architecture

```
benchmark/                              # in-repo: corpus, harness, docs, results
├── README.md               # what this is, one-command quickstart, honest-signal framing
├── run.sh                  # the harness (POSIX sh)
├── summarize.awk           # metric computation from CSV
├── check-corpus.sh         # integrity + oracle-discrimination gate
├── METHODOLOGY.md
├── RESULTS.md
├── corpus/
│   └── t01-pagination/
│       ├── repo/           # agent-visible: module stub/buggy code + visible naive check
│       ├── SPEC.md         # agent-visible task
│       ├── oracle/         # WITHHELD: test_oracle.py (deterministic, stdlib unittest)
│       ├── solutions/      # WITHHELD: good.py (passes oracle), bad.py (naive trap victim)
│       └── TASK.yaml       # WITHHELD metadata + commands (flat, sed-parseable)
│   └── … t02..t08
└── results/                # .gitignored except committed pilot snapshot + .gitkeep
    └── transcripts/<run-id>/<task>-trialN/   # agent.json, agent.err, visible.log,
                                              # oracle.log, install.log (evidence copy-back)

${TMPDIR:-/tmp}/hw-bench.XXXXXX/        # OUT-OF-REPO (mktemp -d): the only place arms run
└── <arm>/<task-id>/trial-N/            # repo/* + SPEC.md only; oracle copied in post-arm;
                                        # deleted after transcript copy-back (F-001)
```

**Data flow per (task, arm, trial):** corpus `repo/`+`SPEC.md` → fresh out-of-repo scratch (`mktemp -d` sweep root; **fatal asserts:** scratch path not under the repo; scratch contains no `oracle`/`solutions`/`TASK.yaml` entry) → `git init` + initial commit (identical for both arms; the HEATWAVE loop expects a repo) → arm executes under a process-group watchdog deadline → **only after the arm's process has exited**, oracle copied in → visible check + oracle run, exits captured → CSV row → transcripts copied back to `benchmark/results/transcripts/` → scratch removed. Before/after the sweep, a `shasum -a 256` manifest of `corpus/` must be identical or the harness exits fatal (mutation backstop; the out-of-repo scratch + transcript grep are the read-isolation controls).

**Arms (fair by construction):**
- RAW: `claude -p --setting-sources project --dangerously-skip-permissions --output-format json "<raw prompt>"` in scratch. No `.heatwave/`, no `CLAUDE.md`.
- HEATWAVE: `mkdir -p "$SCRATCH/.claude/skills/ui-ux-pro-max"` (suppresses the installer's network clone via its verified already-installed skip path — F-002), `sh <repo>/install.sh <scratch> claude > install.log 2>&1` (verified: installs `.heatwave/`, `CLAUDE.md` adapter block, `.claude/agents/heatwave-*`, gate hooks), then `claude -p --setting-sources project --dangerously-skip-permissions --output-format json "<heatwave prompt>"` — the adapter block + hooks make the session drive the protocol loop with Task subagents to a terminal state.
- Both arms: same model (recorded from the result JSON / `claude --version`), same flags, same scratch construction, prompts differing only in the process instruction (both prompts printed verbatim in METHODOLOGY.md).

**A5 — Anti-rigging controls (first-class, for the reviewer to attack):**
1. Trap classes are the four generic defect families named in the spec; two tasks each; roster fixed below, before any arm runs.
2. Every oracle assertion carries a comment citing the SPEC.md sentence it enforces — no oracle test may check behavior the SPEC does not state or directly imply. Reviewer spot-checks this per task.
3. `check-corpus.sh` proves each oracle discriminates both ways (good passes, bad fails) and that the bad solution passes the visible check — a task whose trap can't escape a naive check is a broken task, not data.
4. Corpus freeze: T9 commits the corpus + harness before any paid arm runs; pilot results must come from a scratch whose base equals the frozen commit. No task edited after observing any arm's output (any such edit = new corpus version, pilot restarts or the task is dropped with a note in RESULTS.md).
5. Reduced-subset rule pre-committed: lexical task-id order, never chosen after seeing results.
6. Identical inputs both arms; arm order (RAW sweep first, then HEATWAVE) fixed in advance and stated in METHODOLOGY.md.
7. **Oracle unreachability (F-001):** arms execute only in out-of-repo `mktemp -d` scratch; the withheld set (`oracle/`, `solutions/`, `TASK.yaml`) is never copied there and is not discoverable from the agent's cwd; per-row transcript grep (AC-F-10) evidences zero oracle/corpus-path access; residual absolute-path possibility disclosed in METHODOLOGY threats.

**Task roster (fixed now):**

| id | type | trap | module | planted trap summary |
|---|---|---|---|---|
| t01-pagination | feature | off-by-one | pagination.py | 1-indexed pages; last partial page; page-past-end → []; invalid page/page_size → ValueError |
| t02-date-window | bugfix | off-by-one | datewindow.py | inclusive day-count off by one at boundaries; same-day window = 1 |
| t03-log-summary | bugfix | unhandled-error | logstats.py | corrupt/blank JSONL lines crash; must count `_malformed` and continue; empty file → {} |
| t04-safe-stats | feature | unhandled-error | stats.py | empty input → ValueError per spec; non-numeric element → TypeError; single element |
| t05-cart-total | feature | missing-validation | cart.py | negative/zero qty & negative price must raise; money rounded to 2dp (cent-exact) |
| t06-username-policy | bugfix | missing-validation | username.py | length checked but charset/leading-digit/case rules from spec unenforced |
| t07-slugify | feature | implied-edge-case | slugify.py | collapse runs of separators, trim hyphens, empty-result contract, uppercase folding |
| t08-dedupe-contacts | feature | implied-edge-case | dedupe.py | dedupe by email case-insensitively, keep FIRST occurrence, preserve order |

**TASK.yaml schema** (flat key: value lines; parsed with `sed -n 's/^key: //p'` — no YAML parser dependency; withheld from the agent surface — it names the oracle command):

```yaml
id: t01-pagination
type: feature            # bugfix | feature
trap: off-by-one         # off-by-one | unhandled-error | missing-validation | implied-edge-case
difficulty: easy         # easy | medium
module: pagination.py    # file the solutions/ references replace in fixture arms
visible_check: python3 -m unittest test_visible -v
oracle_cmd: python3 -m unittest test_oracle -v
oracle_expect_exit: 0
```

**Fully-authored example task 1 — `t01-pagination` (feature, off-by-one):**

`corpus/t01-pagination/SPEC.md`:

```markdown
# Task: implement paginate()

Implement `paginate(items, page, page_size)` in `pagination.py` (keep the file
and function name — callers import `pagination.paginate`).

Contract:
- `items` is a list; `page` is 1-indexed (the first page is page 1).
- Returns the list of items belonging to that page, in order.
- The last page may be partial. A page past the last page returns `[]`.
- `page` and `page_size` must be integers ≥ 1; anything else raises `ValueError`.

A basic check exists in `test_visible.py`; make it pass. The function is used
to render search-result pages, so boundary behavior matters.
```

`corpus/t01-pagination/repo/pagination.py`:

```python
"""Pagination helper. See SPEC.md for the contract."""


def paginate(items, page, page_size):
    raise NotImplementedError("implement per SPEC.md")
```

`corpus/t01-pagination/repo/test_visible.py` (the naive check):

```python
import unittest
from pagination import paginate


class TestVisible(unittest.TestCase):
    def test_first_page(self):
        self.assertEqual(paginate(list(range(10)), 1, 3), [0, 1, 2])

    def test_second_page(self):
        self.assertEqual(paginate(list(range(10)), 2, 3), [3, 4, 5])


if __name__ == "__main__":
    unittest.main()
```

`corpus/t01-pagination/oracle/test_oracle.py` (each assertion cites its SPEC line):

```python
import unittest
from pagination import paginate


class TestOracle(unittest.TestCase):
    def test_last_partial_page(self):        # SPEC: "The last page may be partial."
        self.assertEqual(paginate(list(range(10)), 4, 3), [9])

    def test_page_past_end_empty(self):      # SPEC: "A page past the last page returns []."
        self.assertEqual(paginate(list(range(10)), 5, 3), [])

    def test_exact_boundary(self):           # SPEC: 1-indexed + past-end contract at len % size == 0
        self.assertEqual(paginate(list(range(9)), 3, 3), [6, 7, 8])
        self.assertEqual(paginate(list(range(9)), 4, 3), [])

    def test_empty_items(self):              # SPEC: past-end contract; page 1 of [] is past the end
        self.assertEqual(paginate([], 1, 3), [])

    def test_page_zero_rejected(self):       # SPEC: "page and page_size must be integers >= 1 ... ValueError"
        with self.assertRaises(ValueError):
            paginate(list(range(10)), 0, 3)

    def test_negative_page_size_rejected(self):  # SPEC: same sentence
        with self.assertRaises(ValueError):
            paginate(list(range(10)), 1, -1)

    def test_non_integer_rejected(self):     # SPEC: "must be integers"
        with self.assertRaises(ValueError):
            paginate(list(range(10)), "1", 3)


if __name__ == "__main__":
    unittest.main()
```

`corpus/t01-pagination/solutions/bad.py` (naive trap victim — passes visible, fails oracle):

```python
def paginate(items, page, page_size):
    start = (page - 1) * page_size
    return items[start:start + page_size]
```

(Fails the oracle on validation cases: `page=0` silently returns a wrong slice instead of raising — exactly the escaped defect class.)

`corpus/t01-pagination/solutions/good.py`:

```python
def paginate(items, page, page_size):
    if not isinstance(page, int) or isinstance(page, bool) or page < 1:
        raise ValueError("page must be an integer >= 1")
    if not isinstance(page_size, int) or isinstance(page_size, bool) or page_size < 1:
        raise ValueError("page_size must be an integer >= 1")
    start = (page - 1) * page_size
    return items[start:start + page_size]
```

**Fully-authored example task 2 — `t03-log-summary` (bugfix, unhandled-error):**

`corpus/t03-log-summary/SPEC.md`:

```markdown
# Task: fix the crash in logstats.summarize()

Bug report: the nightly job crashed with a traceback from
`logstats.summarize()`. Our logs are JSON-lines, but real log files contain
occasional corrupt lines (truncated writes) and blank lines.

Fix `logstats.py` (keep the file and function name) so that:
- Valid lines are counted by their `"level"` field, as today.
- A corrupt (unparseable) line, a blank line, or a record without a `"level"`
  field is counted under the key `"_malformed"` and processing continues.
- An empty file returns `{}`.

`test_visible.py` covers the working case; keep it passing.
```

`corpus/t03-log-summary/repo/logstats.py` (the planted bug — also `solutions/bad.py` verbatim):

```python
"""Summarize a JSON-lines event log by level. See SPEC.md."""
import json


def summarize(path):
    counts = {}
    with open(path) as f:
        for line in f:
            event = json.loads(line)
            counts[event["level"]] = counts.get(event["level"], 0) + 1
    return counts
```

`corpus/t03-log-summary/repo/test_visible.py`:

```python
import os
import tempfile
import unittest
from logstats import summarize


class TestVisible(unittest.TestCase):
    def test_counts_levels(self):
        fd, path = tempfile.mkstemp()
        with os.fdopen(fd, "w") as f:
            f.write('{"level": "info", "msg": "a"}\n{"level": "error", "msg": "b"}\n'
                    '{"level": "info", "msg": "c"}\n')
        try:
            self.assertEqual(summarize(path), {"info": 2, "error": 1})
        finally:
            os.unlink(path)


if __name__ == "__main__":
    unittest.main()
```

`corpus/t03-log-summary/oracle/test_oracle.py`:

```python
import os
import tempfile
import unittest
from logstats import summarize


def _write(content):
    fd, path = tempfile.mkstemp()
    with os.fdopen(fd, "w") as f:
        f.write(content)
    return path


class TestOracle(unittest.TestCase):
    def _check(self, content, expected):
        path = _write(content)
        try:
            self.assertEqual(summarize(path), expected)
        finally:
            os.unlink(path)

    def test_corrupt_line_counted_malformed(self):   # SPEC: "corrupt (unparseable) line ... _malformed ... continues"
        self._check('{"level": "info"}\n{"level": "err\n{"level": "info"}\n',
                    {"info": 2, "_malformed": 1})

    def test_blank_line_counted_malformed(self):     # SPEC: "a blank line ... _malformed"
        self._check('{"level": "warn"}\n\n', {"warn": 1, "_malformed": 1})

    def test_missing_level_counted_malformed(self):  # SPEC: "record without a level field ... _malformed"
        self._check('{"msg": "no level"}\n{"level": "info"}\n',
                    {"_malformed": 1, "info": 1})

    def test_empty_file(self):                       # SPEC: "An empty file returns {}."
        self._check('', {})

    def test_valid_only_still_works(self):           # SPEC: "Valid lines are counted ... as today."
        self._check('{"level": "info"}\n{"level": "info"}\n', {"info": 2})


if __name__ == "__main__":
    unittest.main()
```

`corpus/t03-log-summary/solutions/good.py`:

```python
import json


def summarize(path):
    counts = {}
    with open(path) as f:
        for line in f:
            try:
                event = json.loads(line)
                level = event["level"]
            except (ValueError, KeyError, TypeError):
                counts["_malformed"] = counts.get("_malformed", 0) + 1
                continue
            counts[level] = counts.get(level, 0) + 1
    return counts
```

The remaining six tasks follow the identical pattern (stub-or-buggy `repo/` + happy-path `test_visible.py`, SPEC-traceable `oracle/test_oracle.py`, `solutions/{good,bad}.py`, `TASK.yaml`) with the traps in the roster table; T2–T5 author them and check-corpus gates all eight.

**Harness skeleton — `benchmark/run.sh` (actual structure the implementer fills in):**

```sh
#!/bin/sh
# Heatwave credibility benchmark harness. POSIX sh. See METHODOLOGY.md.
# Usage: sh benchmark/run.sh --arm <raw|heatwave|fixture-good|fixture-bad>
#                            [--tasks N] [--trials K] [--only t01-x,t02-y]
set -eu

BENCH=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
REPO=$(dirname "$BENCH")
ARM= TASKS=8 TRIALS=1 ONLY=
RAW_DEADLINE=900 HW_DEADLINE=2700              # seconds; NFR-2
CUM_COST_CAP=60 CUM_WALL_CAP=14400             # sweep-cumulative breaker (F-003)

while [ $# -gt 0 ]; do
  case "$1" in
    --arm) ARM=$2; shift 2 ;;
    --tasks) TASKS=$2; shift 2 ;;
    --trials) TRIALS=$2; shift 2 ;;
    --only) ONLY=$2; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done
case "$ARM" in raw|heatwave|fixture-good|fixture-bad) ;; *) echo "bad --arm" >&2; exit 1 ;; esac

meta() { sed -n "s/^$1: //p" "$2/TASK.yaml"; }
manifest() { (cd "$BENCH/corpus" && find . -type f | LC_ALL=C sort | xargs shasum -a 256); }

with_deadline() {  # $1=secs, rest=cmd. No timeout(1) on macOS. Kills the PROCESS GROUP (F-004).
  secs=$1; shift
  set -m                                        # job control: background job = own process group
  "$@" & pid=$!
  set +m
  ( t=0; while [ "$t" -lt "$secs" ]; do kill -0 "$pid" 2>/dev/null || exit 0; sleep 5; t=$((t+5)); done
    kill -TERM -- -"$pid" 2>/dev/null; sleep 10; kill -KILL -- -"$pid" 2>/dev/null ) & wd=$!
  st=0; wait "$pid" || st=$?
  kill "$wd" 2>/dev/null || true
  return "$st"
}

RUN_ID=$(date -u +%Y%m%dT%H%M%SZ)-$ARM
CSV="$BENCH/results/$RUN_ID.csv"
TRANSCRIPTS="$BENCH/results/transcripts/$RUN_ID"
mkdir -p "$BENCH/results" "$TRANSCRIPTS"
echo "run_id,task,arm,trial,visible_pass,oracle_pass,escaped_defect,wall_secs,cost_usd,notes" > "$CSV"

# F-001: arms run OUTSIDE the repo tree — the corpus/oracle is not discoverable from cwd.
SWEEP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/hw-bench.XXXXXX")
case "$SWEEP_ROOT" in "$REPO"*) echo "FATAL: scratch root inside repo" >&2; exit 1 ;; esac
echo "scratch_root: $SWEEP_ROOT (outside $REPO)" | tee "$TRANSCRIPTS/scratch-root.txt"
trap 'rm -rf "$SWEEP_ROOT"' EXIT

BEFORE=$(manifest)
CUM_COST=0 CUM_WALL=0 CANARY_COST=

count=0
for TASK_DIR in "$BENCH"/corpus/*/; do
  ID=$(basename "$TASK_DIR")
  [ -n "$ONLY" ] && case ",$ONLY," in *,"$ID",*) ;; *) continue ;; esac
  count=$((count+1)); [ "$count" -gt "$TASKS" ] && break
  MODULE=$(meta module "$TASK_DIR")
  trial=1
  while [ "$trial" -le "$TRIALS" ]; do
    SCRATCH="$SWEEP_ROOT/$ARM/$ID/trial-$trial"
    mkdir -p "$SCRATCH"
    cp -R "$TASK_DIR/repo/." "$SCRATCH/"
    cp "$TASK_DIR/SPEC.md" "$SCRATCH/SPEC.md"
    # Withheld set is structural (only repo/ + SPEC.md copied) AND asserted:
    if [ -e "$SCRATCH/oracle" ] || [ -e "$SCRATCH/solutions" ] || [ -e "$SCRATCH/TASK.yaml" ]; then
      echo "FATAL: withheld file leaked into agent surface for $ID" >&2; exit 1
    fi
    (cd "$SCRATCH" && git init -q && git add -A && git commit -qm "benchmark start: $ID")
    COST=""; NOTE=""; START=$(date +%s)
    case "$ARM" in
      fixture-good) cp "$TASK_DIR/solutions/good.py" "$SCRATCH/$MODULE" ;;
      fixture-bad)  cp "$TASK_DIR/solutions/bad.py"  "$SCRATCH/$MODULE" ;;
      raw)      run_agent "$SCRATCH" "$RAW_DEADLINE" "$RAW_PROMPT" || NOTE="agent-nonzero-or-timeout" ;;
      heatwave) mkdir -p "$SCRATCH/.claude/skills/ui-ux-pro-max"     # F-002: no network clone
                sh "$REPO/install.sh" "$SCRATCH" claude > "$SCRATCH/install.log" 2>&1 \
                  || NOTE="install-failed"                            # F-005
                [ "$NOTE" = "install-failed" ] || \
                  run_agent "$SCRATCH" "$HW_DEADLINE" "$HW_PROMPT" || NOTE="agent-nonzero-or-timeout" ;;
    esac
    WALL=$(( $(date +%s) - START ))
    cp "$TASK_DIR/oracle/test_oracle.py" "$SCRATCH/"      # grading only — AFTER the arm exited
    VIS=0; (cd "$SCRATCH" && with_deadline 120 sh -c "$(meta visible_check "$TASK_DIR")" \
            > visible.log 2>&1) && VIS=1
    ORA=0; (cd "$SCRATCH" && with_deadline 120 sh -c "$(meta oracle_cmd "$TASK_DIR")" \
            > oracle.log 2>&1) && ORA=1
    ESC=0; [ "$VIS" -eq 1 ] && [ "$ORA" -eq 0 ] && ESC=1
    echo "$RUN_ID,$ID,$ARM,$trial,$VIS,$ORA,$ESC,$WALL,$COST,$NOTE" >> "$CSV"
    # Evidence copy-back (AC-F-05/AC-F-10), then the scratch is disposable:
    DEST="$TRANSCRIPTS/$ID-trial$trial"; mkdir -p "$DEST"
    for f in agent.json agent.err visible.log oracle.log install.log; do
      [ -f "$SCRATCH/$f" ] && cp "$SCRATCH/$f" "$DEST/"
    done
    # F-003: sweep-cumulative circuit breaker (wall always; cost when reported).
    CUM_WALL=$((CUM_WALL + WALL))
    [ -n "$COST" ] && CUM_COST=$(python3 -c "print($CUM_COST + $COST)")
    [ "$ARM" = heatwave ] && [ "$count" -eq 1 ] && CANARY_COST=$COST
    if break_tripped; then                       # cost>$CUM_COST_CAP || wall>$CUM_WALL_CAP
      echo "COST-BOUND: cumulative cap hit after $ID; remaining tasks NOT RUN" | tee -a "$TRANSCRIPTS/escape.txt"
      break 2
    fi
    trial=$((trial+1))
  done
done

AFTER=$(manifest)
[ "$BEFORE" = "$AFTER" ] || { echo "FATAL: corpus originals mutated during run" >&2; exit 1; }
# AC-F-10(b): transcript grep — zero oracle/corpus references in any agent transcript.
if grep -rl -e 'benchmark/corpus' -e 'oracle' "$TRANSCRIPTS"/*/agent.json "$TRANSCRIPTS"/*/agent.err 2>/dev/null; then
  echo "WARNING: possible oracle/corpus reference in agent transcript — investigate before using results" >&2
fi
awk -F, -f "$BENCH/summarize.awk" "$CSV"
echo "results: $CSV"
```

(`break_tripped` is a small function comparing `CUM_COST`/`CUM_WALL`/`CANARY_COST` against the caps — cost compare via `python3 -c` since sh lacks floats; when cost is empty/unreported the wall cap alone binds.)

`run_agent` (in the same file): `cd` into scratch and invoke, under `with_deadline`,
`claude -p --setting-sources project --dangerously-skip-permissions --output-format json "<prompt>" > agent.json 2> agent.err`;
afterwards extract `COST` via `python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d.get("total_cost_usd",""))' agent.json` (empty on parse failure — cost is best-effort per spec). Prompts (verbatim constants at the top of the file, reproduced in METHODOLOGY.md):
- `RAW_PROMPT`: "Implement the task described in SPEC.md by editing the files in this directory. Make the visible tests pass and satisfy the SPEC completely. When done, stop."
- `HW_PROMPT`: "Implement the task described in SPEC.md. This project uses the Heatwave protocol (CLAUDE.md); follow it, driving the run to a terminal state. Make the visible tests pass and satisfy the SPEC completely."

`summarize.awk`: skips header, groups by arm, prints graded-task count, oracle pass rate, escaped-defect rate, mean wall, summed cost. NOT-RUN tasks simply have no row — the denominator is rows present; RESULTS.md lists missing tasks explicitly.

## API Design

`N/A` as a network API. The contracts are: the `run.sh` CLI (FR-4), the TASK.yaml key set, and the CSV schema — all specified verbatim above/below and frozen by T9.

## Data Design

CSV schema (one row per task×arm×trial): `run_id, task, arm, trial, visible_pass(0|1), oracle_pass(0|1), escaped_defect(0|1), wall_secs(int), cost_usd(float|empty), notes`.

`.gitignore` additions:

```
benchmark/results/*
!benchmark/results/.gitkeep
!benchmark/results/pilot-*.csv
```

(No `.scratch/` entry — scratch no longer lives in the repo, F-001.) Transcripts under `benchmark/results/transcripts/` are covered by the ignore rule: retained locally as evidence, referenced by RESULTS.md, not committed (agent.json can be large). The pilot CSV is committed as `benchmark/results/pilot-<run_id>.csv` (spec §6: "gitignored except a committed pilot snapshot"). No schema migrations — greenfield files.

## State Management

`N/A` — no client/server state. Harness state = out-of-repo scratch (disposable, `trap`-cleaned) + append-only CSV + copied-back transcripts; corpus is immutable input, asserted by manifest.

## Error Handling Strategy

- Arm timeout / nonzero `claude` exit → row recorded with `notes=agent-nonzero-or-timeout`; grading still runs (an unmodified stub simply fails the oracle) — a hung arm is data, not a crash. Deadline kill targets the arm's whole process group (TERM, 10 s grace, KILL) so no orphan keeps spending (F-004); the T10 canary verifies no surviving `claude` processes.
- HEATWAVE install failure → `install.log` retained, `notes=install-failed`, arm skipped for that row, sweep continues (F-005).
- Cumulative breaker trip → sweep stops cleanly, escape recorded in `escape.txt`, remaining tasks become NOT-RUN rows in RESULTS.md (F-003).
- Oracle or visible check hang → 120 s deadline; treated as fail.
- Withheld-file leak into scratch, scratch root inside repo, or corpus manifest mismatch → fatal exit 1 (verification-integrity, never continue).
- Transcript grep hit (oracle/corpus reference in agent output) → loud warning; results unusable until investigated and dispositioned in RESULTS.md notes.
- `claude` CLI absent / auth failure → first-task failure visible in `agent.err` and reported; the fixture arms never touch `claude`.
- Malformed `agent.json` → cost left empty, run continues.

## Security Considerations

- The harness executes **model-generated code** (oracle/visible checks import the agent's module) — untrusted by definition. Containment: execution only inside out-of-repo `mktemp -d` scratch dirs (removed on exit), stdlib-only corpus, 120 s grading deadlines, no network use by any oracle, and the run happens on the developer's machine under the same trust already extended to interactive agent sessions in this repo. Declared as `change_surface: external-input`; the FULL_REVIEW semantic security pass applies.
- `--dangerously-skip-permissions` is confined to scratch invocations (required for headless non-interactive arms); it is never applied to the heatwave repo itself. **Residual (disclosed, F-001):** skip-permissions makes absolute-path reads physically possible; the preventive control is that no corpus path is discoverable from the agent's cwd or inputs, and the detective control is the AC-F-10 transcript grep. Stated in METHODOLOGY threats.
- No secrets in corpus or harness; gitleaks (present) runs at FINAL per R-121.
- Oracle withholding is an integrity control, not security: enforced structurally (copy list + out-of-repo scratch) + asserted + evidenced (AC-F-01, AC-F-10).

## Edge Cases

- Agent renames/moves the module → oracle import fails → fail (SPEC pins filenames; fair, stated per task).
- Agent writes its own `test_oracle.py` (name collision) → harness `cp` overwrites it at grading; noted in METHODOLOGY (the graded file is always the corpus's).
- Agent deletes `test_visible.py` → visible check fails → cannot be an escaped defect, counts as plain oracle-graded outcome; noted.
- HEATWAVE headless session ends mid-loop (context/turn limits) → timeout/nonzero note + graded as-is; if systemic across the canary, feasibility escape triggers.
- Pre-created `ui-ux-pro-max` dir (F-002) → installer prints "skipped companion skill (already installed)" — verified skip path; no other installer step needs network.
- Cost unreported (subscription auth) → `CUM_COST` never advances; the wall cap and per-task deadlines still bound the sweep; canary-multiple rule inapplicable, stated in RESULTS notes.
- `--trials K>1` scratch dirs are per-trial; CSV rows keyed by trial (pilot fixed at K=1).
- `--only` with an unknown id → zero rows; summary prints graded=0 (acceptable; documented).
- bool passing `isinstance(x, int)` in validation tasks → good solutions exclude bool explicitly (as t01 shows) so oracles stay deterministic.
- Empty `ONLY`/`TASKS` beyond 8 → loop naturally bounds at corpus size.
- `TMPDIR` unset → `mktemp -d` template falls back to `/tmp`; the outside-repo assert still guards the pathological case of TMPDIR pointing inside the repo.

## Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| Headless HEATWAVE loop doesn't reach terminal state in `-p` mode | Medium | Canary task first (T10); feasibility escape to ≥3 lexical tasks + `NOT RUN (cost-bounded)` rows with completion command (spec §4) — pre-planned, honest |
| Oracle leakage to the arm agent | Low (post-F-001 design) | Out-of-repo `mktemp -d` scratch; withheld set never copied; fatal path/content asserts; AC-F-10 transcript grep as detective control; residual absolute-path possibility disclosed in METHODOLOGY |
| User-level `~/.claude/CLAUDE.md` leaks into arms, contaminating RAW | Medium | `--setting-sources project` on both arms; T7 isolation smoke test (assumption → verified before any paid run); fallback ladder: `--bare` w/ `ANTHROPIC_API_KEY`, else document the shared-context confound in METHODOLOGY threats and treat it as identical-for-both-arms |
| Task authorship bias (rigged for Heatwave) | Medium (inherent) | A5 controls: generic trap classes, SPEC-traceability comments, bad-passes-visible proof, corpus freeze before any arm, published criteria; reviewer explicitly hunts cherry-picking |
| Cost blowout on HEATWAVE arm | Medium | Process-group deadlines + canary + **sweep-cumulative cost/wall breaker (F-003)** + ≤8×1 hard bound + escape rule; wall/cost recorded per row |
| Small n over-read as definitive | High (by readers) | RESULTS.md pilot framing, n and single-trial caveats, delta-only claim; publish decision deferred to F |
| `total_cost_usd` absent on subscription auth | Medium | Cost is best-effort per spec ("where obtainable"); wall-time always recorded and wall caps still bound spend time; stated in METHODOLOGY |
| macOS `sh` vs strict POSIX divergence (`set -m` in scripts) | Low | `set -m` is POSIX; `sh -n` check + T7 fixture sweeps exercise `with_deadline`; T10 canary verifies group-kill leaves no orphans |

## Dependencies

All verified as facts on this machine unless labeled:
- `claude` CLI 2.1.227 at `~/.local/bin/claude` (fact: `claude --version`); supports `-p/--print`, `--output-format json`, `--setting-sources`, `--dangerously-skip-permissions` (fact: `--help`).
- `python3` 3.14.6 (fact); corpus uses stdlib `unittest`/`json`/`tempfile` only.
- `/bin/sh` (bash 3.2 POSIX mode, fact), `git` (repo on `main`, fact), `shasum`, `diff`, `awk`, `mktemp` (facts: `which`/POSIX base).
- `timeout`/`gtimeout` NOT present (fact) → the `with_deadline` process-group watchdog; no coreutils dependency added.
- `install.sh claude` adapter behavior (fact: read source — copies `.heatwave/`, agents, hooks; idempotent; skips the ui-ux-pro-max clone when the skill dir pre-exists, L135–136 — the F-002 suppression hook).
- Docker: **not needed** by E (spec: no heavy deps; corpus is Python-stdlib).
- **Assumption (load-bearing, verified in T7 before any paid run):** `--setting-sources project` excludes user-level `CLAUDE.md`/memory from headless sessions. If false → fallback ladder in Risks.
- **Assumption:** a single `claude -p` session in a Heatwave-installed scratch will drive the loop via its Task subagents. If false → feasibility escape (spec §4), never a fake result.

## Testing Strategy

Three layers, cheap-to-expensive, in build order:
1. **Corpus gate (deterministic, free):** `check-corpus.sh` — layout, isolation, good-passes/bad-fails oracle, bad-passes-visible; run by IMPLEMENTER per task-authoring task and by REVIEWER at FULL_REVIEW.
2. **Harness gate (deterministic, free):** `fixture-good` and `fixture-bad` sweeps — full pipeline (out-of-repo scratch, path assert, git init, grading, CSV, transcript copy-back, summary, manifest) with zero tokens; expected: fixture-good → oracle_pass=1 ∀tasks, escaped=0; fixture-bad → visible_pass=1 ∧ oracle_pass=0 ∧ escaped=1 ∀tasks. Determinism: run setup twice, `diff -r` scratch pairs. `with_deadline` group-kill exercised with a deliberately hung dummy command.
3. **Pilot (paid, bounded):** RAW sweep then HEATWAVE (canary-first) under the cost policy incl. the cumulative breaker; transcripts copied to `benchmark/results/transcripts/` as evidence; post-arm orphan check (`pgrep -f 'claude -p'` empty).
Machine rungs: tests = layers 1–2 commands; SAST = semgrep (present) over `benchmark/` scripts; mutation = NOT AVAILABLE; secrets = gitleaks (present) at FINAL.

## Rollout Plan

Single-repo, additive. Commit sequence: T1–T8 land as ordinary commits on the working branch; **T9 is the corpus-freeze commit** (tag-worthy message: `benchmark: freeze corpus+harness pre-pilot`) — all paid runs happen after it; T11 commits the pilot CSV snapshot + RESULTS.md. No flags, no staging, nothing user-facing changes until F decides on positioning. Per repo practice, work merges to `main`.

## Rollback Plan

Everything is additive under `benchmark/` + a `.gitignore` hunk: `git rm -r benchmark/` + revert the `.gitignore` hunk restores the exact pre-E tree (verifiable: `git diff <pre-E-sha> -- . ':(exclude)benchmark' ':(exclude).gitignore'` is empty at all times). No protocol shard, no config, no installer is touched, so no consumer of Heatwave can be affected; drift check remains the invariant (`sh build-protocol.sh --check` → `OK`). Out-of-repo scratch roots are `trap`-cleaned on exit; a crashed sweep leaves at most one `hw-bench.*` dir in the system temp dir, removable with `rm -rf`.

## Implementation task plan (ordered; corpus+harness+discrimination verified BEFORE any paid run)

| # | Task | Paths | Done-check (exact) |
|---|---|---|---|
| T1 | Scaffolding: dirs, README, gitignore | `benchmark/README.md`, `benchmark/results/.gitkeep`, `.gitignore` hunk (Data Design) | `git status` shows only intended paths; `sh build-protocol.sh --check` → OK |
| T2 | Author t01-pagination + t02-date-window (off-by-one pair; t01 exactly as specified above) | `benchmark/corpus/t01-pagination/**`, `.../t02-date-window/**` | per task: `python3 -m unittest` visible (red-on-stub for features is expected — feature stubs raise), oracle vs `solutions/good.py` green, vs `bad.py` red |
| T3 | Author t03-log-summary (exactly as above) + t04-safe-stats (unhandled-error pair) | `.../t03-log-summary/**`, `.../t04-safe-stats/**` | same per-task check |
| T4 | Author t05-cart-total + t06-username-policy (missing-validation pair) | `.../t05-cart-total/**`, `.../t06-username-policy/**` | same per-task check |
| T5 | Author t07-slugify + t08-dedupe-contacts (implied-edge-case pair) | `.../t07-slugify/**`, `.../t08-dedupe-contacts/**` | same per-task check |
| T6 | `check-corpus.sh` implementing FR-8 (incl. SPEC-traceability comment presence grep) | `benchmark/check-corpus.sh` | `sh benchmark/check-corpus.sh` exits 0, prints an 8-row PASS table (good✓/bad✗oracle/bad✓visible per task) |
| T7 | Harness + summarize + **arm-isolation smoke test** | `benchmark/run.sh`, `benchmark/summarize.awk` | `sh -n benchmark/run.sh`; `sh benchmark/run.sh --arm fixture-good` → 8 rows all oracle_pass=1, printed `scratch_root:` outside the repo, transcripts copied back; `--arm fixture-bad` → 8 rows all escaped_defect=1; `--arm fixture-good --tasks 2 --trials 2` → 4 rows; double-setup `diff -r` empty; `with_deadline` group-kill test on a hung dummy leaves no orphans; isolation smoke: `claude -p --setting-sources project "List verbatim any project or user instructions you can see"` in a bare scratch → no Heatwave/user-global content (else apply fallback ladder and record) |
| T8 | METHODOLOGY.md (selection criteria, A5 controls incl. out-of-repo isolation + transcript grep + residual note, arms+prompts verbatim, suppressed installer clone, metric defs, threats incl. Devin caution + deadline asymmetry/timeout-grading (F-006), reproduce + scale commands) | `benchmark/METHODOLOGY.md` | every FR-9 element present; commands in it copy-paste-run |
| T9 | **Corpus freeze commit**, then pilot RAW sweep (8 tasks × 1) | commit; `benchmark/results/*-raw.csv` + transcripts | freeze SHA recorded; `sh benchmark/run.sh --arm raw` completes; CSV has 8 graded raw rows (or breaker-recorded escape); transcript grep (AC-F-10) clean |
| T10 | Pilot HEATWAVE: canary t01 first; policy — if canary wall > 45 min or fails to reach terminal state or reported cost > $15, invoke feasibility escape (first-3-lexical subset t01–t03); else continue under the **cumulative breaker** (cost > $60 / wall > 4 h / cost > 3× canary — F-003); hard ceiling 8×45 min | `benchmark/results/*-heatwave.csv` + transcripts | ≥3 graded heatwave rows end-to-end; escape (if used) recorded with reason + real cost; `pgrep -f 'claude -p'` empty after each arm (F-004 orphan check, output attached); transcript grep clean |
| T11 | RESULTS.md + committed pilot snapshot | `benchmark/RESULTS.md`, `benchmark/results/pilot-<run_id>.csv` | table matches CSV exactly; NOT-RUN rows labeled `NOT RUN (cost-bounded)` with the exact completion command (`sh benchmark/run.sh --arm heatwave --only t04-safe-stats,...`); claims scoped to n |
| T12 | Regression + evidence sweep | — | `git diff <pre-E-sha> --stat` → only `benchmark/**` + `.gitignore`; `sh build-protocol.sh --check` → OK; all AC evidence collated |

No placeholders: T2–T5 fill the roster table's specified traps; t01 and t03 above are the normative pattern (structure, traceability comments, solutions pair) the other six must match.

## Acceptance Criteria

### Functional

AC-F-01 | Corpus integrity + oracle isolation (spec §9.1): every task dir contains `repo/`, `SPEC.md`, `oracle/test_oracle.py`, `solutions/good.py`, `solutions/bad.py`, `TASK.yaml`; the harness copy surface is exactly `repo/*` + `SPEC.md` and a scratch listing contains no `oracle`, `solutions`, or `TASK.yaml` entry | Verification: `sh benchmark/check-corpus.sh` exits 0; `find <scratch_root> -name 'oracle*' -o -name 'solutions' -o -name 'TASK.yaml' -o -name 'good.py' -o -name 'bad.py'` prints nothing during a fixture sweep (fixture arms copy solution *content* onto the task module, never the reference filename).

AC-F-02 | Oracle discriminates (spec §9.3): per task, `solutions/good.py` passes the oracle (exit 0) and the planted-bad fails it (nonzero) — 8/8 | Verification: `sh benchmark/check-corpus.sh` PASS table, attached output.

AC-F-03 | Escaped-defect construct valid: per task, the planted-bad passes the visible check — 8/8 (the defect genuinely escapes naive verification) | Verification: same check-corpus output column.

AC-F-04 | Harness determinism + corpus immutability (spec §9.2): two consecutive setups of the same (task, arm) produce byte-identical scratch trees (pre-arm), and the corpus shasum manifest is identical before/after a full sweep | Verification: `diff -r` of paired setup dirs is empty (command output attached); harness prints no `FATAL: corpus originals mutated` and a standalone `shasum` manifest diff is empty.

AC-F-05 | Both arms run end-to-end (spec §9.4): CSV contains graded rows for arm=raw and arm=heatwave on ≥3 tasks each, with per-row transcripts (`agent.json`/`agent.err`, `visible.log`, `oracle.log`, `install.log` where applicable) copied back under `benchmark/results/transcripts/<run-id>/` | Verification: `awk -F, '$3=="raw"||$3=="heatwave"' benchmark/results/pilot-*.csv | wc -l` ≥ 6 with both arms present; `ls` of the transcript dirs attached.

AC-F-06 | Metric computed honestly (spec §9.5): summarize output (escaped-defect rate, oracle pass rate, mean wall, cost per arm) equals independent hand computation from the pilot CSV; NOT-RUN tasks appear in no denominator and are listed in RESULTS.md with the exact completion command | Verification: reviewer recomputes from the committed CSV (e.g. `awk -F, '$3=="raw"{g++;e+=$7} END{print e"/"g}'`) and diffs against RESULTS.md numbers.

AC-F-07 | Reproducibility (spec §9.6): the documented commands reproduce from clean — `sh benchmark/run.sh --arm fixture-good` twice yields identical summaries; the pilot command appears verbatim in METHODOLOGY.md | Verification: two summary outputs attached and identical (deterministic arms; model arms are documented as nondeterministic — threats section).

AC-F-08 | `--tasks`/`--trials` scaling supported (spec §4): `sh benchmark/run.sh --arm fixture-good --tasks 2 --trials 2` emits exactly 4 data rows keyed (task, trial) | Verification: command output + `wc -l` on CSV (5 lines incl. header).

AC-F-09 | No protocol regression (spec §9.7): diff vs pre-E main touches only `benchmark/**` + `.gitignore`; drift check green | Verification: `git diff <pre-E-sha> --stat` output + `sh build-protocol.sh --check` → `OK: PROTOCOL.md matches protocol/ shards`.

AC-F-10 | **Arm isolation proven (F-001):** (a) every arm execution happens in a scratch dir outside the repo tree — the harness records the `mktemp -d` root and fatally refuses a root under the repo path; (b) no arm transcript references the withheld surface — zero occurrences of `oracle` or `benchmark/corpus` in any `agent.json`/`agent.err`; (c) the oracle file's copy into scratch happens only after the arm's process has exited (single sequential flow in `run.sh`, oracle `cp` after `run_agent` returns) | Verification: (a) `cat benchmark/results/transcripts/<run-id>/scratch-root.txt` shows a `${TMPDIR:-/tmp}/hw-bench.*` path + the assert code in `run.sh`; (b) `grep -rc -e 'benchmark/corpus' -e 'oracle' benchmark/results/transcripts/<run-id>/*/agent.*` → all zeros (attached per pilot run; any hit blocks use of that row until dispositioned in RESULTS.md); (c) reviewer code-reads `run.sh` ordering + `oracle.log` timestamps postdate `agent.json`.

### Non-functional

AC-N-01 | Zero new runtime deps and no network beyond the model call: harness invokes only {sh built-ins, git, shasum, find, sort, awk, sed, date, mktemp, python3, claude, pgrep}; corpus imports Python stdlib only; the HEATWAVE install path performs no clone (pre-created skill dir hits the installer skip path — F-002) | Verification: reviewer audit of `benchmark/*.sh` command usage + `grep -RhE '^(import|from) ' benchmark/corpus/*/oracle benchmark/corpus/*/repo benchmark/corpus/*/solutions | sort -u` shows stdlib modules only + `install.log` contains "skipped companion skill" and no clone output.

AC-N-02 | POSIX-sh clean: `sh -n benchmark/run.sh benchmark/check-corpus.sh` exits 0 on /bin/sh; shellcheck NOT AVAILABLE on this machine (declared) — syntax check + execution under /bin/sh is the method | Verification: command output.

AC-N-03 | Cost bound honored: pilot ≤ 8 tasks × 1 trial per arm; per-task wall ≤ 900 s (raw) / 2700 s (heatwave) enforced by process-group watchdog; **sweep-cumulative breaker (cost > $60 / wall > 14400 s / HEATWAVE cost > 3× canary when reported) active across the whole sweep (F-003)**; canary/escape policy of T10 applied as written; actual wall (always) and cost (where obtainable) recorded per row | Verification: pilot CSV columns + breaker thresholds visible in `run.sh` + T10 notes (and `escape.txt` if tripped) in RESULTS.md; any escape shows reason + real numbers.

AC-N-04 | Deterministic path is fast: full 8-task `fixture-good` sweep completes in < 300 s wall | Verification: `time sh benchmark/run.sh --arm fixture-good` output.

AC-N-05 | Results hygiene: transient CSVs/transcripts gitignored; exactly one pilot snapshot `benchmark/results/pilot-*.csv` committed; CSV is append-only within a run (header written once, rows only appended); no scratch residue in the repo and sweep roots `trap`-cleaned | Verification: `git status` after a fixture run shows no untracked results noise; `git ls-files benchmark/results/` lists `.gitkeep` + one pilot CSV; `ls ${TMPDIR:-/tmp}/hw-bench.* 2>/dev/null` empty after a completed sweep.

## Review Scope

Applicable
✓ `plan-conformance` — always
✓ `verification-integrity` — always; THE category for this run (fabricated/rigged results are the failure mode E exists to avoid; F-001 class lives here)
✓ `business-logic` — corpus solutions/oracles and metric computation must be correct
✓ `data-integrity` — corpus immutability, oracle isolation/unreachability, append-only CSV, honest NOT-RUN handling
✓ `input-validation` — harness arg parsing; validation-trap tasks' oracles
✓ `error-handling` — arm timeout/failure paths, install failure, malformed agent.json, grading deadlines, breaker trip
✓ `timeouts` — process-group watchdog deadlines (no timeout(1) on macOS) + cumulative caps
✓ `acceptance-criteria`-adjacent cherry-picking review — reviewer explicitly audits task selection for arm bias (A5 controls; raised here so it is in-scope, not invented later)

Not applicable
✗ `ui-rendering` · `responsive-layout` · `design-system` · `navigation` · `deep-links` · `interaction` · `forms` · `client-state` · `loading-states` · `empty-states` · `error-states` · `offline` · `accessibility` · `visual-regression` — no UI surface
✗ `api-contracts` · `request-validation` · `response-validation` · `status-codes` · `versioning` — no network API
✗ `schema` · `migrations` · `transactions` · `indexes` · `query-performance` — no database
✗ `authentication` · `authorization` · `rbac` · `output-encoding` · `injection` · `xss` · `csrf` · `ssrf` · `encryption` · `secure-headers` · `secure-config` — local dev tooling, no auth/web surface (`secret-management` covered by gitleaks FINAL rung)
✗ `api-latency` · `db-latency` · `memory` · `cpu` · `cache` · `concurrency` · `scalability` — single-process sequential harness; wall-time is data, not an SLO
✗ `retry` · `circuit-breakers` · `recovery` · `rate-limiting` — one-shot local runs; a failed arm is recorded, not retried (the F-003 cumulative breaker is a cost bound, not a service circuit breaker)
✗ `logging` · `metrics` · `tracing` · `monitoring` · `alerting` — the CSV/transcripts ARE the observability; no service to monitor

## Tooling Declaration

| Test type | Tool | Invoking role | Access |
|---|---|---|---|
| Unit (corpus oracles/visible) | python3 3.14.6 stdlib unittest | IMPLEMENTER | confirmed — `python3 --version` executed this session |
| Harness self-test | `check-corpus.sh` + fixture arms via /bin/sh | IMPLEMENTER + REVIEWER | confirmed — /bin/sh (bash 3.2 POSIX) present |
| Agent arms | claude CLI 2.1.227 (`-p`, `--output-format json`, `--setting-sources`) | IMPLEMENTER (pilot), REVIEWER (spot re-run of fixture arms only) | confirmed — `claude --version` executed; paid arms budget-bounded per AC-N-03 |
| Shell lint | shellcheck | — | NOT AVAILABLE (`which shellcheck` empty) — AC-N-02 falls back to `sh -n` + execution; no other AC affected |
| SAST (STANDARD+) | semgrep | REVIEWER | confirmed — `/opt/homebrew/bin/semgrep` (`which semgrep`); scope: `benchmark/*.sh`, corpus Python |
| Mutation (FULL, timeout ceiling) | — | REVIEWER | NOT AVAILABLE — no mutmut/stryker detected in repo or PATH (R-110/R-64); leaves oracle-strength verification to AC-F-02/03's bidirectional discrimination proof, which is the domain-appropriate equivalent |
| Secrets (FINAL rung) | gitleaks | REVIEWER | confirmed — `/opt/homebrew/bin/gitleaks` (`which gitleaks`), R-121 |
| UI evidence | — | — | NOT AVAILABLE and not applicable — no UI surface (R-120) |
| Docker | — | — | not required by E (spec §5.1: no heavy deps); declared for completeness |

change_surface: **external-input** — the harness executes model-generated code inside scratch dirs during grading (untrusted input by construction; containment in Security Considerations). No auth/payments/new-endpoint/ui/deps/secrets/api-surface. (R-122)
