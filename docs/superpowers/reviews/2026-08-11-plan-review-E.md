# Review Report

task_id: 2026-08-11-credibility-benchmark | artifact_type: review-report | iteration: 2 | review_type: PLAN_REVIEW | produced_by: REVIEWER (claude-fable-5) | timestamp: 2026-08-11

Artifact under review: `docs/superpowers/plans/2026-08-11-credibility-benchmark.md` (iteration 2)
Authority: `docs/specs/2026-08-11-credibility-benchmark-design.md` (approved spec)

## Verdict (iteration 2)

GATE_MET — APPROVED
Blockers: 0 open | Majors: 0 open | Minor: 0 open | Nit: 0 open
(All 6 iteration-1 findings resolved and verified below.)

## Reconciliation (iteration 2)

| Finding ID | Prior status | Current status | Change reason (verified against plan iteration 2 + repo) |
|---|---|---|---|
| F-001 (Major, oracle leakage) | Open | **Resolved** | Scratch now `mktemp -d "${TMPDIR:-/tmp}/hw-bench.XXXXXX"` outside the repo (skeleton L427); fatal assert `case "$SWEEP_ROOT" in "$REPO"*)` refuses an in-repo root (L428) and covers the TMPDIR-inside-repo edge case (Edge Cases L560); copy surface is exactly `repo/*`+`SPEC.md` with `TASK.yaml` now also withheld and content-asserted (L448–450); oracle `cp` sits strictly after the arm case block exits (L464); new AC-F-10 proves isolation three ways — recorded scratch root outside repo, per-row transcript grep for `oracle`/`benchmark/corpus` = zero (a hit blocks use until dispositioned), and code-read of ordering. Residual (absolute-path reads physically possible under skip-permissions) honestly disclosed in FR-9, Security Considerations, Risks, and the METHODOLOGY threats list with the grep named as the detective control. Ground-truthed: installed `.heatwave/` content and installer stdout contain no repo path and zero occurrences of "oracle" (grep of protocol/ + adapters/), so scratch carries no pointer to the answer key and the detective grep has no false-positive source in installed files. Leakage path genuinely closed: the agent's cwd no longer reaches the corpus by any `cd ..`. |
| F-002 (Minor, network clone) | Open | **Resolved** | Harness pre-creates `$SCRATCH/.claude/skills/ui-ux-pro-max` before install (skeleton L457); verified against install.sh L134–136 — the `-d "$SKILL_DIR"` branch prints "skipped companion skill" and performs no clone. AC-N-01 now requires that install.log line as evidence; NFR-1 states "no network beyond the model call". |
| F-003 (Minor, no cumulative breaker) | Open | **Resolved** | Sweep-cumulative breaker in the task loop (skeleton L476–483): CUM_WALL always, CUM_COST when reported, caps $60 / 14400 s / HEATWAVE > 3× canary; trip → clean stop, `escape.txt`, NOT-RUN rows. Wired into FR-10, NFR-2, AC-N-03, T10; cost-unreported case falls back to the wall cap (Edge Cases L555). Concrete and present. |
| F-004 (Minor, orphan processes) | Open | **Resolved** | `with_deadline` uses `set -m` so the arm is its own process group; TERM → 10 s grace → KILL on the group (skeleton L408–418); T10 adds a `pgrep -f 'claude -p'` empty-after-arm evidence check; T7 exercises group-kill on a hung dummy. `set -m` portability flagged in Risks with the T7/T10 checks as verification — acceptable. |
| F-005 (Nit, install output discarded) | Open | **Resolved** | Install output → `$SCRATCH/install.log`, copied back with transcripts; failure records `notes=install-failed` and the sweep continues (skeleton L458–461, Error Handling). Also fixes the latent iteration-1 `set -eu` abort on install failure. |
| F-006 (Nit, deadline asymmetry undisclosed) | Open | **Resolved** | FR-9 and T8 now require the METHODOLOGY threats list to name the 900 s/2700 s asymmetry and the graded-as-is timeout policy, including that a timed-out partial solution can register as an escaped defect. |

