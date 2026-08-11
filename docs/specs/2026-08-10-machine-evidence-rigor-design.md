# Design Spec — Machine-Evidence Rigor (Heatwave Protocol v4, Sub-project B)

- **Date:** 2026-08-10
- **Status:** Draft, awaiting owner review
- **Scope:** Sub-project B of the Heatwave v4 redesign. Builds on A (shard structure, tiers, EXPRESS).
- **Depends on:** A (APPROVED, merged to main). Uses the `protocol/` shards, the tier system (§0.5 + EXPRESS), and the tooling-declaration mechanism (§6.1).

---

## 1. Context & problem

Heatwave's rigor today rests on an LLM REVIEWER reading code and asserting findings. Research (docs/superpowers/ research passes, 2026-08) names four measured weaknesses:

1. **Same-model self-preference bias.** All roles run one model family; the reviewer under-critiques work in its own style. Isolation is contextual, not cognitive.
2. **Review is judge-prose, not machine evidence.** "Evidence over assertion" still ultimately trusts the reviewer's reading — no SAST, no mutation-adequacy, no mandated reproduce-then-fix. LLM-as-judge self-confidence is poorly calibrated.
3. **No refutation gate.** Findings go straight to severity → FIXING; false positives each cost a full fix round-trip (the dominant hidden cost).
4. **"Verified" for bug fixes is a claim.** Nothing forces a failing reproduction *before* the fix and a green re-run after.

## 2. Goals / non-goals

**Goals:**
- G1. **Machine-evidence ladder** run *before* the LLM reviewer opines: existing tests → SAST scan of the diff → mutation-adequacy on changed modules. Each is a machine verdict (pass/fail bit), near-zero LLM tokens. Tool-agnostic: the protocol demands the *check*, not a named tool.
- G2. **Refute-or-promote gate:** every Major+ finding must survive an explicit refutation attempt before it enters FIXING. Nits/Minors exempt (cost control).
- G3. **Reproduce-then-fix for bug-class changes:** a failing test/repro is captured *before* IMPLEMENTING and re-run green at review. Converts "verified" to a bit.
- G4. **Heterogeneous reviewer:** recommend + document a different model family for REVIEW states; run-record flags when reviewer model == implementer model so the gap is visible. Not mandated (zero-config must still work).
- G5. **Tier-scaled application** so cost stays proportional to risk.

**Non-goals (deferred):**
- Wiring specific tools — Semgrep, Strix, mutation runners, Playwright — is **sub-project D**. B defines tool-agnostic gates + the tooling-declaration entries; D supplies adapters.
- Model tiering / delta review / persistent sessions (C). Benchmark (E).

## 3. Locked decisions (from owner brainstorm)

- **Heterogeneous reviewer = recommend + configurable** (not required). Default stays the session model; strong recommendation + run-record visibility flag.
- **Rigor scales by tier:**

| Tier | Machine-evidence ladder | Refute-or-promote | Reproduce-then-fix (bugs) |
|---|---|---|---|
| EXPRESS | none (stays instant) | no | no |
| LIGHT | existing tests only | yes (Major+) | yes, for bug-class |
| STANDARD | + SAST scan of diff | yes | yes |
| FULL | + mutation adequacy on changed modules | yes | yes |

- **B/D boundary:** B is tool-agnostic. A ladder rung with no declared tool degrades to an explicit `NOT AVAILABLE` (R-64) with the acceptance criteria it leaves unverified — never a silent skip. D makes the rungs real.

## 4. Design

### 4.1 Machine-evidence ladder (new review sub-phase, `protocol/reviewer.md` + `core.md`)

Before the REVIEWER writes LLM findings in FULL_REVIEW, it runs the ladder for the run's tier and records each rung's verdict in the findings ledger as machine evidence:
1. **Tests** — the plan's declared test command(s) run; failures are machine-Blocker findings.
2. **SAST** (STANDARD+) — a static scan of the diff (tool per config/tooling declaration; e.g. a `sast:` entry). Non-empty high-severity output → machine findings.
3. **Mutation adequacy** (FULL) — mutation run on changed modules; surviving mutants on changed lines → a machine finding "tests inadequate for <file>", pointing the fixer at what to cover.
Each rung absent-of-tool → `NOT AVAILABLE` line naming the unverified ACs (R-64). The LLM reviewer then covers only what machines cannot (logic, design, plan-conformance) — smaller prose surface, lower verbosity-bias exposure.

### 4.2 Refute-or-promote gate (new, `protocol/reviewer.md`)

Each candidate finding of severity **Major or Blocker** must carry a `refutation` field: the reviewer (or a cheap second pass) explicitly attempts to refute it — "is this actually reachable / actually wrong / already handled?" A finding that cannot be refuted is *promoted* to the ledger and enters FIXING; one that is refuted is recorded `status: refuted` with the reason and does **not** cost a fix cycle. Minors/Nits skip this (not worth the tokens). Ledger schema (`templates/findings-ledger.yaml`) gains `refutation:` and the `refuted` status.

### 4.3 Reproduce-then-fix for bug-class changes (`protocol/planner.md`, `implementer.md`, `reviewer.md`)

