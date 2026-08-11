# Implementation Package

task_id: hw-v4-C-speed-token | artifact_type: implementation-package | iteration: 1 | produced_by: IMPLEMENTER (claude-fable-5) | timestamp: 2026-08-11

Branch: `heatwave-v4-subproject-c` (local only, off `main` @ 2492d55). Plan: `docs/superpowers/plans/2026-08-11-speed-token-engine.md` (iteration 2, PLAN_REVIEW passed).

## Change Summary

Sub-project C adds the speed / token engine as three core rules plus operational text, config keys, and run-record measurement fields — changing how cheaply the same gates run, never the gates. R-116 (stage model-tiering, cheap-eligible vs frontier-required sets, mechanical rejection of downgrades), R-117 (persistent reviewer session FULL→TARGETED→FINAL with explicit degrade and the FINAL safety clause), R-118 (delta-only FINAL_REVIEW: ledger closure + full machine-gate re-run + delta-scoped LLM reading with the R-8/R-54 reconciliation via recorded R-49 expansion + per-AC re-confirmation). R-110's FINAL carry-forward sentence is superseded (the run's only B-rule text change, mandated by the LOCKED safety clause). R-44 is rewritten to the R-118 scope. Driver duties (model selection, session management, `head_sha`/delta computation with the clean-tree precondition) ride §9.1. Config gains four commented-out optional keys; the run record gains `review_session`, `final_delta_range`, and per-transition `stage_model`/`head_sha` — all optional, pre-C records read with defaults. Zero-config behavior is byte-identical: no speed keys → session model everywhere, fresh contexts, full-scope FINAL.

## Files Changed

| Path | Change type | Line delta (main..HEAD) |
|---|---|---|
| protocol/core.md | modified (T1: R-116/R-117/R-118, §1.4 config note, R-110 amendment) | +38/−2 |
| protocol/final-reviewer.md | modified (T2: R-44 + post-R-45 paragraph) | +5/−1 |
| protocol/reviewer.md | modified (T3: §4.6 persistence note) | +2/−0 |
| protocol/orchestrator.md | modified (T4: §9.1 three speed duties) | +2/−0 |
| protocol/history.md | modified (T9: F.1 row) | +1/−0 |
| PROTOCOL.md | regenerated every shard-touching commit (T1–T4, T9) | generated |
| templates/run-record.yaml | modified (T5: 2 fields + transitions comment) | +3/−1 |
| heatwave.config.example.yaml | modified (T6: speed keys block) | +18/−0 |
| prompts/orchestrator.md | modified (T7.1) | +1/−1 |
| prompts/reviewer.md | modified (T7.2: one bullet) | +1/−0 |
| prompts/final-reviewer.md | modified (T7.3: item 1 → R-118 scope) | +1/−1 |
| adapters/claude-code/HEATWAVE.md | modified (T8.1) | +2/−0 |
| adapters/generic/HEATWAVE-AGENT.md | modified (T8.2) | +1/−1 |
| docs/faq.md | modified (T8.3) | +1/−1 |
| docs/specs/…C-design.md, docs/superpowers/plans/…, reviews/… | added (trail) | new |
| docs/superpowers/impl/2026-08-11-subproject-C-implementation.md | added (this artifact) | new |

Commits (one per task): 678217a trail, dc566f9 T1, d5f819c T2, 5b60551 T3, 35fb9cf T4, 9c969e1 T5, 42f2c33 T6, b3eedb0 T7, 38dd77e T8, f4e7258 T9.

## Diff

`git diff main..heatwave-v4-subproject-c` in /Users/abhirajsinha/Projects/heatwave (local branch; not pushed).

## Deviation Records

Declared for REVIEWER ruling — none self-approved:

