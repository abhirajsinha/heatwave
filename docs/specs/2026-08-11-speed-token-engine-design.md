# Design Spec — Speed / Token Engine (Heatwave Protocol v4, Sub-project C)

- **Date:** 2026-08-11
- **Status:** Draft, awaiting owner review
- **Scope:** Sub-project C of the Heatwave v4 redesign.
- **Depends on:** A (shards, tiers, EXPRESS, cache-friendly dispatch ordering) and B (machine-evidence ladder, findings ledger) — both merged to main.

---

## 1. Context & problem

A slimmed the per-role context; B added machine evidence. What remains is the *dispatch economics*: every stage still runs the frontier model, every review stage spawns a cold context that re-reads everything, and FINAL_REVIEW re-covers ground already reviewed. Research (docs/superpowers/ research passes) shows three proven, un-taken savings:

1. **No model tiering.** 40–60% of stage work (mechanical checks, tiny re-reviews, summarization) doesn't need a frontier model; routing them to a cheap model behind the *same gate* cuts 85%+ of those stages' cost at ~95% quality (RouteLLM / Triage).
2. **Cold review spawns forfeit prompt caching.** Re-spawning a fresh reviewer for FULL→TARGETED→FINAL re-reads the stable prefix each time; a persistent session reuses cache (41–80% measured).
3. **Full re-review at FINAL.** FINAL re-reads unchanged files; commercial reviewers verify only the delta since the last verdict + re-run machine gates.

## 2. Goals / non-goals

**Goals:**
- G1. **Stage model-tiering:** a config-driven map routes mechanical stages to a cheap model, keeps the frontier model for stages where rigor matters. Zero-config default unchanged (session model everywhere).
- G2. **Persistent reviewer session:** one reviewer context lives across a single task's FULL→TARGETED→FINAL reviews (warm cache, retained finding memory), degrading to fresh context where the tool can't persist.
- G3. **Delta-only FINAL_REVIEW:** FINAL verifies fix-ledger closure + re-runs machine gates + reviews only the delta since the last FULL_REVIEW — never re-reads unchanged files — while still re-confirming every AC.
- G4. Everything measurable: run-record records the model tier used per stage and the review-session mode, so the savings are visible.

**Non-goals (deferred):**
- Wiring real tools (Semgrep/Strix/etc.) — D.
- Benchmark (E), positioning (F), multi-repo (G), CLI (H).
- Changing what any gate *requires* — C changes *how cheaply* the same gates run, never the gates themselves.

## 3. Locked decisions (owner brainstorm)

- **Model tiering = cheap for MECHANICAL ONLY.** Cheap model permitted for: EXPRESS check, artifact summarization, PLAN_REVIEW of EXPRESS/LIGHT tiers, and TARGETED_REVIEW of a small delta. **Frontier model always for:** FULL_REVIEW, FINAL_REVIEW, and any PLAN_REVIEW/review of STANDARD or FULL tier. All config-overridable.
- **Persistent reviewer session = persist across a task's FULL→TARGETED→FINAL.** Isolation is preserved (the reviewer never authored the code — R-1/R-2 untouched). **Safety rule:** FINAL_REVIEW, even in a persistent session, MUST re-run all machine evidence from scratch and re-confirm every AC independently — persistence never lets a prior verdict stand unre-checked. Config flag `fresh_final_reviewer: true` forces a cold FINAL context for those who want fully independent final eyes.

## 4. Design

### 4.1 Stage model-tiering (`protocol/core.md` §1.4 + `orchestrator.md`, config)

