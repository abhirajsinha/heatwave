# Review Report

task_id: hw-v4-C-speed-token | artifact_type: review-report | iteration: 1 | review_type: FULL_REVIEW | produced_by: REVIEWER (claude-fable-5) | timestamp: 2026-08-11

## Verdict

GATE_MET
Blockers: 0 open | Majors: 0 open | Minor: 1 | Nit: 1

## Scope Evaluated

Plan scope (plan-conformance, verification-integrity, data-integrity) over the full `main...heatwave-v4-subproject-c` diff (18 files, +1067/−9): all 8 shipped protocol/prompt/adapter/template/config files read in the diff and in the final tree; every deterministic check re-run by this reviewer; live battery artifacts under `/private/tmp/hw-c-verify/` independently inspected (records, reports, ledgers, git ranges re-executed).

## Scope Changes

None (no R-49 expansion needed — the plan's three categories covered everything the diff touches).

## Reconciliation

First post-implementation review — no prior code-review findings. PLAN_REVIEW trail (iteration 1: 0B/3M/1m/1n) confirmed answered in plan iteration 2; all three Major fixes (F-hwC-001/002/003) verified landed in the shipped text by the greps below (AC-F-08/09/10 all satisfiable and satisfied).

Late findings: None.

## Acceptance Status

| AC ID | Status | Evidence |
|---|---|---|
| AC-F-01 | Satisfied | t2-failmsg record: `stage_model: claude-haiku-4-5-20251001` on LIGHT PLAN_REVIEW with the artifact's `produced_by: REVIEWER (claude-haiku-4-5-20251001)`; combined FULL_FINAL pass on `claude-fable-5`; t3 TARGETED (1-line ≤150) on haiku. Re-read from disk this review. |
| AC-F-02 | Satisfied | t3-sub config `stage_models: {FULL_REVIEW: claude-haiku}`; record FULL_REVIEW transition comment carries the R-116 rejection warning and `stage_model: claude-fable-5` ≠ cheap-id. Re-read from disk. |
| AC-F-03 | Satisfied | t1-zeroconfig: no speed keys in config (grep 0); 6/6 transitions `stage_model: claude-fable-5`; terminal_state APPROVED via full state machine. Re-verified. |
| AC-F-04 | Satisfied | (a) t4-div `review_session: persistent`; TARGETED report written "from this persistent session's retained ledger (R-117, R-58)", ledger header "carried forward from 04-findings-1.yaml (R-109, R-117)", F-t4-div-001 cited by ID. (b) t1/t3 `fresh-degraded`, explicit with reason comment. Deviation 2's honest reframing accepted (see below). |
| AC-F-05 | Satisfied | (a) t4 FINAL report: both rungs executed fresh in-pass (`PASS: all tests` exit 0; sast-stub exit 0) + complete per-AC table — context reused, no verdict carried. (b) t4-div-freshfinal: `review_session: fresh-configured`, cold context reconciling from artifacts only (R-4/5.6), gates re-run. |
| AC-F-06 | Satisfied | t3-sub: `head_sha: 719085a…` on FULL transition; `final_delta_range: 719085a…..3a8fcb0…`; I re-ran `git diff --name-only <range>` in the scratch repo → `calc.sh` only. Dirty re-drive: `# R-118 DEGRADE: tree dirty at dispatch … FULL SCOPE, no delta range`, `final_delta_range` blank — never an empty-range delta review. Read-scope tool-log check done on t4 per the plan's own R-64 fallback for t3 (declared, not silent). |
| AC-F-07 | Satisfied | t1-typo EXPRESS: exactly 01+02 artifacts, checker PASS, APPROVED. t1-mult ledger: tests+sast rungs recorded, GATE_MET. t3 F-t3-sub-001: machine-origin Blocker with a real R-112 refutation attempt (baseline attribution via HEAD~1) that round-tripped FIXING. Drift check exit 0 on the final tree (run by me, below). |
| AC-F-08 | Satisfied | Re-run: `grep -c "equivalent to FULL_REVIEW" protocol/final-reviewer.md prompts/final-reviewer.md` → `0` / `0`; full re-sweep (adapters/ prompts/ protocol/ README COMPANIONS docs/faq,loop,getting-started install.sh) → zero hits, exit 1. |
| AC-F-09 | Satisfied | Re-run: R-116/117/118 defined exactly once each in PROTOCOL.md (refs 1/1/2 — R-118's second ref is R-110's cross-ref); `grep -c "carried forward" protocol/core.md` → 0; "no prior verdict survives by reference" → 1; generated header line intact. |
| AC-F-10 | Satisfied | Re-run: "scope expansion (R-49)" at protocol/core.md:248 inside R-118; "R-49 scope expansion" at protocol/final-reviewer.md:13 and prompts/final-reviewer.md:7. Semantic check independently repeated by this reviewer against the live texts of R-8 (core:128), R-43 (reviewer:61), R-53/R-54 (core:292/294), R-55 (reviewer:86): no unqualified MAY/MUST-NOT pair survives; R-49 is in FINAL context (dispatch matrix loads reviewer.md at FINAL_REVIEW). |
| AC-N-01 | Satisfied | Name audit re-run: 14 existing .md/.yaml + 4 new docs/ files only; `git diff --quiet main..HEAD -- build-protocol.sh install.sh` exit 0; `--summary` shows only `create mode 100644` for the 4 docs — no executables, no mode changes. |
| AC-N-02 | Satisfied | `git diff --quiet main..HEAD` exit 0 on all four EXPRESS/B artifacts AND on the five untouched prompts AND on templates/state.yaml + findings-ledger.yaml. Sole R-110–R-115 text change is the mandated R-110 final-sentence amendment. |
| AC-N-03 | Satisfied | t3-sub-prec-resume: v4-C field count 0 in the pre-C body; single appended FINAL transition with the explicit no-head_sha full-scope degrade comment; pre-C fields left absent, record not rewritten. `ruby -ryaml` parse of templates/run-record.yaml → YAML-OK. |

## Findings

Canonical detail below; no findings ledger file for this docs-repo review round beyond this report (consistent with prior A/B review trail practice in docs/superpowers/reviews/).

**F-hwC-101 | Minor | verification-integrity | protocol/orchestrator.md:66**
The clean-tree precondition is stated two ways that disagree: the shard's prose says "verify the working tree is clean **for tracked source**" while its own parenthetical (and prompts/orchestrator.md:30, and R-118 itself) demand the strict, unqualified `git status --porcelain` empty. `--porcelain` also lists untracked files, so the strict reading over-degrades in any repo with untracked scratch files, which invites drivers to improvise a "tracked source" subset — and the implementer's own battery demonstrated the failure: the t4-freshfinal driver, reading "tracked source" as task source, signaled *clean* and computed a delta range while a tracked file (`heatwave.config.yaml`) sat uncommitted; the cold FINAL reviewer caught it via its own porcelain check and self-degraded to full scope (recorded in 07-review-report.md). Concrete failure scenario: a driver following the loose prose signals clean while an uncommitted tracked edit exists → that edit is invisible to the range diff at FINAL and only reviewer vigilance or the machine gates catch it. Fix is one line: make the three texts agree — e.g. `git status --porcelain --untracked-files=no` empty (tracked-only, matching the prose) in all three homes, or drop "for tracked source". Not a Major: two of the three shipped texts (including the normative R-118) already carry the strict reading, the degrade direction is fail-safe, and the shipped reviewer duties demonstrably caught the live instance.
Refutation attempt (R-112): is the ambiguity real in the shipped text rather than only in the scratch driver's conduct? Re-read all three homes — orchestrator.md:66 alone carries the "for tracked source" qualifier against its own strict parenthetical; the divergence is in the diff, not just the rig. Not refuted — but severity capped Minor by the fail-safe direction and the in-battery catch.

**F-hwC-102 | Nit | plan-conformance | adapters/claude-code/HEATWAVE.md:9**
The section still opens "you dispatch each role as a **subagent** with a fresh context:" and the R-117 exception arrives only at line 17. Internally consistent once read in full (and the sweep pattern rightly doesn't flag it), but a skimming driver stops at the headline. Suggest appending "(review stages: see R-117 note below)" to line 9.

## Verification Log

Machine evidence (R-110): drift rung run by this reviewer, both directions.

| Item | Method | Result | Evidence |
|---|---|---|---|
| Drift check (positive) | `sh build-protocol.sh --check` on the branch tree | pass, exit 0 | `OK: PROTOCOL.md matches protocol/ shards` |
| Drift check (negative) | append junk line to protocol/core.md, re-check, restore, re-check | fail-as-expected exit 1, then restored exit 0, tree clean after | `DRIFT: PROTOCOL.md differs from protocol/ shards — run: sh build-protocol.sh` / injected-exit:1 / restored-exit:0 |
| A: EXPRESS surface + untouched prompts | `git diff --quiet main..HEAD` per file set | exit 0 both sets | this session |
| A: payload matrix | `wc -l` core + each shard | core 372; all core+shard rows 408–570, all < 974 baseline | this session |
| B: ladder/refute intact | ledger template machine_evidence schema unchanged; R-112 text present; t3 refutation exercised live | pass | grep outputs + t3 04-findings-1.yaml |
| C: AC-F-08 greps | exact plan commands | `0 0`; re-sweep zero hits exit 1 | this session |
| C: AC-F-09 greps | exact plan commands | 1/1/2 refs, 1 definition each; carried-forward 0; replacement phrase 1; header intact | this session |
| C: AC-F-10 greps + semantic re-read | plan commands + independent reading of R-8/R-43/R-53–55 vs R-118 | all three homes hit once; no unqualified MAY/MUST-NOT pair | this session |
| T1–T7 per-task greps | every plan verification block command | all expected counts met (T3:1; T4:1/1/1/1/1; T5:1/1/1+YAML-OK; T6:3/1/1; T7 all ≥1, untouched-prompts diff quiet) | this session |
| T9 rule uniqueness | `grep -rc "^\*\*R-<n>\.\*\*" protocol/` summed | R-110–R-118 each exactly 1; R-113 three halves | this session |
| Battery: delta range | `git diff --name-only 719085a..3a8fcb0` in t3-delta scratch repo | `calc.sh` only | re-executed this review |
| Battery: records | direct reads of all 8 run records + key reports/ledgers | every Implementation Package claim checked matched the on-disk artifact | this session |

Not verified:

| Item | Reason | Criteria affected |
|---|---|---|
| Harness-transcript claims (t4 FINAL 23-event tool-use log; SendMessage resumption being genuinely the same context) | Subagent transcripts not retained on disk; only artifacts are | None gating — AC-F-04/05/06 rest on the record/report/ledger artifacts, which I verified directly and which are internally consistent (persistent-session ledger header, by-ID citation, fresh command outputs); the tool-log check was the plan's own best-effort extra with a declared R-64 fallback |
| Cross-tool persistence (aider/cursor/etc.), real SAST/mutation, driver-side summarization routing | Declared NOT AVAILABLE in the package per R-64, matching the plan's Tooling Declaration | None — each declaration names its ACs and none is left carrying an AC alone; honest limitations, not silent skips (R-66 not triggered) |

## Deviation dispositions (R-5/R-6 — reviewer ruling)

1. **L3 moved to the STANDARD target (t3-delta).** ACCEPTED, no severity. The plan as written was unexecutable: a LIGHT run's only review is the combined FULL_FINAL pass, so there was no standalone FULL_REVIEW to reject a downgrade against. The relocation preserved every L3 check verbatim (warning in transcript comment, warning in record, session model served). Right call; AC-F-02 evidence is sound.
2. **L5b degrade is a SHOULD-election, not incapacity.** ACCEPTED, no severity. The shipped texts are conditional and correct either way (R-117 is SHOULD; the adapter says "where it cannot… dispatch fresh and record fresh-degraded — explicit, never silent"); an explicit recorded degrade is compliant conduct under a SHOULD regardless of whether the harness could have resumed. The honest reframing strengthens, not weakens, the evidence. Observation only: t1's record comment "cannot be resumed as dispatched" reads as incapacity — scratch evidence, not shipped text, so no finding.
3. **L6 FINAL LLM dispatch not re-run.** ACCEPTED, no severity. AC-N-03's metric is record-level (resume proceeds, defaults applied, explicit degrade appended, appends-only diff) — all evidenced and re-verified; full-scope FINAL conduct is separately live-evidenced (t2 combined pass, t4-freshfinal cold FINAL).

**Dispatch-origin process note (scratch battery):** in the /tmp harness the review dispatches originated from the implementer peer rather than a driver. The SHIPPED rules are correct: protocol/orchestrator.md §9.1 and prompts/orchestrator.md place all dispatch (including reviews, session management, and model selection) with the DRIVER, and the claude-code adapter's hard boundary forbids the driver authoring findings. R-1/R-2 isolation is authorship-based and held in the artifacts: every reviewer artifact carries a distinct produced_by, the t4 persistent reviewer authored none of the code it judged, and no reviewer context shows implementer authorship. The irregularity is confined to the test rig, which does not ship. Not a defect.

## Summary

Sub-project C ships exactly what the approved plan specified: R-116/R-117/R-118 landed verbatim at the plan's anchors, the R-110 carry-forward amendment and R-44 rewrite are in place, driver duties/prompts/adapters/config/template all carry the mirrored operational text, and zero-config remains byte-equivalent (all keys commented out; R-116's no-config sentence reproduces R-10 resolution; A's EXPRESS surface and B's ladder byte-untouched except the one mandated R-110 sentence). Every deterministic check in the plan and package was re-run by this reviewer and passed, including the drift check in both directions. The live battery is genuine and unusually strong — I re-executed its git ranges and re-read its records; the cheap-model routing, downgrade rejection, persistent/degraded/forced-fresh sessions, delta-FINAL with dirty-tree degrade, and pre-C resume are all evidenced on disk, and the forced-fresh FINAL even caught a real clean-tree signal discrepancy live, which points at the one defect I raise: the orchestrator shard's "clean for tracked source" prose disagrees with its own strict `--porcelain` parenthetical (F-hwC-101, Minor — fail-safe direction, one-line fix). One Nit on adapter headline wording. All three declared deviations are accepted; the R-64 declarations are honest limitations affecting no AC. 0 Blockers, 0 Majors: gate met.