1. **L3 host run.** What the plan specified: L3 (downgrade rejection) on "the same target" as L2 with config gaining `stage_models: {FULL_REVIEW: <cheap-id>}`. What was done instead: the downgrade config was placed on the L4 target (t3-delta) and the rejection exercised at that STANDARD run's FULL_REVIEW dispatch. Why: L2's target runs LIGHT, whose only review is the combined FULL_FINAL pass — it never dispatches a plain FULL_REVIEW, so the check as specified had no stage to reject; the L4 STANDARD run has one. Every L3 check is satisfied verbatim (warning in driver transcript, warning recorded in run record, `stage_model` = session model on the FULL_REVIEW transition). Affects review scope/ACs: AC-F-02 evidence comes from t3-delta, not t2-light. Threat impact: none.
2. **L5b degrade justification.** What the plan specified: claude-code records `fresh-degraded` because Task subagents are one-shot. What was found instead: this harness CAN resume a subagent (SendMessage continuation — which is how the L5a persistent path was verified live in-harness rather than via a generic-adapter simulation). The L1/L3-L4 runs still used one-shot fresh dispatches with the degrade recorded explicitly, but under R-117's SHOULD, a driver in this harness electing fresh contexts is a recorded SHOULD-deviation rather than a hard incapacity. Affects: AC-F-04b evidence reads "explicit recorded degrade on the one-shot dispatch path", not "tool cannot persist". Threat impact: none (degrade is the safe direction).
3. **L6 FINAL dispatch not re-run.** The pre-C-record resume (L6) was verified at driver/record level (resume proceeds, explicit full-scope degrade appended, record diff = appends only); a fresh LLM FINAL dispatch was not repeated for the copy. Why: AC-N-03's metric is record-level, and full-scope FINAL behavior is separately evidenced live (t2 combined pass; L5c cold FINAL). Affects: none of AC-N-03's stated metrics left unverified.

## Migration Notes

None. All new fields optional; absent = pre-C defaults (session model, no session tracking, full-scope FINAL). `state.yaml` schema untouched. Rollback per plan: revert 678217a..f4e7258, rebuild, drift-check.

## Configuration Changes

`heatwave.config.example.yaml` (commented-out, opt-in): `cheap_model`, `small_diff_threshold` (default 150 when cheap_model set), `stage_models` (narrow-only), `fresh_final_reviewer`. No env vars, no secrets.

## Test Additions

No runtime code — the "tests" are the deterministic greps per task (all rerun on the final tree, below) and the T10 live battery under `/private/tmp/hw-c-verify/` (4 targets, 6 runs + 3 re-drives; artifacts retained on disk).

## Test Results

### Drift check (G-5, final tree)

```
$ sh build-protocol.sh --check
OK: PROTOCOL.md matches protocol/ shards
exit:0
```
(Also run + green after every one of T1, T2, T3, T4, T5, T8, T9 — see the per-task command outputs in the run transcript; every protocol-editing commit contains its regenerated PROTOCOL.md.)

### AC-F-09 — rules present, spec regenerated

```
R-116: total refs 1, definitions 1
R-117: total refs 1, definitions 1
R-118: total refs 2, definitions 1          # 1 definition + 1 cross-ref (R-110)
"carried forward" in core.md: 0
"no prior verdict survives by reference": 1
head -1 PROTOCOL.md → <!-- GENERATED FILE — do not edit. Canonical source: protocol/*.md. … -->
```

### AC-F-08 — adapter consistency

```
$ grep -c "equivalent to FULL_REVIEW" prompts/final-reviewer.md protocol/final-reviewer.md
0
0
$ grep -rniE "fresh context per review|re-reviews everything|equivalent to FULL_REVIEW|carried forward" \
    adapters/ prompts/ protocol/ README.md COMPANIONS.md docs/faq.md docs/loop.md docs/getting-started.md install.sh
(no output) — exit 1, zero hits
```
T9 rule uniqueness: R-110/111/112/114/115/116/117/118 each defined exactly once in protocol/ (`grep -rc "^\*\*R-<n>\.\*\*"` summed = 1 each); R-113 exactly three named halves (planner/implementer/reviewer, 1 hit each).

### AC-F-10 — R-8/R-54 vs R-118 reconciled

(a) Greps:
```
protocol/core.md:248        — "scope expansion (R-49)" inside R-118 (1 hit)
protocol/final-reviewer.md:13 — "R-49 scope expansion" (1 hit)
prompts/final-reviewer.md:7   — "R-49 scope expansion" (1 hit)
```
(b) T8.5 semantic-check notes (each rule read in the final tree against final R-118, verbatim):

