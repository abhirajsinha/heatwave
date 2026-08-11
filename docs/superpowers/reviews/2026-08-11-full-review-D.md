# Review Report

task_id: 2026-08-11-ecosystem-companions | artifact_type: review-report | iteration: 1 | review_type: FULL_REVIEW | produced_by: REVIEWER (claude-fable-5, fresh context) | timestamp: 2026-08-11

## Verdict

GATE_MET
Blockers: 0 open | Majors: 0 open | Minor: 1 | Nit: 1

## Scope Evaluated

Plan's declared scope: plan-conformance, verification-integrity, secure-config, secret-management, over-engineering. Identity constraint (zero new runtime dependencies) evaluated as CRITICAL per dispatch. Real diff read in full: `git diff main...heatwave-v4-subproject-d` (21 files, +762/−13; the non-docs surface is 6 shards + PROTOCOL.md + 3 templates + config + COMPANIONS.md + 3 prompts + 2 adapter files).

## Scope Changes

None.

## Reconciliation

Iteration 1 of FULL_REVIEW — no prior FULL findings. PLAN_REVIEW residuals F-001–F-004 (reviewer-directed folds):

| Finding ID | Prior status | Current status | Change reason |
|---|---|---|---|
| F-…-001 (Minor, FR-7 "exactly") | to fold | **Closed** | Plan FR-7 now reads "reproduced … in the change_surface vocabulary, with the FINAL-presence precision for gitleaks" — verified in plan text |
| F-…-002 (Minor, external-input term) | to fold | **Closed** | R-122 as shipped carries the defining clause "`external-input` means any handling of untrusted input — external, user-supplied, or crossing a service or trust boundary — the input-handling class" (protocol/planner.md:112); echoed in prompts/planner.md:15 |
| F-…-003 (Nit, R-102 aside) | to fold | **Closed** | R-122 final sentence is now "EXPRESS runs have no plan and no change surface; companions never fire on EXPRESS" — R-102 aside dropped |
| F-…-004 (Nit, spec-correction note) | to fold | **Closed** | Plan Problem Statement carries the spec §4.6 correction note |

Late findings: None.

## Acceptance Status

