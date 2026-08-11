# Review Report

task_id: 2026-08-11-ecosystem-companions | artifact_type: review-report | iteration: 1 | review_type: PLAN_REVIEW | produced_by: REVIEWER (claude-fable-5) | timestamp: 2026-08-11

## Verdict

GATE_MET → **APPROVED**
Blockers: 0 open | Majors: 0 open | Minor: 2 | Nit: 2

## Scope Evaluated

§4.2 PLAN_REVIEW criteria against the plan's declared scope: plan-conformance (spec §2 G1–G7, §3 locked decisions, §4.7 policy, §5 file list, §8 verification items), verification-integrity, secure-config (companion gating semantics), secret-management (gitleaks-rung semantics), over-engineering. Identity constraint (zero new runtime dependencies) reviewed as part of plan-conformance to spec §5 / non-goal 2.

## Scope Changes

None.

## Reconciliation

Iteration 1 — no prior findings.

Late findings: None.

## Acceptance Status

N/A at PLAN_REVIEW. AC coverage judged for completeness/verifiability below.

## Findings

**F-2026-08-11-ecosystem-companions-001 | Minor | plan-conformance**
`docs/superpowers/plans/2026-08-11-ecosystem-companions.md` FR-7 + Architecture §6.5 table (lines 26, 61–69). FR-7 claims the spec §4.7 table is "reproduced exactly," but three cells are deliberately normalized: gitleaks trigger "every run" → "every run with a FINAL"; `/security-review` trigger "{auth,input,deps,secrets,API}" → "change_surface ∩ {auth, external-input, deps, secrets, api-surface}"; Playwright "UI change-type; MCP present" → "change_surface ∋ ui; MCP present". Every normalization is an improvement consistent with R-121/R-122 mechanics and I judge them intent-preserving — the defect is the word "exactly," which misstates conformance and invites a false-drift finding at FULL_REVIEW. Fix during implementation: reword FR-7 (or add one deviation line) to "reproduced in the change_surface vocabulary, with the FINAL-presence precision for gitleaks." No re-plan needed.

**F-2026-08-11-ecosystem-companions-002 | Minor | secure-config**
Plan FR-6 / R-120 / R-122 vs spec §4.6. The spec gates `/security-review` on "input-handling"; the plan's single `change_surface` vocabulary substitutes "external-input" (the Strix token from spec §3/§4.5) without noting the mapping. Edge risk: a change handling untrusted input a planner reads as not strictly "external" (user-supplied file parsing, inter-service payloads) could be classified outside the gate and suppress the semantic pass. Mitigants already in the plan: R-122 makes misclassification a minimum-Major reviewer finding when it suppresses a security companion, and Appendix C's `input-validation` category is the declared evidence base. Fix during implementation: one clause in R-122 defining `external-input` as "any handling of untrusted input, external or user-supplied" (or note the spec-term mapping). Not gate-blocking.

**F-2026-08-11-ecosystem-companions-003 | Nit | plan-conformance**
Plan R-122 final sentence: "R-102 already keeps sensitive paths out of it [EXPRESS]" is slightly overbroad — R-102 enumerates auth/payments/user-data/schema/public-API; `external-input` and `ui` are not in that list. The operative guarantee (EXPRESS has no plan → no change_surface → companions never fire) is stated in the same sentence and is sufficient on its own; trim or hedge the R-102 clause.

**F-2026-08-11-ecosystem-companions-004 | Nit | plan-conformance**
Plan Architecture table row "`/security-review` … NOT in adapter files despite spec §4.6's parenthetical" — correct (verified below), but the plan nowhere records this as a formal spec-correction note. One line in the Problem Statement ("spec §4.6's 'present in the Claude Code adapter' is inaccurate; the only occurrence is prompts/reviewer.md:24, which T8/T9 fix and wire") would make the correction auditable.

## Verification Log

Machine evidence (R-110): PLAN_REVIEW — no code diff; ladder N/A. Deterministic checks run directly instead:

| Item | Method | Result | Evidence |
|---|---|---|---|
| `/security-review` NOT in adapters (planner claim 1) | `grep -rn "security-review" adapters/ prompts/ protocol/ COMPANIONS.md README.md` | CONFIRMED — sole hit is `prompts/reviewer.md:24`; zero hits under `adapters/` | grep output |
| `prompts/reviewer.md:24` ungated (planner claim 2) | Read lines 1–30 | CONFIRMED — "if a security-scanning tool … is available … run it": availability-gated only, no change-type gate. T8's rewrite target is real | file text |
| Rule numbering starts R-119, no collision | `grep -rhoE "R-1[0-9]{2}"` across protocol/, templates/, prompts/, adapters/, config, sorted | CONFIRMED — highest existing rule R-118; R-119–R-122 free | grep output |
| Spec conformance G1–G7 → FR/task/AC map | Cross-read spec §2/§8 vs plan FR-1..10, T1–T12, AC-F-01..09 + AC-N-01..05 | COMPLETE — G1→AC-F-02/03, G2→AC-F-01, G3→AC-F-06, G4→AC-F-07, G5→AC-F-04/05, G6→AC-F-08, G7→AC-N-04/05; spec §8.1–8.8 each cited by ID in the AC table; §8.7 zero-companion → AC-F-09 | both documents |
| §3 locked decisions honored | Text comparison, R-119/R-120/R-121 exact text vs spec §3 | EXACT — Strix opt-in + lazy + up/down recorded + triple-gate (config AND surface∩{auth,payments,external-input,new-endpoint} AND FULL) + never-routine + disabled default incl. absent key; floor auto-when-detected R-99 parity; gates BOUND not recreated ("This section does not amend R-110"); gitleaks hit = Blocker at FINAL with R-9 waiver (R-9 verified at core.md:130); no E/F/G/H leak | plan lines 39–79 vs spec §3–§4 |
| Cited anchors exist post-A/B/C | Read/grep core.md (R-110:89, R-118:248 — amendment 1 before-text "(build/drift, tests, SAST, mutation per R-110)" matches verbatim; §0.5 rigor table:82; shard-map core row:21 matches amendment 3 before-text verbatim; §6.2:300/§6.4:310; R-102:76), planner.md (§6.1:85, R-99:104, v4 sast/mutation note:106, §4.1:65, Appendix C:157 incl `secret-management`:171), reviewer.md (§4.4:48, ladder sentence:52, R-111:36, R-112:38), final-reviewer.md (§4.7:7, R-44:9, v4 note:13), orchestrator.md (§9.1:53, §9.2:68), history.md (F.1:32) | ALL REAL — every surgical amendment's before-text located exactly | file reads |
| Template/config targets | Read run-record.yaml (tooling_resolutions:26 — insertion point real), findings-ledger.yaml (rung comment `tests \| sast \| mutation`:10), planning-document.md (Tooling Declaration:78, 4-column table matches added rows), heatwave.config.example.yaml (`tooling.sast`/`tooling.mutation` present as claimed) | ALL MATCH | file reads |
| T9 target `adapters/claude-code/.claude/agents/heatwave-reviewer.md` | `find adapters -type f` | EXISTS (hidden dir; 6 lines) | find output |
| Adapter-consistency baseline | `grep -rn -i "semgrep\|gitleaks\|strix\|playwright\|context7\|mutation\|companion" adapters/ prompts/ README.md` | Only reviewer.md:24 (fixed by T8), neutral detection lists, and README COMPANIONS pointers — no adapter contradicts R-120; T9's "expected residual hits" claim accurate | grep output |
| Identity constraint (zero new runtime deps) | Task audit T1–T12: every edit is to existing text files; installs are test-time, scratchpad/brew-side; no vendoring; install.sh untouched; AC-N-03 diff audit + AC-N-05 conditionality audit enforce it | HOLDS — every companion detected+degradable, nothing required, nothing always-on token-costing (NFR-2, R-120 class scheme) | plan text |
| Gating both directions + ordering | R-119 enumerates all three failure legs with distinct recorded markers; AC-F-04 (disabled default, live, `docker ps`) + AC-F-05 (enabled±gate) cover both directions; T10 explicitly BEFORE T11 installs with `command -v` check + PATH-strip backup | SOUND | plan T10–T12 |
| Verification honesty (R-64) | Tooling Declaration: Strix real binary declared NOT AVAILABLE with affected AC + stub/rule-text mitigation; Playwright unknown-until-probed, declared either way; brew/pipx installs "expected" with R-64 fallback | HONEST — matches B's accepted pattern and spec §8.3's parenthetical | plan declaration table |
| build-protocol.sh drift mechanics | Read script | T1–T4 (the only shard-touching tasks, history.md included in ORDER) each end regenerate+`--check`; T5–T9 touch non-shard files correctly exempt | script + task list |

Not verified:

| Item | Reason | Criteria affected |
|---|---|---|
| Live behavior of the T10–T12 scratch runs | PLAN_REVIEW — execution evidence is produced at implementation and judged at FULL/FINAL | AC-F-01..09 (methods judged concrete and executable; results pending) |
| Strix repo/license authenticity (usestrix/strix) | Not probed at plan review; plan's T7 contract (verify-before-list, else explicit re-verify flag) is the honest handling | COMPANIONS.md entry accuracy — reviewer will check at FULL |
| context7 MCP availability inside dispatched planner subagents (vs this environment) | Declared "confirmed — present in this environment"; subagent inheritance unproven until T12 | AC-F-07 positive path — plan already routes miss to R-64 declaration |

## Summary

Adversarial ground-truthing against the post-A/B/C tree confirms this plan is unusually well-anchored: every one of the seven surgical amendments quotes before-text that exists verbatim at the cited location, the new rules slot into a verified R-119 gap, and both of the planner's spec-correction claims are true — `/security-review` appears nowhere in `adapters/` (the spec §4.6 parenthetical is wrong) and `prompts/reviewer.md:24` is indeed an availability-gated-only instruction that T8 correctly rewrites. The locked decisions are honored to the letter: Strix's triple gate is stated with the absent-key-means-disabled default and both skip directions distinctly recorded; the deterministic floor is R-99-parity auto-when-detected; B's `sast`/`mutation` gates are bound, not recreated, with an explicit R-110 reconciliation sentence. The identity constraint holds — text-only edits, test-time installs outside the repo, AC-N-03/05 audits — and companion output routes through R-112 refute-or-promote. Verification is honest in the B pattern: real gitleaks/semgrep/mutmut, declared stubs for Strix, probe-and-declare for Playwright, and the T10-before-T11 ordering closes the detection-contamination hole the plan itself identified. The four findings are cosmetic-to-small: an overclaimed "exactly" on a table that was in fact (sensibly) normalized, an undeclared input-handling→external-input vocabulary mapping worth one defining clause, an overbroad R-102 aside, and a missing formal note of the spec correction. None blocks; all are one-line fixes the implementer can fold into T1/T2 text, and FULL_REVIEW should confirm them. Zero Blockers, zero Majors: gate met.

**Verdict: APPROVED — proceed to IMPLEMENTING. Findings 001–004 (2 Minor, 2 Nit) to be folded in during implementation and reconciled at FULL_REVIEW.**