- **R-8** ("REVIEWER MAY expand review scope; MUST NOT narrow"): compatible — R-118(c) names the surviving channel itself: at FINAL the MAY resolves through a *recorded* R-49 expansion; the delta is the required floor, not a narrowing of reviewer authority, and no unqualified MAY/MUST-NOT pair remains.
- **R-43** ("MUST NOT re-litigate areas passed earlier unless blast radius reaches them or reconciliation justifies"): points the same direction as the delta floor; R-118(c)'s grounded-suspicion escape is R-43's blast-radius exception restated at FINAL. No conflict.
- **R-53** (implementer declares blast radius): untouched — the FINAL delta is driver-computed from git, independent of the declaration; the declaration's audit path (R-54 finding) survives at FULL/TARGETED unchanged.
- **R-54** ("blast radius is a claim; REVIEWER MAY review outside it"): compatible — R-118's text qualifies R-54 by name for FINAL only: outside-radius reading at FINAL = recorded R-49 expansion substantiating a suspected delta-caused regression; blanket re-reading forbidden; earlier passes unaffected.
- **R-55** (stable finding IDs): orthogonal to reading scope; the persistent session (R-117) strengthens ID stability in practice (t4 ledger carried F-t4-div-001 across three passes). No conflict.

Verdict: no unqualified MAY/MUST-NOT pair survives between R-8/R-43/R-53–R-55 and R-118.

### AC-N-01 — zero new runtime deps

`git diff --name-only main..HEAD` = exactly the 14 existing `.md`/`.yaml` files + the 4 new docs under `docs/` (list in Files Changed). `git diff --quiet main..HEAD -- build-protocol.sh install.sh` → exit 0 (byte-untouched). `git diff main..HEAD --summary` shows no `create mode 100755`, no mode changes. `sh -n build-protocol.sh install.sh adapters/claude-code/role-gate.sh` → exit 0.

### AC-N-02 — EXPRESS + B artifacts untouched

```
$ git diff --quiet main..HEAD -- prompts/express-checker.md templates/express-change.md \
    templates/express-check.md templates/findings-ledger.yaml
exit 0 (all four byte-identical)
```
Only R-110–R-115 text change in the whole diff: the single mandated R-110 final-sentence amendment (verified by grepping the protocol diff for `R-11[0-5]\.` hunks). Prompts planner/implementer/fixer/plan-reviewer/express-checker: `git diff --quiet` → exit 0.

### A regression — payload sizes + EXPRESS

Baseline 974 (v3.1). Final tree: core 372; core+planner 570; core+implementer 464; core+reviewer 528; core+fixer 417; core+final-reviewer 408; core+orchestrator 498; PLAN_REVIEW row 726; FINAL row 564. Every matrix row < 974. EXPRESS live: see L1 below (two artifacts, APPROVED, no plan).

### T10 live battery (scratch root /private/tmp/hw-c-verify/, retained)

Cheap-model probe: haiku subagent dispatch → replied `PROBE-OK / claude-haiku-4-5-20251001`. Assumption confirmed; cheap-id = claude-haiku-4-5-20251001; session model = claude-fable-5.

**L1 / AC-F-03, AC-F-07 — zero-config (t1-zeroconfig).** STANDARD run t1-mult: PLANNING → PLAN_REVIEW → IMPLEMENTING → FULL_REVIEW (GATE_MET) → FINAL_REVIEW → APPROVED, all six transitions `stage_model: claude-fable-5` (run-record.yaml). FULL ledger `machine_evidence`: tests pass + sast stub pass (B rungs). FINAL was the empty-delta edge (gate met at FULL): range `a3df736..a3df736` recorded; reviewer report states scope = empty delta, machine gates re-run fresh, AC re-confirmed. EXPRESS sibling t1-typo: run dir = exactly `01-express-change.md` + `02-express-check.md` (+ state/record), checker PASS → APPROVED.

**L2 / AC-F-01 — cheap routing (t2-light, `cheap_model: claude-haiku`).** LIGHT run t2-failmsg record excerpt:
```
PLANNING→PLAN_REVIEW   stage_model: claude-haiku-4-5-20251001   # cheap-eligible (LIGHT plan review)
IMPLEMENTING→FULL_REVIEW stage_model: claude-fable-5            # LIGHT combined pass: frontier-required
```
The PLAN_REVIEW artifact was genuinely produced by the haiku dispatch (produced_by: REVIEWER (claude-haiku-4-5-20251001)). Also in t3: TARGETED_REVIEW (1-line fix ≤ threshold 150) ran on haiku — second cheap-eligible routing evidenced.

**L3 / AC-F-02 — downgrade rejection (t3-delta, `stage_models: {FULL_REVIEW: claude-haiku}`).** Driver transcript: `DRIVER R-116 WARNING: … stage_models.FULL_REVIEW=claude-haiku routes a frontier-required stage to the configured cheap model — REJECTED; FULL_REVIEW dispatched on the session model (claude-fable-5).` Run record transition carries the same one-line warning; `stage_model: claude-fable-5` ≠ cheap-id.