(Not required at FULL_REVIEW; recorded because this run's substance is its verification evidence.)

| AC | Status | Evidence |
|---|---|---|
| AC-F-01 | Satisfied | `hw-d-floor/…/gh-config/05-findings-final.yaml`: rung `secrets` verdict fail ("leaks found: 2", rule github-pat), finding F-gh-config-001 severity Blocker, category secret-management, origin machine, run blocked (ESCALATED pending OWNER waiver — the R-9 path R-121 names). Reviewer re-ran the class of demo independently: fresh scratch repo + planted `ghp_…` → gitleaks `leaks found: 1` |
| AC-F-02 | Satisfied | gh-config FULL ledger: `sast | semgrep scan --config auto … | pass | 290 rules, 2 targets, 0 findings`, reviewer-executed; semgrep 1.172.0 confirmed on PATH by this reviewer |
| AC-F-03 | Satisfied | add-normalize ledger: mutmut fail, 6 survivors, 4 on changed lines → Majors; refutation of 2 baseline survivors via pre-change-SHA re-run (R-112) |
| AC-F-04 | Satisfied | hw-d-strix add-auth-check original leg + hw-d-clean: `companions.strix: skipped-disabled` with legs (b)/(c) held, leg (a) failed; docker ps unchanged |
| AC-F-05 | Satisfied (evidence-location caveat = F-005) | Positive leg: ledger `dynamic` rung — docker up 08:04:56Z, stub scan 08:05:14Z (invocation log exactly 1 line, re-counted), down 08:05:23Z, container gone (re-verified: `docker ps` today shows only the pre-existing unrelated learn-os-db-1). Negative leg: `strix: skipped-out-of-gate` in add-power run-record, log still 1 line. Real Strix honestly NOT AVAILABLE (R-64) |
| AC-F-06 | Satisfied | Positive path LIVE: `status-page/04-ui-evidence-status-page.png` (PNG 1200×585 on disk, re-checked with `file`); report cites a11y assertions per-AC; `file:`-URL substitution logged. Negative path: live NOT-AVAILABLE declarations in T10/T11 plans |
| AC-F-07 | Satisfied | fetch-release plan: 2 lookups for 2 distinct cited APIs, each labeled Fact with content; add-power plan: "present — not used". "Exactly one per cited API" reinterpretation is disclosed and reasonable — the gated property (never always-on, zero speculative) is what the spec §8.5 protects |
| AC-F-08 | Satisfied per its own letter | See disposition in Verification Log |
| AC-F-09 | Satisfied | add-power ledger: `sast` NOT_AVAILABLE with reviewer re-probe evidence; run APPROVED (05-review-report-final.md present); run-record `companions.detected: []` |
| AC-N-01 | Satisfied | Re-run by this reviewer: `OK: PROTOCOL.md matches protocol/ shards`, exit 0; injected-drift negative re-run: exit 1 with DRIFT message, then restored to exit 0 |
| AC-N-02 | Satisfied | Re-grepped: zero companion terms in express-checker.md / express-change.md / express-check.md / implementer.md; `git diff main...HEAD` on all EXPRESS/implementer files = 0 lines; live EXPRESS run evidence in package |
| AC-N-03 | Satisfied | Re-run: `git diff main...HEAD --numstat` binary markers = 0; install.sh delta = 0; 21 files all existing text files + docs |
| AC-N-04 | Satisfied | Re-grepped (60 hits): every prompts/adapters hit carrying a token-costing instruction is gated (change_surface/iff/R-119); formerly ungated prompts/reviewer.md:24 now opens with the change_surface condition |
| AC-N-05 | Satisfied | Re-counted: core.md added lines = 24 (≤ 90); conditionality audit of reviewer.md §4.4 / planner.md §4.1 / prompts confirms iff/when/MAY on every class-2/3 instruction |

## Findings

**F-2026-08-11-ecosystem-companions-005 | Minor | verification-integrity**
Implementation Package AC-F-05 bullet ("run record `strix: run` + both timestamps") vs `scratchpad/hw-d-strix/.heatwave/runs/add-auth-check/run-record.yaml:29–31`, which reads `strix: skipped-disabled` with both timestamps empty. The up/down markers exist only inside `04-review-report-1.md:56` and the ledger as *instructions to the driver*; no driver applied them, so the orchestrator §9.1 *(v4-D)* copy-duty was never exercised live for a strix-ran case (it WAS exercised for gh-config's fired list and for the negative leg's `skipped-out-of-gate`). Failure scenario: an auditor reading the run record alone concludes the scan never ran — the exact ambiguity the markers exist to prevent. The substantive AC-F-05 evidence (triple gate both directions, Docker up/scan/down timestamps, 1-line invocation log, container gone) is real and reviewer-re-verified, so this is a package overstatement plus an unexercised bookkeeping duty, not a gating defect. Fix: correct the package sentence; optionally apply the driver update to the scratch record.

**F-2026-08-11-ecosystem-companions-006 | Nit | plan-conformance**
`hw-d-strix/…/04-review-report-1.md:56` instructs the driver to record `companions.strix: ran (stub, clean)` — not a member of the shipped enum `run | skipped-disabled | skipped-out-of-gate | NOT AVAILABLE` (templates/run-record.yaml:31). Exemplar evidence should model the schema exactly; annotate via `fired[]`/comment, keep `strix: run`.

## Verification Log

Machine evidence (R-110) — every rung re-executed by this reviewer, not trusted from the package:

| Rung/check | Method | Result | Evidence |
|---|---|---|---|
| build/drift | `sh build-protocol.sh --check` on the branch | **pass** | `OK: PROTOCOL.md matches protocol/ shards`, exit 0 |
| drift negative | append junk to PROTOCOL.md → `--check` → restore | **pass** | `DRIFT: PROTOCOL.md differs from protocol/ shards — run: sh build-protocol.sh`, exit 1; restored exit 0 |
| A: EXPRESS surface | grep companion terms in EXPRESS files + diff of EXPRESS/implementer files vs main | **pass** | 0 hits, 0 diff lines |
| A: core line budget | `git diff main...HEAD -- protocol/core.md \| grep "^+" \| … \| wc -l` | **pass** | 24 ≤ 90 |
| B: ladder/enum | grep rung enum + R-110..R-115 anchors | **pass** | enum now `tests \| sast \| mutation \| secrets \| dynamic`; R-110 text unchanged except the reconciled §6.5 intro; R-111/R-112 referenced by R-120, not redefined |
| C: tiering/session/delta | grep R-116/R-117/R-118 + `final_delta_range`/`review_session`/`stage_model` | **pass** | all anchors intact; R-118 amendment is exactly the "+; secrets per R-121" clause |
| D: consistency sweep | repo-wide companion grep (60 hits) + ungated-instruction filter | **pass** | zero ungated token-costing instructions |
| D: planted-secret demo | fresh scratch repo, committed `ghp_…`, `gitleaks git .` | **pass** | `leaks found: 1` (gitleaks 8.30.1) — the R-121 Blocker class reproduces deterministically |
| Identity: zero new deps | `--numstat` binary scan, install.sh diff, file-by-file diff read | **pass** | 0 binaries, 0 install.sh delta, all 21 files existing text files; every companion detected + NOT-AVAILABLE-degradable; nothing vendored, nothing mandatory, nothing always-on |
| Tool-claim sanity | `command -v` + versions | **pass** | gitleaks 8.30.1 / semgrep 1.172.0 / mutmut present, strix absent — exactly as the package declares |
| Strix COMPANIONS.md entry | GitHub API + raw README fetch | **pass** | usestrix/strix exists, license `Apache-2.0`, README line 82 = `curl -sSL https://strix.ai/install \| bash`, headless `strix -n --target` at README:244–252 — entry accurate |
| Docker hygiene | `docker ps` now | **pass** | only pre-existing unrelated `learn-os-db-1`; no hw-strix leftovers |
| Scratch artifacts exist | ls + reads of hw-d-clean (6 runs), hw-d-floor (2), hw-d-strix (2), ledgers, PNG, invocation log, run-records | **pass** | all present with content matching package quotes (one discrepancy → F-005) |

Correctness reading of the shipped text: R-119's triple gate cannot misfire on routine changes (conjunction of explicit opt-in config AND surface intersection AND FULL tier; all three failure legs have distinct recorded markers; enabled-but-missing-tool/Docker → NOT AVAILABLE; unset `strix_target` covered by plan edge case 9 via R-64); teardown is mandatory with up-without-down defined as a protocol defect. gitleaks Blocker carries the OWNER R-9 waiver path (R-9 verified at core.md:132). Semgrep/mutation feed B's existing rungs — §6.5 opens "This section does not amend R-110" and R-110's gate text is byte-identical except nothing; companion output routes through R-112 refute-or-promote with R-111 high-severity-only conversion. Floor detection is R-99-parity in planner.md §6.1. Blast radius declaration matches the diff exactly.

**AC-F-08 disposition:** the change-surface gate is now in the shard (reviewer.md §4.4), the rewritten prompt (prompts/reviewer.md:24 opens "when the plan's `change_surface` intersects …"), and the adapter (HEATWAVE.md dispatch note; the plan-review finding that `/security-review` was previously absent from adapters/ was true and is now fixed). Live: positive-surface run fired the gate and — the slash command being non-invocable inside dispatched subagent contexts — recorded the R-64 declaration + manual security-category substitute; none-surface run stayed silent. The AC's own letter anticipates exactly this ("or carries the R-64 declaration if unavailable to the dispatched context"), so AC-F-08 is **verified, not R-66-blocked**; the never-observed genuine slash invocation remains an honest, recorded R-64 limitation inherent to dispatched contexts, not an evidence gap in the deliverable (which is the gate text itself).

Not verified:

| Item | Reason | Criteria affected |
|---|---|---|
| Real Strix positive scan / PoC realism | Needs its own LLM credentials — R-64, matches plan's declared mitigation (stub + real Docker discipline + rule text) | AC-F-05 realism only; gating fully verified |
| Live `/security-review` invocation transcript | Slash commands unavailable in dispatched subagent contexts (R-64, recorded) | AC-F-08 invocation half — see disposition |
| Playwright-MCP positive path in THIS review context | Not re-executed by this reviewer; PNG + per-AC report citations accepted as evidence, PNG existence re-verified on disk | AC-F-06 (re-execution would add little over artifact verification) |

## Summary

Adversarial re-execution confirms the package: every deterministic claim I re-ran reproduced — drift green and its negative red, the 24-line core budget, zero-EXPRESS-surface, the B/C anchor greps, the consistency sweep, and a from-scratch planted-secret gitleaks run that fails exactly as R-121 mandates. The identity check is clean in the strongest sense: 21 modified text files, zero binaries, zero install.sh delta, and a shipped policy (R-120) whose every companion is detected, optional, and NOT-AVAILABLE-degradable — nothing became a dependency and nothing always-on costs tokens. The Strix triple gate is correctly conjunctive with all three skip legs distinctly recorded, and the live evidence covers both directions plus real Docker up/scan/down with no container left behind — I even verified the COMPANIONS.md install channel against the upstream README. The PLAN_REVIEW residuals are all genuinely folded, including the input-handling defining clause. The two findings are small: the package overstates where the strix positive-leg markers landed (they live in the review report/ledger as driver instructions; the scratch run record still says skipped-disabled — the one v4-D duty never exercised live), and the exemplar report uses a non-enum marker value. Neither weakens the shipped protocol text, whose gating both I and the live runs exercised. Zero Blockers, zero Majors: gate met.

**Verdict: GATE_MET — 0 Blockers, 0 Majors, 1 Minor (F-005), 1 Nit (F-006). Proceed to FINAL_REVIEW; F-005/F-006 to be addressed or dispositioned there.**
