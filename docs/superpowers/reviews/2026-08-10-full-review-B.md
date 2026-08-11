# Review Report

task_id: hw-v4-B-machine-evidence | artifact_type: review-report | iteration: 1 | review_type: FULL_REVIEW | produced_by: REVIEWER (claude-fable-5, fresh context) | timestamp: 2026-08-11

## Verdict

GATE_MET
Blockers: 0 open | Majors: 0 open | Minor: 2 | Nit: 2

## Scope Evaluated

Plan scope §5.1 as declared: plan-conformance, verification-integrity, data-integrity. All other categories N/A per the plan's Review Scope (docs/templates repo, no runtime surface) — N/A reasons re-checked and hold: the only executable (`build-protocol.sh`) is byte-identical to main (verified: `git diff --quiet main...HEAD -- build-protocol.sh` → exit 0).

## Scope Changes

None. No surface the plan did not anticipate was found in the diff (17 repo files + 4 docs-trail files, all named by the plan's task list).

## Reconciliation

PLAN_REVIEW iteration 2 left two dispositions to carry:

| Finding ID | Prior status | Current status | Change reason |
|---|---|---|---|
| F-hwB-011 (Minor, deferred with "MUST be reconciled at FULL_REVIEW") | Deferred (approved) | Fixed | The one-clause R-31 carve-out landed exactly as the deferral prescribed: `protocol/fixer.md:21` now ends "Findings with `status: refuted` (R-112) require no response." Verified by grep this review. The optional `prompts/fixer.md` companion edit was not taken — see F-hwB-016 (Nit). Disclosed in the package (Files Changed, T2 row) rather than as a formal Deviation Record block; substance directed by PLAN_REVIEW, so no self-approval occurred. |
| F-hwB-012 (Nit, plan response-block grep claim) | Open (Nit) | Closed — no artifact impact | Confirmed the inaccurate claim lives only in the plan document's response block; no shard/template/prompt echoes it (repo grep). |

Late findings: F-hwB-013..016 below are new in this review (first review of the implementation — not late per R-60).

## Acceptance Status

(Not required at FULL_REVIEW; recorded because every AC was re-verified this review.)

| AC ID | Status | Evidence |
|---|---|---|
| AC-F-01 | Satisfied | (a) L3 ledger `machine_evidence` carries tests+sast pass verdicts recorded above the findings block, both REVIEWER-executed per evidence_ref; (b) N2 ledger `rung: sast, verdict: NOT_AVAILABLE` with probe evidence. `unverified_acs: []` in N2 is an honest-empty — dispositioned acceptable, see Variance (c). Transcript-order limitation honestly declared (R-64); the deterministic component (ledger structure + verification logs) verified by me. |
| AC-F-02 | Satisfied | L4 ledger F-l4-report-002: `origin: machine, rung: mutation`, problem "(tests inadequate for report.sh)", default Major — read directly from `/private/tmp/hw-b-verify/l4/.heatwave/runs/l4-report/04-findings-1.yaml`. |
| AC-F-03 | Satisfied | (a) F-l4-report-002 `status: refuted` with substantive refutation (mutant re-applied to scratch, suite killed it, tool cited nonexistent line 6 of a 4-line file); absent from 05-fix-report.md responses, R-31 carve-out cited verbatim. Second organic refutation: F-n2-shout-001 refuted by execution. (b) F-l4-report-001 (machine Blocker, failing test) refutation-attempted (baseline HEAD^ PASS → attributable), promoted `status: open`, answered in the fix report. (c) I re-ran the awk sweep across all battery ledgers: 4 "refutation present", 0 "EMPTY REFUTATION". Reconciliation-path refutation (N3 proper) not exercised — see F-hwB-014 (Minor). |
| AC-F-04 | Satisfied | (a) L2 package lines 71/79: `FAIL: expected 6, got 3` (pre-fix) then `PASS: sum 1..3 = 6`. (b) N1 ledger: exactly one open Major, `category: verification-integrity`, with a genuinely rigorous three-way refutation attempt; verdict GATE_NOT_MET. |
| AC-F-05 | Satisfied | (a) L2 final record `hetero_reviewer: "false (self-preference bias not mitigated)"`; both pre-review snapshots grep-count 0 for the field; in the final record the line sits after the IMPLEMENTING→FULL_REVIEW transition (append order proves timing — though the literal mid-list append malforms the YAML, F-hwB-013). (b) H1: `roles.reviewer.resolved: claude-opus-4-8` ≠ implementer, `hetero_reviewer: "true"`, both review artifacts `produced_by: REVIEWER (claude-opus-4-8)` — model switching was available, no R-64 degradation needed. |
| AC-F-06 | Satisfied | Re-grepped all four run dirs myself: L1 zero ladder/machine_evidence mentions; L2 rungs {tests}; L3 {tests, sast}; L4 {tests, sast, mutation}. |
| AC-F-07 | Satisfied | L1 run dir is exactly the two EXPRESS artifacts + records, APPROVED. L3 `state: APPROVED` through the full chain; its FINAL_REVIEW ledger re-ran tests and carried sast forward naming the prior evidence_ref with diff-empty eligibility evidence (D-7 exercised). Drift check on final tree run by me: `OK: PROTOCOL.md matches protocol/ shards`, exit 0. |
| AC-F-08 | Satisfied | Sweeps re-run by me: adapters/README/COMPANIONS/faq/install.sh grep → 0 hits; 8 adapter shims carry only compatible invariants; rule-definition grep → R-110/111/112/114/115 exactly once each, R-113 exactly three named halves; status-enum sweep → 3 sites, all correct (Appendix A continues `Disputed | Refuted`; R-77 lists Refuted; R-6 is prose; fix-report `Response:` is a different enum). |
| AC-F-09 | Satisfied | Re-run by me: `grep -c "R-11{0,1,2,4,5}\." PROTOCOL.md` → 1 each; `grep -c "R-113 (" PROTOCOL.md` → 3; Appendix A section contains `Refuted` (count 1); generated-file header intact. |
| AC-N-01 | Satisfied | `git diff --name-only main...HEAD` → 17 pre-existing .md/.yaml + 4 new docs-trail files only; `--summary` shows no mode changes and no created files outside docs/; build-protocol.sh byte-identical. |
| AC-N-02 | Satisfied | `git diff --quiet main...HEAD -- prompts/express-checker.md templates/express-change.md templates/express-check.md` → exit 0; grep of those three files for ladder/machine_evidence/refut/mutation/change_class/hetero → 0 in each; L1 artifact set identical to A's. |
| AC-N-03 | Satisfied | resume-check record: 0 hits for `change_class|hetero_reviewer`; post-resume diff is one appended transition line, nothing rewritten. (The appended transition duplicates an existing one — harness noise, F-hwB-015 Nit.) |

## Variance Dispositions (R-5/R-6 — the three flagged by the implementer)

- **(a) L4 as controlled dispatch, not full live FULL run — ACCEPTED, no finding.** The plan's own Risks row designates controlled dispatches as the nondeterminism fallback; the states that carry L4's ACs (FULL_REVIEW, FIXING) ran as live role contexts against R-3-legal fixtures, and every AC-F-02/03 check binds to artifacts those live contexts produced. Residual gap (no fully-live FULL-tier PLANNING→APPROVED run) is real but covered by L3's live end-to-end plus L4's live review/fix states; disclosed honestly as a deviation note rather than self-approved.
- **(b) N3 skip — MINOR (F-hwB-014).** Refutation-at-authorship is proven twice organically, but the plan's skip condition ("if L4's bait draws a candidate Major organically") was met in spirit, not letter — the bait drew nothing; the refutations came from the mutation rung and N2. The distinct N3 branch — R-58 reconciliation forcing refutation of a *prior-iteration* seeded open Major — has no evidence. Non-gating; log for the backlog.
- **(c) AC-F-01b honest-empty `unverified_acs: []` — ACCEPTED, no finding.** R-110's shipped text requires naming "the acceptance criteria it leaves unverified"; when no declared AC depends on the rung, the truthful value of that set is empty. The entry still records the probe evidence, the R-64 gap narration, and the compensating manual read — the degradation contract (never-silent) is fully exercised. Inventing an AC to satisfy the criterion's literal wording would have been the dishonest path.

## Findings

Canonical detail below (no separate NN-findings ledger exists for this docs-repo meta-run; this section is the finding record).

```
Finding ID:           F-hwB-013
Severity:             Minor
Category:             data-integrity
Origin:               reviewer
Location:             protocol/core.md:154 (R-115 "recomputes and appends the updated value") and templates/run-record.yaml:17 (`hetero_reviewer` as a single top-level key); exhibited in /private/tmp/hw-b-verify/l2/.../run-record.yaml:22
Problem:              R-115's "append" semantics collide with the record's YAML shape. The battery driver literally appended the hetero line mid-file: in L2's final record `hetero_reviewer:` sits at column 0 BETWEEN two `transitions:` list items, which is structurally invalid YAML (the following `- {...}` item is orphaned). And on an R-11 substitution, "appends the updated value" for a scalar top-level key means a duplicate key — also invalid per YAML spec (most parsers last-wins silently).
Why it matters:       Any tooling that ever parses run-records strictly will choke on records produced by a driver following R-115 literally. Today's consumers are LLM drivers reading text, so nothing breaks — hence Minor, not Major.
Recommended fix:      One-clause wording tweak in a later run: the driver SETS the template's `hetero_reviewer` field (or appends a dated advisory line as a YAML comment / transitions-style entry); timing evidence comes from record snapshots (which L2 already demonstrates), not from mid-list insertion.
Verification method:  grep the amended R-115 for set-not-append wording; produce one record with a recomputed value and parse it with any YAML parser.
Refutation:           Attempted: is L2's record actually valid? No — a top-level scalar key between sequence items under `transitions:` cannot parse (inspection; no yaml module in this env to machine-confirm, stated per R-64). Is the shipped rule text itself clean of the problem? No — "appends the updated value" is in R-115 verbatim. Not refutable as written — but consequence today is nil, so Minor stands.
Introduced in:        1
Status:               Open
```

```
Finding ID:           F-hwB-014
Severity:             Minor
Category:             verification-integrity
Origin:               reviewer
Location:             Implementation Package, Deviation note 2 (N3 skip); plan T11 N3
Problem:              The R-58 reconciliation channel for refutation — a reviewer handed a prior-iteration ledger containing a seeded open Major and refuting it during reconciliation — was never exercised. The plan's stated skip condition (L4's bait drawing an organic candidate Major) did not occur; the two organic refutations happened at first authorship, a different moment in the finding lifecycle.
Why it matters:       "Refute during reconciliation" is the path a false positive from a PREVIOUS review takes; it touches R-58/R-59 interplay that authorship-time refutation does not. If it misbehaves, a stale false-positive Major keeps gating until someone notices. Both directions of R-112 at authorship are proven, so the residual risk is narrow — Minor.
Recommended fix:      Backlog item: one controlled reviewer dispatch per the original N3 recipe (seeded prior ledger with a demonstrably guarded "bug"), attach ledger showing status: refuted at reconciliation. Can ride any future B-follow-up or D run.
Verification method:  The N3 recipe's own checks: reconciliation table addresses the seeded finding; ledger status refuted; absent from fix cycles.
Refutation:           Attempted: do the organic refutations cover the same mechanism? Partially — R-112's refutation logic is identical, but the R-58 trigger context (prior open finding, reconciliation obligation) is untested. Not fully refutable; Minor stands. Deferral to backlog is REVIEWER-approved (R-6/R-78).
Introduced in:        1
Status:               Deferred (approved)
```

```
Finding ID:           F-hwB-015
Severity:             Nit
Category:             verification-integrity
Origin:               reviewer
Location:             /private/tmp/hw-b-verify/resume-check/run-record.yaml:21-22
Problem:              The resume-compat check's appended transition duplicates the already-present FULL_REVIEW→FINAL_REVIEW entry (same from/to/artifact, new timestamp) instead of advancing from the resumed state.
Why it matters:       Harness noise only; AC-N-03's substance (no error, no rewrite, append-only) is proven regardless. A duplicate transition row in a real run would be cosmetic.
Recommended fix:      None required; note for future battery recipes.
Verification method:  n/a
Refutation:           n/a — Nit (R-112 exempt)
Introduced in:        1
Status:               Open
```

```
Finding ID:           F-hwB-016
Severity:             Nit
Category:             internal-consistency
Origin:               reviewer
Location:             prompts/fixer.md:7
Problem:              The prompt bullet still reads "Every finding gets exactly one response (R-31, R-40)" without the refuted carve-out. F-hwB-011's fix listed the prompts/fixer.md companion edit as optional; it was not taken.
Why it matters:       The shard the FIXING dispatch loads (protocol/fixer.md R-31) carries the carve-out, and the live L4 fixer applied it correctly — worst case remains a harmless surplus response. Nit.
Recommended fix:      Append "(refuted findings excepted, R-31/R-112)" to the bullet in any future prompt-touching run.
Verification method:  grep prompts/fixer.md for the exception.
Refutation:           n/a — Nit (R-112 exempt)
Introduced in:        1
Status:               Open
```

## Verification Log

Machine evidence (R-110): no ladder rungs apply to this meta-review in the usual sense (docs repo, no declared test framework); the plan's declared deterministic tooling was executed in full by me, ladder-style, before any finding was authored:

| Item | Method | Result | Evidence |
|---|---|---|---|
| Drift check, final tree | `sh build-protocol.sh && sh build-protocol.sh --check` (run by me) | PASS | `generated PROTOCOL.md from protocol/ shards` / `OK: PROTOCOL.md matches protocol/ shards`, exit 0; regeneration left the tree clean (`git status --porcelain` empty) |
| Injected-drift negative | appended a junk line to PROTOCOL.md, re-ran `--check`, restored | PASS | `DRIFT: PROTOCOL.md differs from protocol/ shards`, exit 1; after restore: OK, exit 0 |
| A regression: EXPRESS surface | byte-diff vs main + ladder-vocabulary grep of the three EXPRESS files | PASS | exit 0 on `git diff --quiet`; 0 grep hits in each file |
| A regression: dispatch line counts (A's AC-N-01) | `wc -l` | PASS | core+implementer = 445 ≤ 450; largest review row core+reviewer = 507 < 974 |
| Rule presence/uniqueness | greps on PROTOCOL.md and shards (AC-F-09, T10 check 4) | PASS | R-110/111/112/114/115 defined exactly once each (bold-definition grep); R-113 exactly three named halves; PROTOCOL.md counts 1/1/1/1/1 and 3 |
| Status-enum consistency (F-hwB-001 class) | `grep -rn "Disputed|disputed" protocol/ templates/ prompts/` + read each hit | PASS | Every status enumeration carries Refuted/refuted (Appendix A reviewer.md:146-147, core.md R-77:310, findings-ledger.yaml:29); fixer/fix-report `Response:` enums are response enums, correctly untouched |
| R-77 exclusion + fixer carve-out | read core.md:310, fixer.md:21 | PASS | Refuted excluded from "open"; refuted findings need no FIXER response |
| Diff fidelity to plan's normative text | read the full main...HEAD diff of protocol/, templates/, prompts/, config | PASS | Every insertion matches the plan's verbatim rule text; tier table matches spec §3 exactly (EXPRESS none / LIGHT tests / STANDARD +SAST / FULL +mutation); R-113 binds to change_class: bugfix in all three halves; R-115 computes only once BOTH roles resolved; ponytail held (extend-in-place, no restructuring) |
| AC-N-01/02 audits | diff-name, --summary, byte checks (run by me) | PASS | see Acceptance Status |
| Live-battery evidence bundle | read ledgers, run-records, snapshots, fix report under /private/tmp/hw-b-verify/ | PASS | all package quotes match the on-disk artifacts verbatim (L2 red/green, L4 refuted+promoted, N1 Major, N2 NOT_AVAILABLE, H1 opus provenance, L3 D-7 carry-forward, tier-scaling greps, refutation sweep 4/0) |
| T10 repo sweeps | re-ran both greps over adapters/ etc. | PASS | 0 hits; 8 shims, no contradictions |

Not verified:

| Item | Reason | Criteria affected |
|---|---|---|
| YAML machine-parse of L2/H1 run-records | no `yaml` module in this environment; structural judgment by inspection | none gating — informs F-hwB-013 only |
| Subagent internal transcript ordering (rungs-before-findings) | transcripts not attachable, as the package honestly declares (R-64) | AC-F-01's ordering component rests on ledger structure + verification logs — accepted as the available evidence |
| H1 reviewer model identity beyond artifact self-report | no cryptographic model attestation exists | AC-F-05b — artifacts + run-record are mutually consistent; accepted |

## Summary

Sub-project B is implemented faithfully to the approved plan: every rule (R-110–R-115) landed verbatim in the planned shard locations, the tier-rigor table matches the spec's locked table exactly, the Status-enum extension is consistent at every site that enumerates statuses, refuted findings are excluded from both R-77 and the FIXER's R-31 obligation, reproduce-then-fix binds to `change_class: bugfix` in all three halves, and the hetero advisory computes only once both roles resolve. I re-ran every deterministic check myself rather than trusting pasted output — drift check (positive and injected-negative), all AC-F-08/09 greps, the A-regression byte and line-count checks, and the AC-N audits — and all passed. The live-battery evidence bundle on disk matches the package's quotes exactly, including both refute-or-promote directions, red-then-green both ways, all four tier-scaling profiles, and a genuinely live Opus-reviewer H1. The implementer flagged its three variances instead of self-approving — correctly. Dispositions: (a) accepted, (c) accepted, (b) a non-gating Minor. Four findings total: two Minors (R-115 append-semantics vs YAML validity; unexercised reconciliation-path refutation, deferred to backlog with approval) and two Nits. Zero Blockers, zero Majors: GATE_MET.
