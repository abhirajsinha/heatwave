# Implementation Package — Adaptive Intake + Slimdown (Heatwave v4, Sub-project A)

task_id: hw-v4-A-intake-slimdown | artifact_type: implementation-package | iteration: 1 | produced_by: IMPLEMENTER (claude-fable-5) | timestamp: 2026-08-10

Plan implemented: `docs/superpowers/plans/2026-08-10-adaptive-intake-slimdown.md` (iteration 2, PLAN_REVIEW-passed). Branch: `heatwave-v4-subproject-a` (13 commits, local only, off `main` at b3044e8).

## Change Summary

PROTOCOL.md v3.1 (974 lines) was extracted verbatim into eight canonical `protocol/` shards (T1, pure move); `build-protocol.sh` now generates PROTOCOL.md with a byte-equality `--check` drift guard (T2). Core gained the EXPRESS tier, R-101–R-104, EXPRESS states/transitions, and §2.5 run-config with reserved `autonomy`/`scope` fields — declared and defaulted, consulted by nothing (T3). The EXPRESS pipeline shipped: change/check templates, `prompts/express-checker.md`, implementer EXPRESS mode, shard §4.8/R-105 (T4). The design-doc gate (T5), findings ledger + R-109 (T6), and run-record/state schema with pre-v4 resume defaults (T7) followed. The orchestrator prompt was rewritten around intake triage, the shard dispatch matrix (R-107/R-108), and the EXPRESS path (T8). install.sh, role-gate.sh, all 11 adapters, 3 agent defs, and 6 role prompts now point at core+shard with EXPRESS carve-outs (T9); docs and the v4 history table landed (T10); the live battery ran against four throwaway targets via `claude` 2.1.226 (T11). Review residuals F-010/F-011/F-012 folded in as directed.

## Files Changed

`git diff --stat b3044e8..HEAD` → 45 files, +1747 −529. By task:

| Path | Change | Task |
|---|---|---|
| `protocol/core.md` | new (extraction + v4 content) | T1, T2, T3 |
| `protocol/planner.md` | new (+ §3.2.3) | T1, T5 |
| `protocol/implementer.md` | new (+ §4.8) | T1, T4 |
| `protocol/reviewer.md` | new (+ §3.4.1, R-29/§3.4 amendments) | T1, T6 |
| `protocol/fixer.md` | new | T1 |
| `protocol/final-reviewer.md` | new | T1 |
| `protocol/orchestrator.md` | new (+ E-pointer, §9.2 resume note, §9.6/§9.7) | T1, T2, T7, T8 |
| `protocol/history.md` | new (+ v4 change table) | T1, T10 |
| `build-protocol.sh` | new, executable | T2 |
| `PROTOCOL.md` | now generated (951 lines; regenerated in every shard-touching commit) | T2–T10 |
| `templates/express-change.md`, `templates/express-check.md` | new | T4 |
| `prompts/express-checker.md` | new | T4 |
| `prompts/implementer.md` | +EXPRESS mode; citation reworded | T4, T9 |
| `heatwave.config.example.yaml` | +express/design_doc blocks | T4, T5 |
| `templates/technical-design.md` | new (7 locked sections) | T5 |
| `prompts/planner.md` | +design-doc-first; citation reworded | T5, T9 |
| `templates/findings-ledger.yaml` | new | T6 |
| `prompts/reviewer.md`, `prompts/final-reviewer.md`, `prompts/fixer.md` | ledger output/input; citations reworded | T6, T9 |
| `templates/review-report.md` | Findings section → ledger summary | T6 |
| `templates/run-record.yaml` | +run_config block, EXPRESS enum, normative header | T7 |
| `prompts/orchestrator.md` | rewritten (intake, matrix, EXPRESS path) + Edge-Case-5 clarification | T8 (+follow-up) |
| `prompts/plan-reviewer.md` | citation reworded | T9 |
| `install.sh` | ships/refreshes `protocol/` | T9 |
| `adapters/claude-code/role-gate.sh` | +EXPRESS_CHECK in NO_EDIT_STATES; +design_doc_path allowance | T9 (+Deviation D-1) |
| `adapters/claude-code/{HEATWAVE.md,GATE.md}` | shard working set, EXPRESS map rows + carve-outs | T9 |
| `adapters/claude-code/.claude/agents/heatwave-{planner,implementer,reviewer}.md` | core+shard citations, EXPRESS rows | T9 |
| `adapters/{generic,codex,gemini,cursor,copilot,windsurf,cline,zed,aider}/…` | working-set line + EXPRESS exception clause (F-012 phrasing) | T9 |
| `adapters/README.md` | lines 3/29/30 updated | T9 |
| `README.md`, `docs/faq.md`, `docs/loop.md` | EXPRESS; F-010 rewording | T10 |
| `docs/getting-started.md` | grep-verified — does not name the tier list; unchanged per T10 | T10 |