When the task is a **bug fix** (planner classifies `change_class: bugfix` in the run-config/plan):
- The plan's acceptance criteria MUST include a **failing reproduction** (a test that fails on current code, demonstrating the bug).
- The IMPLEMENTER captures that failing test *first* (red), then fixes (green) — the evidence is the before/after run.
- The REVIEWER confirms the reproduction existed and now passes. A bug fix with no reproducing test is a Major (R-66 style: unverifiable claim).
- Non-bug changes are unaffected.

### 4.4 Heterogeneous reviewer (recommend + visible, `protocol/core.md` §1.4, config)

- `heatwave.config.example.yaml` gains a documented recommendation: set `roles.reviewer.preferred` to a *different model family* than the implementer for uncorrelated blind spots. Zero-config default is unchanged (session model).
- The driver records `reviewer_model` and `implementer_model` in the run-record; when equal, it appends a one-line advisory `hetero_reviewer: false (self-preference bias not mitigated)`. Visible, not blocking.

### 4.5 Tooling declaration additions (`protocol/planner.md` §6.1)

The planner's tooling detection gains two optional entries — `sast` and `mutation` — detected from the repo where possible (e.g. a `semgrep` config, a `stryker.conf`, `mutmut` in deps), else declared `NOT AVAILABLE` with the ACs that leaves unverified. Consistent with existing R-99/R-64.

## 5. Affected files (all within A's structure)

**Modified:**
- `protocol/core.md` — machine-evidence-ladder states/rules, tier-scaling table, hetero-reviewer visibility rule, new rule IDs (R-110+)
- `protocol/reviewer.md` — ladder execution, refute-or-promote, reproduce confirmation
- `protocol/planner.md` — reproduce-then-fix ACs for bugfix class, `sast`/`mutation` tooling entries, review-scope rows
- `protocol/implementer.md` — capture-failing-test-first for bugfix class
- `templates/findings-ledger.yaml` — `refutation`, `refuted` status, machine-evidence rungs
- `templates/planning-document.md` — bugfix reproduction AC, tier-rigor note
- `templates/run-record.yaml` — `change_class`, `reviewer_model`/`implementer_model`, `hetero_reviewer` advisory
- `heatwave.config.example.yaml` — hetero-reviewer recommendation, `sast`/`mutation` tooling keys
- `PROTOCOL.md` — regenerated via `build-protocol.sh` (drift-checked)
- adapters — only if any assert review behavior that the ladder changes (repo-wide grep, as A taught us)

**No new runtime dependencies.** Tools are external and optional (D wires them); B only references them through the existing tooling-declaration contract.

## 6. Alternatives considered

1. **Mandate heterogeneous reviewer.** Rejected by owner: breaks zero-config, forces a second API key. Recommend + visible instead.
2. **Run full ladder on every tier.** Rejected: mutation testing on every LIGHT change is slow; violates the token/speed goal. Tier-scaled.
3. **Refute every finding.** Rejected: refuting Nits/Minors wastes tokens; the false-positive cost lives in Major+ fix cycles. Major+ only.
4. **Bake specific tools into B.** Rejected: violates "any agent, no hard deps." B stays tool-agnostic; D wires tools.

## 7. Risks & mitigations

| Risk | Mitigation |
|---|---|
| Ladder tools absent → silent loss of rigor | `NOT AVAILABLE` (R-64) naming unverified ACs; never a silent skip |
| Mutation testing too slow on big modules | scope to changed modules/lines only; FULL tier only; declare timeout ceiling |
| Refute-or-promote lets a real bug get refuted away | refutation reason recorded in ledger + visible; reproduce-then-fix independently catches bug-class; FINAL_REVIEW still re-confirms ACs |
| change_class misdetected (bug vs feature) | planner justifies; reviewer may raise; a "fix" with no repro is a Major regardless |
| Regenerated PROTOCOL.md drift | build-protocol.sh drift self-check (from A) |

## 8. Verification strategy (evidence, not assertion)

Live adapter runs on scratch targets + deterministic self-checks:
1. **Ladder runs pre-LLM.** A STANDARD run shows tests+SAST verdicts recorded in the ledger before LLM findings. Absent SAST tool → explicit NOT AVAILABLE line. Evidence: ledger + transcript.
2. **Mutation on FULL.** A FULL run on a module with a weak test shows a surviving-mutant machine finding. Evidence: ledger entry.
3. **Refute-or-promote.** A seeded false-positive Major is refuted (status: refuted, reason recorded) and does NOT enter FIXING; a real Major is promoted. Evidence: ledger + no spurious fix cycle.
4. **Reproduce-then-fix.** A bugfix run without a failing reproduction is flagged Major; with one, the red→green run is the evidence. Evidence: AC + test output.
5. **Hetero-reviewer visibility.** A same-model run records `hetero_reviewer: false` advisory; a configured different-model run records the models. Evidence: run-record.
6. **Tier scaling.** EXPRESS/LIGHT runs do NOT invoke SAST/mutation; FULL does. Evidence: transcripts per tier.
7. **Regression + drift.** A full STANDARD feature still reaches APPROVED; build-protocol.sh drift check passes. Evidence: run-record + check output.
8. **Adapter consistency.** Repo-wide grep shows no adapter contradicts the new review behavior.

Unavailable tooling declared explicitly (R-64), never silently skipped.

## 9. Open questions

None blocking. Specific tool choices (which SAST, which mutation runner) are sub-project D.
