# Review Report

task_id: hw-v4-B-machine-evidence | artifact_type: review-report | iteration: 2 | review_type: PLAN_REVIEW | produced_by: REVIEWER (claude-fable-5) | timestamp: 2026-08-11

---

# Iteration 2 — Verdict on the revised Planning Document

## Verdict

GATE_MET — **APPROVED**
Blockers: 0 open | Majors: 0 open | Minor: 1 (deferred, reviewer-approved) | Nit: 1

## Reconciliation (R-58) — all 10 iteration-1 findings

| Finding ID | Prior status | Current status | Change reason + ground-truth verification |
|---|---|---|---|
| F-hwB-001 (Major) | Open | **Fixed** | T2 edit 3 amends Appendix A itself: `Refuted` added to the Status enum, `Origin` and `Refutation` schema rows added with exact text; T2 edit 4 replaces R-109's "field semantics are unchanged" sentence so schema and ledger cannot contradict. Planner's Status-enum enumeration re-verified by my own grep (`grep -rn "Deferred (approved)" protocol/ templates/ prompts/`): exactly three enum sites — Appendix A (reviewer.md:133, T2 edit 3), R-77 (core.md:294, T1 edit 4), ledger template (T6). core.md:111 (R-6) is deferral prose, correctly left alone; fix-report.md:10's `Response:` enum is a different enum (responses, not statuses). T10 gains check 5 (straggler sweep). Genuinely closed — see F-hwB-011 for the one residual visibility gap the R-31 clause leaves. |
| F-hwB-002 (Major) | Open | **Fixed** | T1 edit 3(c) now rewrites the drive-behavior sentence to the exact four-field form recommended ("Only `tier`, `tier_justification`, `design_doc`, and `change_class` drive behavior."), RESERVED sentence untouched; verification grep adopted into T1. Consistent with R-114. |
| F-hwB-003 (Major) | Open | **Fixed** | R-115 reworded: advisory computed "when BOTH the implementer and reviewer roles have resolved — at the first FULL_REVIEW (or LIGHT combined-pass) dispatch", recomputed+appended on R-11 substitution. Verified R-11 IS the substitution rule (core.md:139: "the substitution MUST be recorded in the Run Record") — cross-reference correct. T5 and T9 orchestrator lines carry the same timing; T11 L2 gains the append-order timing assertion (deterministic: record diff at PLAN_REVIEW-time vs final); AC-F-05 verification updated; Edge Case 11 documents the PLAN_REVIEW non-firing. Baseline greps confirmed: "BOTH" and "evidence_ref" currently 0 hits in core.md, so the expect-1 checks are valid. |
| F-hwB-004 (Minor) | Open | **Fixed** | T1 edit 4 replaces the R-77 exclusion line verbatim (old string matches core.md:294 byte-exact) adding `Status: Refuted` (R-112). |
| F-hwB-005 (Minor) | Open | **Fixed** | Architecture table row now reads "new §3.4.2; Appendix A schema extension" — the phantom §5.7 promise is gone; T2 point 5 keeps the placement note. One instruction for the implementer. (The response block's own grep claim is slightly off — see F-hwB-012, Nit.) |
| F-hwB-006 (Minor) | Open | **Fixed** | R-110's carry-forward sentence now operationalized exactly as recommended: permitted only when the run's diff since the verdict is empty for the rung's scope (the files it scanned/mutated), carry-forward names the prior `evidence_ref`, tests always re-run. D-7 and Edge Case 5 restated to match. |
| F-hwB-007 (Minor) | Open | **Fixed** | R-111 assigns default categories: failing test → verified AC's category else `verification-integrity`; SAST → matching Security category from Appendix C; mutant → `verification-integrity`. Verified Appendix C has a Security section (planner.md:165-167) — the reference is real. D-4 updated to match. |
| F-hwB-008 (Minor) | Open | **Fixed** | Rollback step 2 now `git revert <first>^..<last>` — correct, non-empty range. |
| F-hwB-009 (Nit) | Open | **Fixed** | T10 check 4 pattern extended to match the named halves: `R-11[0-5]\.|R-113 \((planner|implementer|reviewer) half\)\.`, cross-referenced with AC-F-09's count of 3. |
| F-hwB-010 (Nit) | Accepted, no action | **Closed (no action, as disposed)** | D-2 retained verbatim per iteration-1 acceptance. |

Late findings (R-60): two, both introduced by inspection of the revision's new material, neither reopening a prior area.

## New Findings (iteration 2)

### F-hwB-011 | Minor | internal-consistency (shard visibility) — DEFERRED by REVIEWER approval (R-6/R-78)
**Location:** revised R-112 text (T2 edit 1) vs `protocol/core.md:25` (shard map: FIXING loads only core.md + fixer.md) and `protocol/fixer.md:21` (R-31), `prompts/fixer.md:7`
**Problem:** The R-31 carve-out ("refuted findings are outside the set R-31 obliges the FIXER to answer") lives only in R-112, in `protocol/reviewer.md` — a shard the FIXING dispatch never loads. A FIXER sees the ledger's `status: refuted` entries plus R-31's "Every finding ... MUST have exactly one response entry. Silence is not a response." and will either author no-op responses or be confused.
**Why Minor, not Major:** no gate impact (R-77 now excludes Refuted; refuted findings cannot enter FIXING as work items) — worst case is a harmless surplus response entry. This is the same cross-shard blind-spot class as F-hwB-001, but with no contradiction in the rendered PROTOCOL.md, which contains both texts.
**Fix (one clause):** append to R-31 in `protocol/fixer.md` — "Findings with `status: refuted` (R-112) require no response." — and optionally the matching six words in `prompts/fixer.md`'s response bullet.
**Deferral:** Minors do not gate (R-78). Deferred with recorded reason: one-clause edit, cheapest landed during IMPLEMENTING as a declared Deviation Record extending T2's scope to fixer.md (or a T2b micro-edit); MUST be reconciled at FULL_REVIEW.

### F-hwB-012 | Nit | evidence accuracy (plan document, response block only)
**Location:** revised plan, F-hwB-005 response block ("grep -c \"5.7\" on this document → 0 hits outside this response block")
**Problem:** The claim is inaccurate — T2 point 5's placement note ("no separate §5.7 heading") also contains "§5.7". Substance unaffected: both remaining mentions agree there is no §5.7, so the original contradiction stays resolved. Flagged only because this protocol treats stated-verification accuracy as load-bearing (R-65 hygiene).

## Iteration-2 Verification Log

| Item | Method | Result | Evidence |
|---|---|---|---|
| Repo unchanged since iteration 1; numbering still collision-free | `git log -1`, `git status --porcelain`, `grep -rn "R-11[0-5]" protocol/ templates/ prompts/ heatwave.config.example.yaml adapters/` | PASS | HEAD `0cecd88`; only untracked docs; 0 hits |
| R-77 old-string byte match for T1 edit 4 | read core.md:294 | PASS | line matches the plan's replacement target exactly |
| R-11 is the substitution rule R-115 cites | grep core.md | PASS | core.md:139 |
| Appendix C Security categories exist for R-111 defaults | sed planner.md:151-185 | PASS | Security section with 13 categories |
| Status-enum enumeration completeness (planner's F-001 sweep re-derived independently) | `grep -rn "Deferred (approved)" protocol/ templates/ prompts/` + read fix-report.md/run-record.yaml/review-report.md | PASS with one visibility gap | 3 enum sites all covered by T1/T2/T6; fix-report `Response:` and review-report AC-status are unrelated enums; run-record `final_status` free-form → F-hwB-011 records the FIXER-shard visibility gap |
| FIXER shard-loading blind spot | read core.md shard map (line 25) | CONFIRMED | FIXING loads core + fixer only → F-hwB-011 |
| New grep expect-counts valid against baseline | `grep -c "BOTH"` / `"evidence_ref"` on core.md | PASS | both 0 pre-edit |
| No new contradictions, no C/D/E leak, tier table / tool-agnosticism / locked decisions unchanged | full re-read of revision diff areas (Responses block, T1-T5, T9-T11, ACs, Edge Cases 5/11, D-4/D-6/D-7, Error Handling) | PASS | revision edits are consistency fixes within B scope only |

## Iteration-2 Summary

All ten iteration-1 findings are genuinely resolved with exact normative text, not acknowledgments — each fix was ground-truthed against the live repo (byte-exact old strings, real cross-references, valid grep baselines). The revision introduces no new contradiction, no scope creep, and no numbering collision. One new Minor (FIXER-shard visibility of the R-31 carve-out — a one-clause fix, deferred with recorded reason and reconciled at FULL_REVIEW) and one Nit (an inaccurate grep claim inside a response block) do not gate. PLAN_REVIEW gate met: zero Blockers, zero Majors. The plan proceeds to IMPLEMENTING.

---

# Iteration 1 (historical) — original report below

## Verdict

GATE_NOT_MET — REJECTED, back to PLANNER
Blockers: 0 open | Majors: 3 open | Minor: 5 | Nit: 2

## Scope Evaluated

Planning Document `docs/superpowers/plans/2026-08-10-machine-evidence-rigor.md` against approved spec `docs/specs/2026-08-10-machine-evidence-rigor-design.md`, ground-truthed against the post-A tree at `main` HEAD `0cecd88` (drift check run: `OK: PROTOCOL.md matches protocol/ shards`, exit 0).

## Scope Changes

None.

## Reconciliation

N/A — iteration 1.

## Acceptance Status

N/A — PLAN_REVIEW.

## Findings

### F-hwB-001 | Major | plan-conformance / internal-consistency
**Location:** plan T2/T6 vs `protocol/reviewer.md:119-134` (Appendix A — Finding Schema)
**Problem:** The plan adds `status: refuted` and the `origin`/`refutation` fields only to `templates/findings-ledger.yaml` (T6). No task edits Appendix A, whose Status enum is closed: `Open | Fixed | Deferred (approved) | Waived (OWNER) | Disputed`. R-29 mandates the Appendix A schema; R-109 states "Appendix A field semantics are unchanged — the ledger is their compact carrier"; the plan's own R-111 text says "All other Appendix A semantics apply." Post-B, the normative schema forbids the very status R-112 requires, and R-109's "unchanged" claim becomes false.
**Why it matters:** The product of this repo IS the rule text; an internal schema contradiction is exactly the ambiguity B exists to eliminate, and it would be raised as a Major at FULL_REVIEW anyway. The T10 sweep cannot catch it (its grep excludes `protocol/`).
**Fix:** In T2, extend Appendix A: add `Refuted` to the Status enum and add `Origin` (reviewer | machine, default reviewer) and `Refutation` (required Major+) rows; adjust or footnote R-109's "unchanged" sentence.
**Verification:** `grep -n "Refuted" protocol/reviewer.md` non-empty within Appendix A; drift check exit 0.

### F-hwB-002 | Major | plan-conformance / internal-consistency
**Location:** plan T1 vs `protocol/core.md:237`
**Problem:** Core §2.5 states normatively: "Only `tier`, `tier_justification`, and `design_doc` drive behavior." T1 adds `change_class` as an active, behavior-driving field (R-114: "Only `bugfix` alters behavior (R-113)") in the same section but never amends this sentence. Post-B it is false and directly contradicts R-114 three paragraphs below.
**Why it matters:** A driver reading the untouched sentence may treat `change_class` like the RESERVED fields (recorded, consulted by nothing) and skip R-113 — silently disabling reproduce-then-fix, one of the sub-project's five goals.
**Fix:** T1(c) additionally rewrites the sentence to "Only `tier`, `tier_justification`, `design_doc`, and `change_class` drive behavior."
**Verification:** `grep -n "drive behavior" protocol/core.md` shows the four-field sentence; drift check exit 0.

### F-hwB-003 | Major | business-logic (rule-text timing defect)
**Location:** plan T1 edit 2 (R-115 text) and T9 orchestrator addition
**Problem:** R-115 as drafted: "When the reviewer role first resolves for a run, the driver MUST compare the resolved reviewer and implementer models." The reviewer role first resolves at PLAN_REVIEW — before IMPLEMENTING, when `roles.implementer.resolved` is still blank (`templates/run-record.yaml:14-17`). The comparison is defined at a moment when one operand does not exist; a later implementer substitution (the schema's `substitution_reason` exists precisely for fallbacks, e.g. the configured Fable→Opus fallback) can invalidate an early-computed flag.
**Why it matters:** The advisory is G4's entire deliverable. As written it is computed from a blank or assumed value in any configured/substituted run — recording a wrong `hetero_reviewer` is worse than none. The T11 battery would pass by luck (L2 all-same-model; H1 differs regardless), so the defect ships unverified.
**Fix:** Reword R-115 and the T9 orchestrator line to compute the flag when BOTH roles have resolved (i.e., at the first ladder-bearing review dispatch), and to recompute/append if either role's resolved model subsequently changes. Add a T11 assertion that the flag is written no earlier than FULL_REVIEW dispatch.
**Verification:** Rule text grep; L2 transcript shows the flag recorded at/after FULL_REVIEW dispatch.

### F-hwB-004 | Minor | internal-consistency
**Location:** plan T2 (R-112 "MUST NOT gate") vs `protocol/core.md:294` (R-77)
**Problem:** R-77 defines "open" as excluding only `Deferred (approved)` and `Waived (OWNER)`. `refuted` is not in the exclusion list; a strict reader of the gate rule counts a refuted Major as gating, contradicting R-112.
**Fix:** One-line R-77 extension (natural companion to F-hwB-001's Appendix A edit): open excludes Deferred, Waived, and Refuted.

### F-hwB-005 | Minor | internal-consistency (plan document)
**Location:** plan Architecture table ("new §3.4.2 + §5.7") vs T2 point 3 ("A '§5.7' heading is NOT added")
**Problem:** The plan promises §5.7 in one section and explicitly declines it in another. T2's reasoning is sound (one home, smaller diff) — the Architecture table row must drop "§5.7" so the implementer has one instruction.

### F-hwB-006 | Minor | verification-integrity
**Location:** plan D-7 / R-110 final sentence ("a rung whose inputs are unchanged since its last recorded verdict MAY carry that verdict forward by reference")
**Problem:** "Inputs unchanged" is not operationalized — no stated criterion (diff of what, verified how) for the carry-forward judgment. A lax FINAL reviewer can carry a stale SAST verdict across a fix that touched scanned files. Tests-always-re-run mitigates but does not close it.
**Fix:** One clause: carry-forward is permitted only when the run's diff since the verdict's recording is empty for the rung's scope, and the reference names the prior verdict's evidence_ref.

### F-hwB-007 | Minor | acceptance-criteria (schema completeness)
**Location:** plan T2, R-111 text
**Problem:** R-111 converts rung results to findings "mechanically" and says "All other Appendix A semantics apply" — but Appendix A makes `category` mandatory and R-111 assigns none. The one non-mechanical field in a "mechanical" conversion is unspecified.
**Fix:** State defaults in R-111 (e.g. failing test → `verification-integrity` or the affected AC's category; SAST → the relevant security category; surviving mutant → `verification-integrity`), reviewer MAY override per R-5.

### F-hwB-008 | Minor | correctness (rollback plan)
**Location:** plan Rollback step 2
**Problem:** `git revert <last>..<first>` is an empty range (commits reachable from `<first>` but not `<last>` — none, since `<last>` descends from `<first>`). Correct form: `git revert <first>^..<last>`. The per-commit alternative in parentheses is the only working path as written.

### F-hwB-009 | Nit | verification method precision
**Location:** plan T10 check 4
**Problem:** `grep -rn "R-11[0-5]\." protocol/` never matches R-113's named halves ("R-113 (planner half)." has no digit-dot). AC-F-09's separate `grep -c "R-113 ("` covers it; T10's uniqueness claim for R-113 should point there or use a pattern that matches the halves.

### F-hwB-010 | Nit | declared spec deviation — accepted
**Location:** plan D-2 vs spec §4.4/§5 (`reviewer_model`/`implementer_model` fields)
**Disposition:** Accepted by this review. The run record already carries resolved models per role (verified: `templates/run-record.yaml:14-17`); a single computed `hetero_reviewer` satisfies spec §4.4's intent (models recorded + equality visible) without a driftable duplicate. Deviation was declared with justification, as required. No action.

## Verification Log

| Item | Method | Result | Evidence |
|---|---|---|---|
| A merged, drift green | `git log`, `sh build-protocol.sh --check` | PASS | HEAD `0cecd88`; "OK: PROTOCOL.md matches protocol/ shards", exit 0 |
| Rule numbering: highest live rule R-109, no R-110..115 collision | `grep -rn "R-11[0-5]" protocol/ templates/ prompts/ heatwave.config.example.yaml adapters/` | PASS | zero hits; R-106 exists as named halves (precedent for R-113's halves confirmed) |
| T1 anchors (core.md) | grep/sed | PASS | R-103 at line 78 exactly as plan states; §1.4 R-12 at 141; §2.5 run_config `design_doc` line, R-106 driver half, pre-v4 defaults sentence ending `scope: single_repo` — all present |
| T2 anchors (reviewer.md) | grep | PASS | §3.4.1/R-109 at 30-32, §4.4/R-39 at 42-44, §5.6/R-58/R-59, R-55, R-44 (final-reviewer.md:9) all real |
| T3 anchors (planner.md) | sed §6.1 | PASS | §3.2.2/R-27, §6.1 R-62/R-99 + example block in exact pipe format the plan's two appended rows match |
| T4 anchors (implementer.md) | grep | PASS | §4.3/R-38; §3.3 row text `Per 6.4 — evidence, not assertion` byte-exact as the plan's old_string |
| T5 anchors (orchestrator.md) | grep | PASS | §9.1/R-85 at 62; §9.2 resume clause at 91 confirms T5's claim that no §9.2 edit is needed |
| T6/T7 template anchors | cat -n | PASS | ledger `verdict:` line 8, `category:` 12, `verification:` 18, `status:` 21; run-record `design_doc` line 11, `roles:` 14-17 (plan's "schema line 14–17" exact); planning-document `## Tier` 5, AC-F example 57, `## Tooling Declaration` 75; review-report `## Verification Log` 33 |
| T8 config anchors | grep | PASS | "Models per role" 12, "uncorrelated blind spots" 13, "Test tooling" 19 |
| T9 prompt anchors | grep | PASS | reviewer FULL_REVIEW + Always; planner "Get right:"; implementer "## Evidence"; orchestrator "Intake" + "The loop" all present |
| Adapter consistency (spec 8.8 pre-check) | plan's own T10 sweep run now | PASS | zero hits for ladder/refut/mutation/sast/change_class/hetero; adapter shims carry only role/tier/"evidence, not assertion" invariants — compatible with B, as the plan claims |
| Tier table vs spec §3 locked table | side-by-side read | PASS | EXPRESS none / LIGHT tests / STANDARD +SAST / FULL +mutation; refute Major+ only; reproduce bug-class LIGHT+ — exact |
| Tool-agnosticism (B/D boundary) | read T3/T8/T11 | PASS | semgrep/stryker named only as detection-evidence examples (spec §4.5 itself names them) and commented config samples; no runner wired; stub-tool harness is honest — plan's Tooling Declaration explicitly declares real SAST/mutation NOT AVAILABLE (`command -v` evidence) and argues correctly that stubs exercise the contract (verdict recording + degradation), which is all B claims |
| C/D/E leakage | read whole plan | PASS | no model tiering, no delta LLM review, no tool adapters, no benchmark; D-7 is machine-rung economy, not C's delta review |
| Spec §2 goals G1-G5 → tasks+ACs | mapping check | PASS | G1→T1/T2/AC-F-01/02/06; G2→T2/AC-F-03; G3→T1/T3/T4/T2/AC-F-04; G4→T1/T5/T8/AC-F-05; G5→T1 table/AC-F-06 |
| Spec §8 items 1-8 → ACs | mapping check | PASS | AC-F-01..08 map 1:1 as labeled; both directions covered for refute (AC-F-03a/b/c) and reproduce (AC-F-04a/b); H1 unavailability degrades to R-64/R-66, not a fake pass |
| Rule text shown verbatim for R-110..R-115 | read T1-T4 | PASS | full normative text present for all six rules (R-113 in three halves); ledger/run-record field additions given as exact YAML |
| Drift regeneration per rule task | read G-5, T1-T5, T10 | PASS | every shard-editing task ends with regenerate + `--check` exit 0 |
| A-preservation (EXPRESS instant, resume-compat) | read G-4, NFR-2/3, AC-N-02/03, T11 resume check | PASS as designed | byte-identity checks named; new fields optional+defaulted; §9.2 clause verified future-proof |

Not verified:

| Item | Reason | Criteria affected |
|---|---|---|
| Live battery feasibility (T11 L1-L4, N1-N3, H1) | PLAN_REVIEW verifies design, not execution; A's T11 precedent is committed evidence but this battery has not run | AC-F-01..07 (execution deferred to FULL_REVIEW) |
| H1 different-model dispatch capability | Declared assumption in the plan (honest, R-64-labeled with degrade path) | AC-F-05b |

## Summary

Ground-truthing was unusually clean: every cited file, section anchor, line number, and rule reference in the plan is real and exact — including "R-103 currently line 78" and "run-record schema line 14–17". Numbering continues correctly from R-109 with zero collisions. The tier-scaling table matches the spec's locked table exactly; hetero-reviewer stays recommend-not-mandate; the B/D boundary holds (stubs test the contract, real tools stay in D, and the plan's own tooling declaration is honest about what is NOT AVAILABLE). No C/D/E leakage. AC coverage maps 1:1 onto spec §8 with both directions of refute-or-promote and reproduce-then-fix genuinely testable.

The rejection is for three deterministic consistency defects, all cheap to fix: (1) Appendix A — the normative finding schema — is never updated, so the canonical Status enum forbids `refuted` while three rules (R-29/R-109/R-111) bind findings to that schema; (2) core §2.5's "Only tier, tier_justification, and design_doc drive behavior" sentence survives unamended and flatly contradicts R-114 in the same section; (3) R-115 computes the hetero advisory "when the reviewer role first resolves" — a moment when the implementer's resolved model does not yet exist, and the battery would pass by luck. Each fix is a few lines in T1/T2/T9; one PLANNING iteration should clear all findings.