## Diff

Branch `heatwave-v4-subproject-a`, commit range `b3044e8..e501c42` (13 commits, one per task plus two labeled follow-ups).

## Deviation Records

**D-1 (role-gate vs R-106 — mechanical conflict fixed).**
- What the plan specified: T9's only role-gate change is `NO_EDIT_STATES` gains `EXPRESS_CHECK`.
- What was built instead: role-gate.sh additionally allows writes under the configured `design_doc_path` (default `docs/design`, read from `heatwave.config.yaml`) during no-edit states.
- Why: discovered live in T11 — the PLANNER must write `docs/design/<task-id>.md` during PLANNING (R-106), but the gate blocked every non-`.heatwave` write in PLANNING. Deterministic proof: piping `{"tool_input":{"file_path":"…/docs/design/x.md"}}` into the pre-fix gate with a PLANNING run present exited 2 with the block message; post-fix it exits 0 while `src/greet.js` still exits 2. Without this, AC-F-04 is unsatisfiable on the claude adapter.
- Affects review scope / acceptance criteria / non-functional targets: enables AC-F-04; adds one reviewed branch to `secure-config` scope (the gate now has a config-driven allowlist entry).
- Affects threat surface: slightly — during PLANNING a role could write under `docs/design/`; the path never contains executable project source and defaults narrow. Judged acceptable; flagged for the REVIEWER.

**D-2 (orchestrator prompt clarification, Edge Case 5).** Plan text said "STANDARD/FULL only"; a live LIGHT run under `design_doc: always` still recorded `design_doc: true` (behavior right — no doc emitted — but the record contradicted core §2.5). Added one sentence to the intake section: EXPRESS/LIGHT record `design_doc: false` even under `always`. Encodes plan Edge Case 5 verbatim; no scope/criteria/threat impact.

**D-3 (placement of R-107/R-108).** The plan's Architecture §D places R-107 (§9.6) and R-108 (§9.7) in the orchestrator shard but no task's file list named that shard edit. Landed them in T8 (the dispatch-matrix task). Conforms to Architecture §D; no impact.

**D-4 (dangling Appendix D/E references).** T2's pointer replacement left two v3.1 references to the removed appendices dangling (core R-15 "See Appendix E", orchestrator run-dir tree comment "per Appendix E"). Both reworded to point at `templates/run-record.yaml`. Same-intent cleanup within T2's mandate; no impact.

## Migration Notes

Forward: `install.sh` refreshes `.heatwave/` with `protocol/` added to the refresh set; user config untouched; pre-v4 run dirs resume via §2.5 defaults (verified live, AC-F-10). Backward: `git revert e501c42..d29161a`-range restores v3.1; orphaned `.heatwave/protocol/` in targets is inert (per plan Rollback Plan).

## Configuration Changes

New optional keys in `heatwave.config.example.yaml` (all commented, all defaulted): `express.enabled`, `express.max_files`, `design_doc`, `design_doc_path`. New optional `run_config` block in run records. No env vars, no secrets.

## Test Additions

No test framework exists (Markdown + POSIX sh repo). Added self-checks: `build-protocol.sh --check` (drift guard, exercised in every task commit) and the plan's grep/comm/uniq structural assertions. T11 fixtures (scope_exceeded, FIXING-with-ledger, pre-v4 record) are reproducible recipes recorded below and in the scratchpad targets.

## Test Results

All commands run this session; outputs verbatim.