Late findings: None. Iteration-2 delta reviewed end-to-end for regressions: `.gitignore` correctly drops the now-unneeded `.scratch/` entry and keeps transcripts ignored; AC-F-07 repro command updated consistently; new tools (`mktemp`, `pgrep`) declared in AC-N-01/Dependencies; scope still `benchmark/**` + `.gitignore` only — no protocol shard, no new rules, no PROTOCOL.md regeneration, no F/G/H leakage; every iteration-1 strength (roster, SPEC-traceable oracles, discrimination-before-pilot ordering, corpus freeze, fixture arms, no LLM judge) preserved unchanged. The `set -eu` AND-OR-list patterns in the revised skeleton were desk-checked and are POSIX-safe.

## Verdict (iteration 1 — superseded)

GATE_NOT_MET — REJECTED → PLANNER
Blockers: 0 open | Majors: 1 open | Minor: 3 | Nit: 2

## Scope Evaluated

Plan scope as declared, plus the dispatch-mandated anti-rigging axis: corpus neutrality, arm symmetry, oracle withholding, deterministic grading, discrimination-before-pilot ordering, cost escape, spec-conformance mapping (G1–G5, §9.1–9.7), E isolation, AC quality, task executability. Repo ground-truthing performed with tools (see Verification Log).

## Scope Changes

None.

## Reconciliation

Iteration 1 — no prior reports.

## Findings

### F-001 | MAJOR | verification-integrity — the oracle is NOT strictly withheld: the arm agent can read `oracle/` and `solutions/` through the filesystem

Plan lines 58, 392–399, 548 (Architecture `.scratch/` location; harness skeleton `SCRATCH="$BENCH/.scratch/..."`; AC-F-01).