- `heatwave.config.example.yaml` gains an optional `cheap_model` and a `stage_models` map. Default: unset → every stage uses the session model (today's behavior, zero-config intact).
- The driver, when dispatching a stage, selects the model: if the stage is in the cheap-eligible set **and** a `cheap_model` is configured, use it; else the role's configured/preferred model; else session model.
- **Cheap-eligible set (fixed by rule, config may narrow, never widen into frontier-required stages):** EXPRESS_CHECK, artifact summarization, PLAN_REVIEW when tier ∈ {EXPRESS, LIGHT}, TARGETED_REVIEW when the delta is ≤ a configured small-diff threshold.
- **Frontier-required stages (rule, config MUST NOT downgrade):** FULL_REVIEW, FINAL_REVIEW, PLAN_REVIEW when tier ∈ {STANDARD, FULL}. A config that tries to route these to the cheap model is rejected with a one-line warning and falls back to the session/preferred model.
- New rule R-116 (tiering) + the eligible/required sets as a table in core.md. Run-record records `stage_model` per dispatched stage.

### 4.2 Persistent reviewer session (`protocol/orchestrator.md`, `reviewer.md`, `core.md`)

- New rule R-117: for one task, the REVIEWER context SHOULD persist across FULL_REVIEW → TARGETED_REVIEW → FINAL_REVIEW where the host tool supports resuming a context; otherwise it degrades to a fresh context (explicit, not silent). The IMPLEMENTER context is never shared with the reviewer (R-1/R-2 hold).
- The persistent reviewer retains its findings ledger between passes (cheaper TARGETED_REVIEW: it already knows what it flagged).
- **R-117 safety clause:** FINAL_REVIEW re-runs machine evidence (drift/tests/SAST/mutation per tier) from scratch and re-confirms each AC with fresh evidence regardless of session continuity; a persistent session may reuse *context*, never a *prior verdict*. `fresh_final_reviewer: true` in config forces a cold FINAL context.
- Run-record records `review_session: persistent | fresh-degraded | fresh-configured`.

### 4.3 Delta-only FINAL_REVIEW (`protocol/final-reviewer.md`, `core.md` §4.7)

- New rule R-118: FINAL_REVIEW scope = (a) confirm every open finding from the prior review is closed in the ledger; (b) re-run all machine gates for the tier (drift, tests, SAST, mutation) — these are cheap and catch regressions; (c) LLM review of only the **delta** = files changed by FIXING commits since the last FULL_REVIEW (`git diff <last-full-review-sha>..HEAD`); (d) re-confirm every AC with evidence (ACs are the acceptance contract — always re-checked, cheap).
- FINAL does **not** re-read files unchanged since the last FULL_REVIEW.
- **Safety:** a FINAL_REVIEW failure still routes to FIXING and the next review is a FULL_REVIEW (existing R-14) — so any regression that a delta-scope missed gets a full pass on the next lap. The machine-gate re-run (b) is the regression backstop within a single FINAL pass.
- Run-record records the delta SHA range reviewed at FINAL.

### 4.4 Measurement (`templates/run-record.yaml`)

Run-record gains: `stage_model` per stage, `review_session` mode, `final_delta_range`. No behavior depends on these — they make the savings auditable (and feed E's benchmark later).

## 5. Affected files (all within A/B structure)

**Modified:**
- `protocol/core.md` — R-116 (tiering + eligible/required table), R-117 (reviewer session + safety clause), R-118 (delta FINAL); §1.4 model config note
- `protocol/orchestrator.md` — per-stage model selection, reviewer-session reuse/degrade, delta-range computation for FINAL
- `protocol/reviewer.md` — persistent-session behavior, ledger retention across passes
- `protocol/final-reviewer.md` — delta scope + mandatory machine re-run + AC re-confirm + safety clause
- `heatwave.config.example.yaml` — `cheap_model`, `stage_models` map, `small_diff_threshold`, `fresh_final_reviewer`
- `templates/run-record.yaml` — `stage_model`, `review_session`, `final_delta_range`
- `PROTOCOL.md` — regenerated via build-protocol.sh (drift-checked)
- adapters — repo-wide grep for any place asserting "fresh context per review" or "FINAL re-reviews everything" that R-117/R-118 change

**No new runtime dependencies.** Model routing and session reuse are config + orchestration rules; tool support is detected/degraded, never required.

## 6. Alternatives considered

1. **Cheap models wherever tier allows (incl. STANDARD review / first-pass FULL).** Rejected by owner: a cheap model gating real review raises miss risk; mechanical-only is the safe cut.
2. **Fresh reviewer every pass.** Rejected: forfeits the cache win C exists to capture; isolation is already satisfied (reviewer authored no code).
3. **Fully delta FINAL with no machine re-run.** Rejected: a delta-only LLM pass could miss a regression in an unchanged file broken by a fix elsewhere; the machine-gate re-run + R-14 full-pass-on-failure are the backstops.
4. **Mandate a cheap model.** Rejected: breaks zero-config and forces a second model. Opt-in via config.

## 7. Risks & mitigations

| Risk | Mitigation |
|---|---|
| Cheap model misses something in a review it gates | mechanical-only eligibility; frontier-required set can't be downgraded; FULL/FINAL always frontier |
| Persistent reviewer rubber-stamps its own prior verdict at FINAL | R-117 safety clause: FINAL re-runs machine evidence from scratch + re-confirms ACs; `fresh_final_reviewer` escape hatch |
| Delta-only FINAL misses a regression in an unchanged file | machine gates re-run every FINAL; FINAL failure → FULL_REVIEW next (R-14) |
| Tool can't persist a context | explicit degrade to fresh (recorded), correctness unaffected — only cache lost |
| Config tries to downgrade a frontier-required stage | rejected with warning, falls back to session/preferred model |
| Regenerated PROTOCOL.md drift | build-protocol.sh drift self-check |

## 8. Verification strategy (evidence, not assertion)

Live adapter runs + deterministic self-checks:
1. **Tiering routes correctly.** An EXPRESS/LIGHT run with `cheap_model` set records `stage_model: <cheap>` on eligible stages and the frontier model on FULL_REVIEW. Evidence: run-record.
2. **Frontier-required not downgradable.** A config routing FULL_REVIEW to the cheap model is rejected (warning) and the run uses the session/preferred model. Evidence: transcript + run-record.
3. **Zero-config unchanged.** With no tiering config, every stage uses the session model (A/B behavior intact). Evidence: run-record.
4. **Persistent session.** A multi-review task on a persistence-capable adapter records `review_session: persistent` and the reviewer references its prior findings at TARGETED_REVIEW. On a non-persistent path, records `fresh-degraded`. Evidence: run-record + transcript.
5. **FINAL safety clause.** A persistent-session FINAL still re-runs machine gates from scratch and re-confirms ACs (shown in the final report); `fresh_final_reviewer: true` yields a cold FINAL context. Evidence: final report + run-record.
6. **Delta FINAL scope.** A FINAL_REVIEW after FIXING reviews only `git diff <last-full-sha>..HEAD`, re-runs machine gates, re-confirms ACs, and does not re-read unchanged files. Evidence: `final_delta_range` in run-record + report.
7. **Regression + drift + A/B preserved.** EXPRESS still instant; drift check green; a full STANDARD feature still reaches APPROVED; B's ladder still runs. Evidence: run-records + drift output.
8. **Adapter consistency.** Repo-wide grep shows no adapter still asserts fresh-per-review or full-re-read-FINAL.

Unavailable capability (e.g. no cheap model configured, tool can't persist) declared/degraded explicitly (R-64), never silently skipped.

## 9. Open questions

None blocking.