**Extraction integrity (T1/AC-N-03)** — loss `comm -23` → empty; duplication `uniq -d` → empty; all-headings uniqueness loop → no `DUP/MISSING` lines. Re-run at HEAD vs pre-T1 (`git show d29161a~1:PROTOCOL.md`): loss check empty; duplication check empty.

**Drift guard (T2/AC-F-07)** — `sh build-protocol.sh --check` → `OK: PROTOCOL.md matches protocol/ shards`, exit 0. After `printf '\n' >> protocol/fixer.md` → `DRIFT: PROTOCOL.md differs from protocol/ shards — run: sh build-protocol.sh`, exit 1; restored, check OK again. `env PATH=/usr/bin:/bin sh build-protocol.sh --check` → OK, exit 0 (AC-N-02 zero-dep).

**POSIX (AC-N-02)** — `sh -n build-protocol.sh install.sh adapters/claude-code/role-gate.sh` → exit 0, no output. `git diff b3044e8..HEAD --stat` adds no package manifests.

**Payload sizes (AC-N-01)** — baseline 974. core+implementer **425** (≤ 450 ✓); core+planner 529; core+reviewer 478; core+fixer 382; core+orchestrator 459; PLAN_REVIEW (core+reviewer+planner) 670; FINAL (core+reviewer+final-reviewer) 512; EXPRESS_CHECK (core) 337. Every matrix row < 974 ✓.

**Repo sweeps (AC-F-12)** — invariant grep over PROTOCOL.md/protocol/adapters/prompts/docs/README: every hit EXPRESS-qualified (14 hits listed in session log; plan/review/spec documents under `docs/superpowers`+`docs/specs` excluded as run artifacts that quote the finding text). Packaging grep `grep -rn "PROTOCOL.md" prompts/ adapters/ | grep -v "full rendered spec" | grep -v "generated"` → empty. F-010 widened patterns (`before any code is written|plan is reviewed before|reviewed before code`) → only docs/faq.md:7, EXPRESS-qualified.

**Install (AC-F-11)** — fresh install: 8 shard files, 4 new templates; second run printed 3 `skipped` lines; `grep -c 'Heatwave protocol (binding)' CLAUDE.md` = 1.

**Live battery (T11, `claude` 2.1.226, four scratch targets):**
- **AC-F-01** (hw-target run `001-button-color-white`): EXPRESS end-to-end headless — artifacts exactly `01-express-change.md` + `02-express-check.md`, no planning/plan-review files, `state: APPROVED`, `tier: EXPRESS`, css changed red→white, check verdict `PASS` with machine gate (`npm test`) output attached.
- **AC-F-02** (run `002-session-timeout-30min`): auth task → `tier: STANDARD`, justification cites R-102/sensitive path; first artifact `01-planning-document.md`. (Bounded by `--max-turns`; left resumable in PLAN_REVIEW — by design.)
- **AC-F-03** (fixture run `003-rename-button-class`): resumed EXPRESS_IMPLEMENTING fixture for a 4-file rename → `Result: scope_exceeded — R-103 "estimated ≤ 2 files" condition broke…(R-105)`, zero source edits (`git status` clean), then recorded transition `EXPRESS_IMPLEMENTING → PLANNING` with note "tier promoted EXPRESS→LIGHT, counters reset to 0" and ran the promoted LIGHT loop (combined FULL_FINAL_REVIEW) to APPROVED — first attempt.
- **AC-F-04** (hw-target3 run `add-stats-subsystem`, `design_doc: always`): `docs/design/add-stats-subsystem.md` exists with exactly 7 `## ` sections; planning doc references it twice; `tier: STANDARD`, `design_doc: true`; APPROVED.
- **AC-F-05** (hw-target4 run `stats-subsystem`, `design_doc: never`): `ls docs/design/` → absent (exit 1); `design_doc: false`; loop proceeded normally.
- **AC-F-06** — static: `grep -rn 'PROTOCOL.md' prompts/` → 0 hits. Live: both AC-F-01 dispatch payloads (stream-json `Agent` tool_use inputs) reference `.heatwave/protocol/core.md` + the matrix shard (`protocol/implementer.md` / `express-checker.md`) and contain **0** occurrences of the full-doc string.
- **AC-F-08** (run `004-health-note-subsystem`): full STANDARD loop PLANNING → PLAN_REVIEW → IMPLEMENTING → FULL_REVIEW → FINAL_REVIEW → APPROVED, complete transition log; delivered code works (`npm run health` writes health.txt; `node --test` 6/6 pass).
- **AC-F-09** — pairing/schema live in run 004 (`04-findings-1.yaml` + `04-full-review-1.md`, `05-…` pair; keys `id/severity/status/verification` conform; one real Minor tracked with stable id across rounds). Fixer-by-id + ledger-driven TARGETED_REVIEW via deterministic FIXING fixture (run `005-version-constant`): `05-fix-report-1.md` responds to `F-005-version-constant-001` with `Response: Fixed`; root-cause fix (`require("../package.json").version`); finding's verification method passes; `06-findings-2.yaml` reconciles the id to `Fixed`; run → APPROVED. *(Method deviation from AC wording: the gating finding came from a fixture, not a flaw seeded into the AC-F-08 run — the 08 run gated MET at iteration 1.)*
- **AC-F-10** (fixture run `006-greeting-fix`, v3.1-format record, state FIXING, no run_config): resumed directly in FIXING (`05-fix-report-1.md` first new artifact), never re-entered intake/PLANNING (`grep -c 'to: PLANNING'` on new transitions → 0), record not rewritten (`grep -c run_config run-record.yaml` → 0), fix landed, APPROVED.