**L4 / AC-F-06 — delta FINAL (t3-delta).** Seeded reversed-operand `sub` → FULL_REVIEW raised machine finding F-t3-sub-001 (Blocker, failing declared test, survived refute-or-promote with baseline attribution) → FIXING (one-line fix, commit 3a8fcb0) → TARGETED (GATE_MET, cheap model) → FINAL. Record: `head_sha: 719085a…` on the FULL transition; `final_delta_range: "719085a…..3a8fcb0…"`; `git diff --name-only <range>` = `calc.sh` only; FINAL report re-ran tests + sast from scratch, per-AC table complete, reading scope stated as delta-only, GATE_MET → APPROVED. **Dirty-tree branch:** re-drive on snapshot copy `t3-sub-dirtyredrive` with uncommitted ` M calc.sh` → porcelain non-empty → transition appended: `# R-118 DEGRADE: tree dirty at dispatch … FULL SCOPE, no delta range`; `final_delta_range` left blank. Never an empty-range delta review.

**L5 / AC-F-04, AC-F-05 — session modes (t4-persist).**
(a) *persistent:* one reviewer context performed FULL_REVIEW, was resumed (SendMessage) for TARGETED_REVIEW, resumed again for FINAL_REVIEW; it authored nothing. Record: `review_session: persistent`. TARGETED report: "Written from this persistent session's retained ledger (R-117, R-58)"; ledger header: "carried forward from 04-findings-1.yaml (R-109, R-117)"; F-t4-div-001 referenced by ID without re-derivation. FINAL report shows both machine rungs executed fresh in-pass (`PASS: all tests` exit 0; sast-stub exit 0) + full per-AC table — context reused, no verdict carried. Tool-use log of the FINAL segment (harness transcript, 23 events): file Reads = only the two dispatch shards (`prompts/final-reviewer.md`, `protocol/final-reviewer.md`); zero source-file Reads; Bash = git/gates/targeted `grep -n 'div 6 3' test.sh` (disclosed in-report as R-118(d) AC evidence, not file re-review).
(b) *degraded:* t1/t3 runs record `review_session: fresh-degraded` with the reason comment on the one-shot dispatch path (see Deviation 2 for the honest qualifier).
(c) *forced fresh:* `fresh_final_reviewer: true` appended to t4 config; FINAL re-driven on copy `t4-div-freshfinal` as a cold context; record: `review_session: fresh-configured`; the cold reviewer reconciled from artifacts only, re-ran both gates fresh, GATE_MET. It independently flagged that the driver's own config toggle had dirtied the tree after the porcelain check and answered by evaluating at full scope explicitly — a real R-118 catch, recorded here as driver-side evidence footnote.

**L6 / AC-N-03 — resume compatibility.** Copy `t3-sub-prec-resume` stripped of every v4-C field (grep count for review_session/final_delta_range/stage_model/head_sha = 0) at the TARGETED-gate-met point. Resume: driver proceeded with §2.5-style defaults, appended the FINAL transition with the explicit full-scope degrade (`no recorded last-FULL head_sha`), never rewrote the record: `diff before after` = exactly one appended line (`25a26`), pre-C fields left absent.

## Blast Radius Declaration

Components touched: `protocol/` shards (core, reviewer, final-reviewer, orchestrator, history) + generated PROTOCOL.md; three role prompts; two adapters + FAQ; run-record template; config example. Consumers: every Heatwave-installed repo on next `install.sh` (zero-config → no behavior change until opt-in); the driver path in every adapter (new SHOULD-duties, no new states/gates). Shared schema: run-record.yaml gains optional fields (backward-readable, AC-N-03 proven); `state.yaml`, counters, §2.1/§2.2 states untouched. Contracts: FINAL_REVIEW scope contract changed by design (R-44→R-118) — that IS the feature, gated by AC-F-05/06. Boundary reasoning: no executable changed (`build-protocol.sh`/`install.sh` byte-identical), no runtime service exists; everything outside protocol text, prompts, adapters, templates, config example, and docs/ is untouched (AC-N-01 name-audit).

## Known Limitations