The plan's withholding is enforced only on the **copy surface** (only `repo/` + `SPEC.md` are copied, asserted at plan L397–399). But the scratch dir lives at `benchmark/.scratch/<arm>/<id>/trial-N` — **inside the heatwave repo, three levels below a sibling of `benchmark/corpus/`** — and both arms run `claude` with `--dangerously-skip-permissions` (plan L64–65, L428), which grants unrestricted Read/Write/Bash on the whole filesystem. The agent's `pwd` (`…/heatwave/benchmark/.scratch/raw/t01-pagination/trial-1`) hands it a discoverable path: `../../../corpus/t01-pagination/oracle/test_oracle.py` and `solutions/good.py` are three `cd ..` away. A conscientious agent exploring its surroundings (or the HEATWAVE loop's reviewer subagent hunting for tests) can find the grading oracle and the reference solution without violating any instruction it was given.

This defeats the spec's core control (§5.1 "the agent never sees this dir", §7-alt-4 "Oracle is strictly withheld until grading") and the plan's own FR-1/AC-F-01, in either direction: leakage could inflate either arm's score, and a skeptical reader who spots the layout can dismiss the entire result. The corpus shasum manifest (L421–422) catches *mutation* but not *reading*, and only after money is spent. Since oracle withholding is the crux of E's credibility, a live leakage path in the planned design is a Major, not a Minor.

Required fix (small): create scratch via `mktemp -d` **outside the repo tree** (e.g. `${TMPDIR:-/tmp}/hw-bench-$RUN_ID/...`), keeping only transcripts/CSV under `benchmark/`; strengthen AC-F-01 with post-run evidence that the agent transcript (`agent.json`) contains no reference to the corpus path (`grep -c 'benchmark/corpus' agent.json` → 0 per row); keep the manifest check as the mutation backstop. State the residual (absolute-path reads are still physically possible under skip-permissions; the corpus path is no longer discoverable from the agent's cwd) in METHODOLOGY threats.

### F-002 | MINOR | data-integrity / determinism — HEATWAVE arm install does a network `git clone` per task, contradicting "no network beyond the model call"

`install.sh` L134–139 (claude adapter): installs the ui-ux-pro-max companion by `git clone --depth 1 https://github.com/nextlevelbuilder/ui-ux-pro-max-skill` when `.claude/skills/ui-ux-pro-max` is absent — which it always is in a fresh scratch. Spec §5.2 says "No network beyond the model call"; the plan (L406) invokes `install.sh` per HEATWAVE (task, trial) without addressing this: 8 clones per sweep, added wall-time charged to the HEATWAVE arm, and a nondeterministic external dependency (upstream repo content can change mid-sweep). Fix is one line: pre-create `$SCRATCH/.claude/skills/ui-ux-pro-max` before calling install.sh (triggers the installer's "already installed" skip path, verified in install.sh L131–133), and note it in METHODOLOGY.

### F-003 | MINOR | cost-bound — no cumulative circuit breaker after the canary

Plan T10 (L538): the canary escape triggers on canary wall > 45 min OR cost > $15 OR non-terminal. A canary at $14.99/44 min authorizes the remaining 7 tasks with no further cost checkpoint — projected ~$105 and ~5–6 h wall, bounded only by per-task deadlines. The escape is concrete and honest as far as it goes (pre-committed lexical subset, NOT RUN rows with completion command — good), but "prevents runaway spend" needs one more rung: add a per-task cumulative checkpoint (e.g. after each HEATWAVE task, if cumulative cost > 3× canary cost or > $60, stop and convert the remainder to `NOT RUN (cost-bounded)`). Cheap to specify; closes the worst-case gap.

### F-004 | MINOR | timeouts — `with_deadline` kills only the direct child PID

Plan L368–376: `kill "$pid"` targets the immediate child; `claude` spawns subprocesses (and the HEATWAVE loop spawns Task subagents). On deadline, children can be orphaned and keep running (and spending) past the recorded wall-time, undermining NFR-2's enforcement claim. Fix: run the arm in its own process group and kill the group (`kill -- -$pid` after starting via `set -m`/`setsid`-equivalent, or document `pkill -P`-style cleanup), or explicitly document the limitation and verify orphan behavior in the T10 canary.

### F-005 | NIT | error-handling — HEATWAVE install output discarded

Plan L406: `sh "$REPO/install.sh" "$SCRATCH" claude >/dev/null 2>&1` — under `set -eu` an install failure aborts the whole sweep with zero diagnostics. Redirect to `$SCRATCH/install.log` instead.

### F-006 | NIT | methodology completeness — deadline asymmetry not listed as a threat

RAW gets 900 s, HEATWAVE 2700 s (L352), and a timed-out arm is graded as-is (L460). Reasonable, but a timed-out partial RAW solution that passes the visible check and fails the oracle counts as an escaped defect — the deadline choice can therefore influence the headline metric. Add the asymmetry + timeout-grading policy to the METHODOLOGY threats-to-validity list (FR-9 currently doesn't name it).

## Acceptance Status

N/A (PLAN_REVIEW — AC table applies at FINAL_REVIEW). AC quality assessed under Verification Log.

## Verification Log

Machine evidence (R-110): plan-stage — repo ground-truthing executed; no build/test rungs applicable to a plan artifact.

| Item | Method | Result | Evidence |
|---|---|---|---|
| Repo state matches plan header | `git log`, `git status`, `sh build-protocol.sh --check` | Confirmed | HEAD `06cd952`; `OK: PROTOCOL.md matches protocol/ shards`; only the two E docs untracked |
| `benchmark/` collision | `ls` repo root; grep protocol/, install.sh, build-protocol.sh for "benchmark" | No collision | no `benchmark/` dir; zero references |
| claude CLI + flags | `claude --version`; `claude --help` grep | Confirmed | 2.1.227; `-p/--print`, `--output-format`, `--setting-sources`, `--dangerously-skip-permissions` all present. Note: help also lists `--allow-dangerously-skip-permissions` ("Enable bypassing") — if headless bypass requires the enable flag, T7/T10 canary will surface it before spend; plan's fallback posture covers it |
| python3 / semgrep / gitleaks / no timeout / no shellcheck | `which`, `--version` | All match plan's Tooling Declaration | python3 3.14.6; `/opt/homebrew/bin/{semgrep,gitleaks}`; timeout/gtimeout/shellcheck absent — `with_deadline` watchdog and `sh -n` fallback are justified |
| install.sh claude-adapter behavior as plan describes | Read `install.sh` L1–140, `adapters/claude-code/{HEATWAVE.md,role-gate.sh,GATE.md}` | Confirmed with one exception | Copies `.heatwave/`, 3 agents, appends CLAUDE.md block, installs 3 hooks; usage `install.sh <target> claude` matches plan. Exception: network `git clone` per install → F-002 |
| RAW arm truly protocol-free | Harness skeleton copy list (repo/ + SPEC.md only) + isolation assert + `--setting-sources project` | Sound at design level, pending T7 | User-level leakage correctly treated as a load-bearing assumption verified BEFORE paid runs, with a fallback ladder — right structure |
| Oracle withholding | Adversarial trace of agent reach under `--dangerously-skip-permissions` from `benchmark/.scratch/` | **FAILED** | F-001 — corpus oracle reachable and discoverable from the agent's cwd |
| Spec G1–G5 → tasks/ACs | Manual mapping | Complete | G1→T2–T6/FR-1–3; G2→T7/FR-4–6; G3→FR-5/T9–T10; G4→T8/FR-9; G5→T9–T11/FR-10 |
| Spec §9.1–9.7 → ACs | Manual mapping | Complete | §9.1→AC-F-01, §9.2→AC-F-04, §9.3→AC-F-02(+03), §9.4→AC-F-05, §9.5→AC-F-06, §9.6→AC-F-07, §9.7→AC-F-09 |
| E isolation | Task table paths T1–T12 | Confirmed | Only `benchmark/**` + `.gitignore`; no protocol/, no PROTOCOL.md regeneration; no F/G/H leakage |
| Ordering: discrimination + harness proof before paid runs | Task table | Confirmed | T2–T6 corpus + check-corpus gate, T7 fixture sweeps + isolation smoke, T9 freeze commit, THEN paid RAW/HEATWAVE — correct |
| Anti-rigging controls A5 | Adversarial read + t01/t03 worked examples | Strong (except F-001) | Fixed 4×2 generic-trap roster pre-committed; every oracle assertion SPEC-cited (t01/t03 examples check out — each assertion traces to a SPEC sentence; no oracle test exceeds the SPEC); bidirectional discrimination + bad-passes-visible gated by check-corpus; corpus freeze commit; pre-committed lexical escape subset; fixed arm order; identical scratch construction; no LLM judge; zero-token fixture arms self-test the pipeline |
| Harness skeleton executability | Desk-check of POSIX sh skeleton under `set -eu` (loop/break AND-OR semantics, `--tasks/--only/--trials` interplay, CSV schema vs summarize) | Sound | No placeholder paths; TASK.yaml sed-parseable schema given; two fully-authored tasks (t01, t03) incl. oracle + good/bad solutions — exceeds the ≥1 requirement |

Not verified:

| Item | Reason | Criteria affected |
|---|---|---|
| Headless `claude -p` actually drives the Heatwave loop to terminal state | Requires a paid run; plan correctly declares it a load-bearing assumption with the T10 canary + feasibility escape, never a fabricated result | AC-F-05 (pilot-time) |
| `--setting-sources project` excludes user-global CLAUDE.md in practice | Behavioral; plan gates it behind T7 smoke test before any paid run, with fallback ladder | AC-F-05 fairness |
| The six unauthored tasks (t02, t04–t08) | Authored at T2–T5; roster + normative pattern fixed in the plan; check-corpus gates all 8 | AC-F-02/03 (build-time) |

## Summary

This is a well-constructed plan whose anti-rigging design is genuinely strong: a pre-committed generic-trap roster, SPEC-traceable oracle assertions, a bidirectional discrimination gate that must pass before any paid run, a corpus-freeze commit, a pre-committed lexical escape subset, fixed arm order, deterministic oracle grading with no LLM judge, and zero-token fixture arms that self-test the whole pipeline. Both arms get identical repo/SPEC/model with process as the only variable, and the two fully-authored example tasks hold up under adversarial reading. Spec coverage (G1–G5, §9.1–9.7) is complete, E is properly isolated, ordering is correct, and every tool claim in the Tooling Declaration reproduced exactly on this machine.

It is rejected for one Major: the oracle is not actually withheld. Scratch dirs nest inside the repo beside `benchmark/corpus/`, and both arms run with `--dangerously-skip-permissions`, so the grading oracle and reference solutions are readable at a discoverable relative path from the agent's own cwd. For an artifact whose entire value is that the agent could not have seen the answer key, a live leakage path is disqualifying regardless of how likely an agent is to wander into it — a skeptical reader only needs the possibility. The fix is small (scratch via `mktemp -d` outside the repo + a transcript-grep evidence rung on AC-F-01) and rides entirely inside existing tasks. Three Minors (per-task network clone in the HEATWAVE install path, no cumulative cost breaker after the canary, process-group kill in the watchdog) and two Nits round it out. One revision cycle should clear the gate.

## Gate

Iteration 1: REJECTED → PLANNER (1 Major open).
**Iteration 2: APPROVED — GATE_MET (0 Blockers, 0 Majors).** All six findings verified resolved (see Reconciliation). The plan proceeds to IMPLEMENTING. FULL_REVIEW must re-verify AC-F-10 with live evidence (scratch-root record + transcript greps) and re-run check-corpus + fixture sweeps independently.