## Blast Radius Declaration

Components touched: the protocol document set (now `protocol/` + generated PROTOCOL.md), all role prompts, all adapters, install.sh, role-gate.sh, templates, top-level docs. Consumers: every Heatwave-installed project on its next `install.sh` run; the claude-code hook path (role-gate). Shared state/schema: `state.yaml` (+2 enum values), `run-record.yaml` (+optional block) — both backward-compatible, proven by AC-F-10. Contracts: role dispatch contract changed from full-doc to core+shard (R-107); artifact set gains EXPRESS notes and findings ledgers. Boundary reasoning: nothing outside this repo and `.heatwave/` install targets is written; no runtime service exists; the only executable surfaces changed are the three POSIX scripts, each `sh -n`-checked and behavior-tested. Unchanged: keep-awake.sh, companions, plugins/ponytail, budgets/counters semantics, R-88 resume rule.

## Known Limitations

- Ledger filename adherence is model-mediated: one live run (hw-target4) named ledgers `NN-<type>-K-ledger.yaml` instead of `NN-findings-K.yaml`; the canonical runs (004, 005) conform. Prompt text already states the canonical name; not worth hard enforcement in this change.
- The AC-F-02/AC-F-05 evidence runs were deliberately bounded with `--max-turns`/timeout and left mid-loop (resumable per R-88); their criteria don't require terminal state.
- `role-gate.sh` design-doc allowance matches any path containing `/<design_doc_path>/` anywhere in the absolute path — a same-named directory elsewhere would also be writable during no-edit states. ponytail: substring match; tighten to project-root-relative resolution if it ever matters.
- The generated PROTOCOL.md reads core-then-roles, not numerically — accepted, documented in the shard map (plan: "Certain, accepted").

## Tooling Status

- shellcheck: NOT AVAILABLE (not installed). Would have linted the three shell scripts beyond syntax. Mitigation per plan: `sh -n` + restricted-PATH execution. No AC depends on it.
- yamllint / PyYAML validation: NOT AVAILABLE. Ledger/run-record checks are grep-structural (as the plan's AC-F-09/AC-F-10 methods specify), not parsed validation.
- Non-Claude adapter CLIs (codex, gemini, cursor, copilot, windsurf, cline, zed, aider): NOT AVAILABLE on this machine. Their adapter-file edits are verified by inspection + install/sweep assertions (AC-F-11/AC-F-12) only, not live runs — stated per R-64.
- Claude Code CLI 2.1.226: confirmed and used for all live scenarios; four throwaway targets under the session scratchpad (`hw-target`…`hw-target4`) hold the run-dir evidence; transcripts in `ac-f-*.txt`/`ac-f-01-stream.json` alongside them.