- `stage_models` narrowing/widening enforcement is string-mechanical (per plan §Architecture): equality against the configured `cheap_model` string; no model-ranking oracle exists in a Markdown protocol. Not a `ponytail:` code comment (no code), recorded here.
- "Artifact summarization" is driver-side conduct with no state; its cheap-eligibility is exercised only when a driver actually summarizes — not separately drivable headless (no summarization occurred in the battery runs; declared, see Tooling Status).
- No `ponytail:` ceiling comments exist in the diff (docs/YAML only).

## Tooling Status

Per R-64 — unavailable/not-exercised, what it would have verified, affected ACs:

- **Cross-tool session persistence** (aider/cursor/codex etc. resuming a reviewer context): NOT AVAILABLE headless — only the claude-code harness (persistent via SendMessage + one-shot Task path) and the generic single-context semantics (which L5a's one-session-across-three-passes flow instantiates) were exercised. Would have verified: R-117 degrade behavior per non-Claude tool. Affected ACs: none beyond what AC-F-04 requires (persistent + degraded both evidenced live); per-tool adapter conduct remains review-time reading, not machine evidence.
- **Real SAST/mutation tools**: NOT AVAILABLE, as in B — declared stub (`sh sast-stub.sh`) exercised the rung *contract* (recorded before LLM findings; re-run from scratch at FINAL), which is what C verifies. Mutation: no FULL-tier scratch run; rung remains contract-verified by rule text only. Affected ACs: none (AC-F-05/06 verify re-execution + recording, demonstrated with tests+sast).
- **Driver-side artifact summarization**: no battery run summarized artifacts, so cheap routing of that (stateless) activity has no run-record evidence. Affected ACs: AC-F-01's table row for summarization rests on rule text + the probe's demonstrated cheap-dispatch capability; the two recorded cheap routings (LIGHT PLAN_REVIEW, small-delta TARGETED) carry the AC.
- **This repo's own sast/mutation ladder entries** (plan Tooling Declaration): NOT AVAILABLE — no scannable runtime language in the diff; affects no AC (all ACs text/behavioral).
- YAML parse check: python3 yaml module absent; ruby fallback used — `YAML.load_file('templates/run-record.yaml')` → `YAML-OK-ruby`.

### AC → evidence map (summary)

| AC | Status | Evidence |
|---|---|---|
| AC-F-01 | machine-verified live | L2 record excerpt (haiku on LIGHT PLAN_REVIEW, session on combined pass) + t3 TARGETED on haiku + probe output |
| AC-F-02 | machine-verified live | L3 driver warning (transcript + record comment) + `stage_model: claude-fable-5` on FULL_REVIEW |
| AC-F-03 | machine-verified live | L1 record: 6/6 transitions session model; APPROVED via full state machine; config file has no speed keys |
| AC-F-04 | machine-verified live | (a) t4 `review_session: persistent` + TARGETED citing F-t4-div-001 from retained ledger; (b) t1/t3 `fresh-degraded` (see Deviation 2) |
| AC-F-05 | machine-verified live | (a) t4 FINAL report: both rungs fresh in-pass + per-AC table; (b) L5c `fresh-configured` cold context |
| AC-F-06 | machine-verified live | t3 `head_sha`, `final_delta_range`, `git diff --name-only` = calc.sh, FINAL fresh gates + per-AC + stated delta scope; read-scope tool-log check done on t4's FINAL (t3's sync dispatch has no retained transcript — its scope claim rests on the report's own scope statement + delta range, stated per plan L4's fallback); dirty-tree branch = explicit degrade, blank range |
| AC-F-07 | machine-verified live | L1 EXPRESS two-artifact APPROVED; L1 STANDARD APPROVED with B rungs; drift exit 0 final tree; t3 Blocker survived refute-or-promote and round-tripped FIXING |
| AC-F-08 | machine-verified | grep `0 0`; re-sweep zero hits; rule uniqueness pass |
| AC-F-09 | machine-verified | greps above; generated header intact |
| AC-F-10 | machine-verified | 3-home greps + T8.5 notes (attached above) |
| AC-N-01 | machine-verified | diff name-audit; scripts byte-identical; no mode changes; sh -n exit 0 |
| AC-N-02 | machine-verified | 4-file `git diff --quiet` exit 0; L1 EXPRESS run-dir listing |
| AC-N-03 | machine-verified live | L6 appends-only diff (`25a26`) + explicit degrade + zero v4-C fields added |

Items for live-adapter verification at review (REVIEWER spot re-run per plan Tooling Declaration): the battery artifacts under `/private/tmp/hw-c-verify/` are retained verbatim for inspection and re-driving.
