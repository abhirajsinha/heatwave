# Review Report

task_id: hw-v4-C-speed-token | artifact_type: review-report | iteration: 2 | review_type: PLAN_REVIEW | produced_by: REVIEWER (claude-fable-5) | timestamp: 2026-08-11

## Verdict

GATE_MET — plan APPROVED → IMPLEMENTING
Blockers: 0 open | Majors: 0 open | Minor: 0 open | Nit: 0 open

## Scope Evaluated

Iteration-2 delta (Responses block, T1.3/T1.4/T1.5, T2.1/T2.2, T4, T7.1/T7.3, T8.5, T10-L4, Edge Cases 11–12, AC-F-06/08/09/10) re-verified against the actual tree at `main` (`2492d55`), plus a no-new-contradictions and no-scope-creep pass over the whole revised document. Iteration-1 scope (spec conformance, LOCKED decisions, anchors, AC quality, task executability) unchanged and re-confirmed where the revision touched it.

## Scope Changes

None (per R-49).

## Reconciliation

| Finding ID | Prior status | Current status | Change reason |
|---|---|---|---|
| F-hwC-001 (Major) | Open | **Closed — verified** | T1.5's replacement (plan line 284) now reads "no prior verdict survives by reference … *v4-C supersedes B's carry-forward allowance*" — hyphenated "carry-forward" only; machine-checked: the new sentence contains zero matches for "carried forward". Repo's sole "carried forward" line remains `protocol/core.md:89` (the sentence being replaced), and no other C-inserted text introduces the string (R-118 body uses "carry-forward"). AC-F-09's `grep -c "carried forward" protocol/core.md` → 0 is now satisfiable by construction; T1 gains the positive grep "no prior verdict survives by reference" → 1. Supersession of B's allowance is still normative and explicit. |
| F-hwC-002 (Major) | Open | **Closed — verified** | New R-44 (plan line 312) says "supersedes the pre-C full-equivalence wording" and "complete at full scope, as before" — machine-checked: zero matches for "equivalent to FULL_REVIEW" across the new R-44, T2.2, and T7.3 texts (the single plan-file match at line 428 is the quoted OLD prompt string being deleted). Ground truth: `grep -c "equivalent to FULL_REVIEW" protocol/final-reviewer.md prompts/final-reviewer.md` today → 0 and 1 (the protocol file's old R-44 has backticks, so it never matched the unbackticked AC grep); T7.3 removes the one prompt hit → AC-F-08's `0 0` satisfiable. T2's own verification now runs the exact AC-F-08 command, so the two checks cannot diverge again. |
| F-hwC-003 (Major) | Open | **Closed — verified** | R-118(c) adopts floor-not-gag: "MUST NOT re-read … as routine re-review" (qualified), with R-8/R-54 discretion surviving at FINAL only as a **recorded R-49 scope expansion** reading exactly what substantiates a suspected delta-caused regression; blanket re-reading stays forbidden. Verified: R-49 exists and is precisely the recorded-scope-expansion rule (`protocol/reviewer.md:68`); no unqualified MAY/MUST-NOT pair remains between R-118(c) and R-8 (`core.md:126`) / R-54 (`core.md:275`); the LOCKED "never re-read unchanged files" decision is honored as the required/default scope (the carve-out is the reconciliation iteration 1 sanctioned, not a scope change). Mirrored consistently in T2.2 and T7.3(c); T8.5 adds the semantic check (R-8, R-43, R-53–R-55 vs final R-118) that string sweeps cannot perform; AC-F-10's greps match the normative strings exactly ("scope expansion (R-49)" in R-118; "R-49 scope expansion" in T2.2/T7.3). |
| F-hwC-004 (Minor) | Open | **Closed — verified** | Clean-tree precondition added where it belongs (T4 driver duty 3: `git status --porcelain` empty at FINAL dispatch; dirty tree = explicit full-scope degrade, recorded), echoed in R-118's degrade list ("or the working tree is dirty at dispatch"), new R-44's degrade conditions, T7.1, Edge Case 11, L4's dirty-tree branch run, and AC-F-06's extended method. Internally consistent across all six homes. |
| F-hwC-005 (Nit) | Open | **Closed — verified** | T1.3 names exactly one anchor: "§1.4, immediately after R-12 (i.e. before R-115)". |

Late findings: None.

## Acceptance Status

N/A — PLAN_REVIEW.

## Findings

None open. No new findings in iteration 2.

## Verification Log

Machine evidence (R-110 — plan-stage rungs): `tests` = drift check | `sh build-protocol.sh --check` | pass | "OK: PROTOCOL.md matches protocol/ shards", exit 0 (re-run iteration 1, tree unchanged at `2492d55`). `sast`/`mutation` = NOT_AVAILABLE for this docs repo per the plan's own R-64 declaration.

| Item | Method | Result | Evidence |
|---|---|---|---|
| F-001 grep satisfiable | `sed -n '279,286p' plan \| grep -c "carried forward"` → 2, both located: line 282 (quoted old sentence, deletion target) and line 286 (planner's own note quoting the string); line 284 (the normative replacement) matches only "carry-forward" | pass | new sentence clean; sole repo hit remains core.md:89 |
| F-002 grep satisfiable | `sed -n '312p;318p;428p' plan \| grep -c "equivalent to FULL_REVIEW"` → 1, located at line 428 = quoted OLD prompt text; `grep -c` on the two target files today → protocol 0 (backticked old text never matched), prompts 1 (replaced by T7.3) | pass | AC-F-08 `0 0` reachable by construction |
| F-003 reconciliation real | Read R-49 (`reviewer.md:68`), R-8 (`core.md:126`), R-43 (`reviewer.md:60`), R-53–R-55 against revised R-118(c)/T2.2/T7.3; checked AC-F-10's grep strings against the normative texts character-for-character | pass | qualified MUST-NOT + recorded R-49 channel; all three mirror strings match their greps |
| F-004 resolved everywhere | Read T4, R-118 degrade list, new R-44, T7.1, Edge 11, L4 dirty branch, AC-F-06 | pass | six homes consistent |
| F-005 resolved | Read T1.3 | pass | single anchor, matches real positions (R-12 line 152, R-115 line 154) |
| No new contradictions | Re-checked all revised verification greps against their own normative texts (T1: "no prior verdict survives by reference", "scope expansion (R-49)"; T2/T7: "R-49 scope expansion"; T4: "git status --porcelain"); re-checked R-116..118 reference forms don't inflate the `R-11x\.` definition counts | pass | every check matches its text; each rule defined once |
| No scope creep; numbering intact | Diff-read iteration 1 → 2: changes confined to the five finding responses (+T8.5, AC-F-10, dirty-tree branch, Edge 11–12); R-116..R-118 unchanged; LOCKED decisions verbatim; R-34 response block present and accurate | pass | plan's own closing note confirmed against the document |

Not verified:

| Item | Reason | Criteria affected |
|---|---|---|
| Cheap-model per-subagent dispatch; generic-adapter persistent path | Execution-stage live-battery items; plan labels both as assumptions with R-64/R-66 fallback | AC-F-01/02/04a (at IMPLEMENTING, not here) |

## Summary

All five iteration-1 findings are genuinely resolved, and the two grep contradictions are closed the right way: not by weakening the checks but by rewording the normative texts so the exact AC commands pass by construction — machine-verified against the plan's own lines and the current tree, including the discovery that the protocol-file half of AC-F-08 was already 0 (backticks) and only the prompt hit needed removing. The F-hwC-003 resolution is the strongest part of the revision: R-118(c) is now a floor, not a gag — the LOCKED delta scope stays the required default while R-8/R-54 discretion survives only as a recorded R-49 expansion, and T8.5 institutionalizes the semantic check that catches this class where string sweeps cannot. The dirty-tree degrade is wired consistently through rule, driver duty, prompt, edge case, battery branch, and AC. No new findings, no scope creep, no LOCKED deviation, numbering intact. The plan proceeds to IMPLEMENTING.

---
---

# Iteration 1 (superseded 2026-08-11 by the iteration-2 verdict above; retained per R-58 for reconciliation)

## Verdict (iteration 1)

GATE_NOT_MET
Blockers: 0 open | Majors: 3 open | Minor: 1 | Nit: 1

REJECTED → PLANNING.

## Scope Evaluated

Plan scope as declared (plan-conformance, verification-integrity, data-integrity) plus §3.2 completeness, §3.2.2 AC verifiability, tooling-declaration realism (R-99/R-63), tier, and internal consistency — all ground-truthed against the post-A/B tree at `main` (`2492d55`, drift check `OK`, exit 0, run this review).

## Scope Changes

None (per R-49).

## Findings (iteration 1)

### F-hwC-001 | Major | acceptance-criteria — AC-F-09/T1 grep is unsatisfiable against T1.5's own normative text

- **Where:** plan lines 199 (T1.5 replacement text) vs 208 (T1 verification) and 401 (AC-F-09).
- **What:** T1.5's normative R-110 replacement reads "…no verdict is **carried forward** (R-118(b), R-117 safety clause…)". T1's verification and AC-F-09 both require `grep -c "carried forward" protocol/core.md` → **0**. The replacement text itself contains the string, so the check yields 1 by construction. The plan declares rule text "normative — inserted verbatim" (line 156), so the implementer can satisfy the text or the check, never both, without a Deviation Record.
- **Why it matters:** an acceptance criterion that cannot pass as written is an unmet-AC class defect (§8.2 Major); it forces mid-implementation deviation on a gate check in a plan whose whole subject is verification integrity.
- **Verification method (for PLANNER):** reword the normative sentence (e.g. "no verdict carries forward" or "no prior verdict survives") or scope the grep to the exact retired B sentence; then confirm `grep -c "carried forward" protocol/core.md` → 0 is achievable with the normative text in place. Keep the Rollback step-4 expectation (1 hit after revert) consistent.

### F-hwC-002 | Major | acceptance-criteria — AC-F-08 grep is unsatisfiable against T2.1's own normative R-44 text

- **Where:** plan line 224 (T2.1 replacement) vs line 400 (AC-F-08).
- **What:** the new R-44 ends "…the evaluation is complete and **equivalent to FULL_REVIEW**, as before." AC-F-08 requires `grep -c "equivalent to FULL_REVIEW" prompts/final-reviewer.md protocol/final-reviewer.md` → `0 0`. The protocol/final-reviewer.md count is 1 by construction. (T2's own check at line 232 greps the backticked variant `` equivalent to `FULL_REVIEW` `` and passes — the two checks diverge; AC-F-08 is the gating one.) T8.4's sweep pattern also hits this line; T8 tolerates read-and-judge hits, AC-F-08's count does not.
- **Why it matters:** same class as F-hwC-001 — a spec-§8.8-mapped AC guaranteed to fail.
- **Verification method:** reword the degrade sentence (e.g. "the evaluation is complete at full scope, as before") or pin AC-F-08 to the backticked/exact retired phrasing; confirm the counts are then achievable.

### F-hwC-003 | Major | plan-conformance / internal consistency — R-54 and R-8 vs R-118(c): a third cross-rule contradiction of the exact class the plan resolves twice, left standing

- **Where:** plan lines 194 (R-118 text) and 228 (T2.2) vs `protocol/core.md:126` (R-8: "The REVIEWER MAY expand review scope… MUST NOT narrow scope below what the approved plan specifies") and `protocol/core.md:275` (R-54: "Blast radius is a claim, not a constraint on the REVIEWER. The REVIEWER MAY review outside the declared radius").
- **What:** new R-118(c) is unconditional: at FINAL the REVIEWER "MUST NOT re-read files unchanged since that SHA." R-8 and R-54 — both in core.md, both loaded at every FINAL dispatch — grant the reviewer the opposite permission. The plan's own §Architecture note (line 56) names why this may not stand: "leaving both texts standing would let a reviewer cite whichever is convenient." The plan surfaced and fixed the R-110 and R-44 instances; this one escaped because the T8 sweep greps surface strings ("re-read|re-review|complete evaluation") and R-8/R-54 contain none of them — a semantic conflict a string sweep cannot catch. Concrete failure mode: a FINAL reviewer suspects a fix in the delta broke an unchanged caller; R-54 invites reading it, R-118 forbids it, and neither text says which wins or how the suspicion is expressed.
- **Why it matters:** the deliverable is rule text; two core rules in direct conflict at FINAL is incorrect behavior of the product itself, and this identical class caused the A and B plan rejections.
- **Verification method:** add one reconciling clause to R-118 (and mirror in T2.2's paragraph), e.g.: "R-8/R-54 scope expansion at FINAL_REVIEW is expressed by failing the review — a suspected out-of-delta regression is a finding grounds for GATE_NOT_MET, routing to FIXING with a FULL_REVIEW next (R-14) — never by reading beyond the delta" (or a narrow carve-out permitting reads strictly to substantiate a delta-caused regression). Then re-run the semantic check: read R-8, R-43, R-53–R-55 against final R-118 text and confirm no MAY/MUST-NOT pair survives unqualified. This honors the LOCKED "never re-read unchanged files" decision — it resolves the text conflict, not the behavior.

### F-hwC-004 | Minor | verification-integrity — `git diff <sha>..HEAD` sees only committed work; the commit precondition at FINAL is unstated

- **Where:** plan lines 59, 194, 258 (delta mechanics, R-118(c), T4 driver duty).
- **What:** the delta is defined as commits since the last FULL_REVIEW SHA. No protocol rule (checked: `grep -n commit protocol/*.md` — nothing binding) requires FIXING output to be committed before FINAL dispatch. With a dirty tree the range diff is empty: FINAL's LLM pass reviews nothing while uncommitted fix code sits in the working tree. Risk is bounded (TARGETED already reviewed the fixes; machine gates run on the working tree; R-14 backstop) and the range syntax is spec-LOCKED — hence Minor, not Major.
- **Verification method:** add one sentence to the T4 driver duty: at FINAL dispatch the driver verifies the working tree is clean relative to HEAD (`git status --porcelain` empty for tracked source); a dirty tree is treated as the existing explicit full-scope degrade. Add the matching L4 sub-check.

### F-hwC-005 | Nit | clarity — T1.3 names two anchors

- **Where:** plan lines 186–190. "after the closing line of the R-10 YAML block" and "insert after R-12" are different positions; the placement note ("before R-115") disambiguates, but the sentence should name one anchor. Cosmetic.

## Verification Log (iteration 1)

Machine evidence (R-110 — plan-stage rungs): `tests` = drift check | `sh build-protocol.sh --check` | pass | "OK: PROTOCOL.md matches protocol/ shards", exit 0. `sast`/`mutation` = NOT_AVAILABLE for this docs repo, matching the plan's own R-64 declaration — affects no plan-stage AC.

| Item | Method | Result | Evidence |
|---|---|---|---|
| A/B merged; drift green | `git log --oneline`; `sh build-protocol.sh --check` | pass | head `2492d55`; OK, exit 0 |
| R-116..118 collision-free; highest rule R-115 | `grep -rn "R-11[0-9]\." protocol/` + repo grep for R-116/117/118 | pass | R-110–R-115 present; zero R-116+ hits |
| R-110 carry-forward sentence exists verbatim, sole hit | grep "carried forward" repo-wide | pass | `protocol/core.md:89` only; text byte-identical to plan quote |
| R-44 old text verbatim; R-45, §4.7, §8.3 present | Read `protocol/final-reviewer.md` | pass | lines 9, 11 |
| Anchors: §1.2 R-2 blockquote line 116; R-12 line 152; R-115 line 154; R-14 line 229; R-43 `reviewer.md:60`; R-85 + v4 two-duties `orchestrator.md:62–64` | Read/grep shards | pass | all match plan claims |
| Prompt anchors: `prompts/final-reviewer.md:7` old item 1; `prompts/orchestrator.md:30` "fresh context" step 2; `prompts/reviewer.md:17` "Always" | grep | pass | verbatim |
| Template/config anchors: `run-record.yaml:19` hetero_reviewer, `:28` transitions comment; config `:55` design-docs block; history F.1 3-column table | grep/read | pass | T5/T6/T9 old-strings exact; F.1 columns match T9.1 row |
| Adapter/doc hits: `HEATWAVE.md:9,15`; `HEATWAVE-AGENT.md:12`; `faq.md:13` | grep + read | pass | T8 inventory accurate; remaining hits (faq:4, getting-started:49, reviewer agent desc) compatible as plan claims; `plugins/` clean |
| Spec conformance: G1–G4 → FR-1..5 → tasks → ACs; §8.1–8.8 → AC-F-01..08; LOCKED §3 sets verbatim in R-116 table; safety clause + `fresh_final_reviewer` in R-117; delta scope (a)–(d) in R-118; zero-config preserved; no D–H leak | line-by-line map, spec vs plan | pass | mapping complete; EXPRESS-PLAN_REVIEW vacuity honestly footnoted |
| Flagged interaction 1 (R-110 vs safety clause) | judge T1.5 vs LOCKED §3/§4.2 | resolution correct in substance | locked decision wins; but see F-hwC-001 |
| Flagged interaction 2 (R-44 "equivalent to FULL_REVIEW") | judge T2.1 vs R-118 + LIGHT tier table §0.5 | resolution correct in substance | LIGHT combined-pass equivalence preserved; but see F-hwC-002 |
| §3.2 completeness, tier=FULL, change_class=feature, tooling declaration realism | section audit; commands re-run where claimed "confirmed" | pass | all sections present; drift + POSIX confirmed live; two "assumed" entries properly labeled with R-64/R-66 fallbacks |

Not verified:

| Item | Reason | Criteria affected |
|---|---|---|
| Cheap-model per-subagent dispatch; generic-adapter persistent path | Live-battery items — execution-stage, not plan-stage; plan labels both as assumptions with R-64/R-66 fallback | AC-F-01/02/04a (at IMPLEMENTING, not here) |

## Summary (iteration 1)

The plan is strong: every spec goal and §8 item maps to a task and an AC, all LOCKED decisions are honored verbatim (including the non-downgradable frontier set, the safety clause, and zero-config), every cited anchor in the post-A/B tree is real and byte-accurate, and the two cross-rule interactions the planner surfaced — B's R-110 carry-forward and R-44's "equivalent to FULL_REVIEW" — are resolved in the right direction and consistently with the LIGHT combined pass. It fails the gate on three Majors, all in the plan's own consistency: two AC verification greps (AC-F-08, AC-F-09/T1) are guaranteed to fail because the normative replacement texts themselves contain the very strings the checks require absent; and a third contradiction of exactly the class the planner fixed twice — R-54/R-8's "REVIEWER MAY read beyond" versus R-118's unconditional "MUST NOT re-read" — is left standing because the string sweep cannot see semantic conflicts. All three have small, local fixes; none disturbs a LOCKED decision. One Minor (dirty-tree delta precondition) and one Nit (T1.3 dual anchor) recorded for the same pass.
