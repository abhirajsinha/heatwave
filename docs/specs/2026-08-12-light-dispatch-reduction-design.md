# Planning Document — LIGHT Dispatch Reduction: Design & Measurement Investigation

task_id: light-dispatch-reduction-plan | artifact_type: planning-document | iteration: 2 | produced_by: PLANNER (claude-opus-4-8) | timestamp: 2026-08-12

### Iteration 2 — response to PLAN_REVIEW findings

- **F-001 (Major, verification-integrity) — FIXED.** The combined FULL+FINAL anchor-table row read `29 Read / 13 Bash / 2 Write`, which was the double-counted sum of *both* reviewer dispatches (PLAN_REVIEW haiku 11R/4B/2W + combined opus 18R/9B/0W). Re-derived by grouping `assistant.tool_use` on `parent_tool_use_id` for the 4th dispatch alone: **18 Read / 9 Bash / 0 Write** (opus, pre-cap; zero writes, as expected — it never reached artifact authoring). Table corrected, derivation method noted, and the stray "reviewer 29 Read" in the whole-run paragraph fixed. The Read-heavy conclusion is unchanged; the number is now reproducible and does not merge a haiku stage into an opus row.
- **F-002 (Minor) — FIXED via option (a).** Added a second Phase-2 scenario `lt-hidden-surface` — a defect planted *outside* the pre-supplied diff (a regression in an unchanged file / a multi-file LIGHT case) — so A/B-2 can actually exercise the surface-hiding failure mode that `lt01` (single-file) cannot. Gate-preservation review charge also sharpened (confirm retained full tool access + spot-check beyond the pre-supplied set). FR-3 and AC-F-05 updated accordingly.
- **F-003 (Minor) — FIXED.** Verified `benchmark/run.sh` `run_agent` fires a single headless `claude -p` that drives the loop from START and reads `state.yaml` only for logging — **there is no resume path**. The bounded Phase-0 run is therefore a **full uncapped replay to reach dispatch-4**, not a resume. Caps raised honestly to match (NFR-1 / AC-N-02: ≤ ~$10, ≤ ~35 min for the single replay).
- **F-004 (Nit) — FIXED.** Tooling declaration now states the R-110 machine ladder is largely `NOT_AVAILABLE` for a markdown-plus-throwaway-script deliverable (no shippable code diff to test/scan); the real evidence is the decomposition self-check + the reviewer's independent re-derivation. Tier stays STANDARD (justification unchanged).

> **What this document is.** A plan for an *investigation*, not for a code change. The deliverable of the run this plans is (a) a zero-cost per-stage time+token **decomposition** of a LIGHT run built from transcripts already on disk, and (b) a **design + bounded-validation analysis** of candidate levers that reduce LIGHT dispatch cost without weakening any gate. No lever is implemented here; each surviving lever is a **separate future Heatwave run**, gated on the evidence this investigation produces. Acceptance criteria below are about the *completeness and soundness of the investigation design*, per the mission — not about shipped code.

## Tier

**STANDARD** — the investigation spans three distinct pieces of work (a transcript-decomposition analysis script, at most one bounded live harness run, and a multi-lever gate-preservation design analysis); it is not a single-file edit, and its conclusions feed changes to protocol rules (R-116/117/118 neighborhood) that are themselves cross-cutting. STANDARD is the honest floor. (PROTOCOL §0.5, R-103a rung 4.)
Change class: **feature** — this is net-new measurement + design analysis; it corrects no defective existing behavior, so R-113 (failing-reproduction AC) does not apply. (R-114.)

## Problem Statement

A LIGHT Heatwave run is four sequential **cold** frontier dispatches — PLANNING → PLAN_REVIEW → IMPLEMENTING → combined FULL+FINAL — each a fresh subagent context that reconstructs task understanding and re-explores the repository from scratch. Measured whole-run wall on the `lt01-progress-cap` fixture is **~20 min at ~$6.22** (verified: `result.duration_ms` 1,196,835 ms and `total_cost_usd` 6.221 in `benchmark/results/transcripts/20260812T084538Z-heatwave/lt01-progress-cap-trial1/agent.ndjson`). Model tiering has already been taken (R-116); it saved ~40% of the *PLAN_REVIEW stage* but produced **no measurable whole-task improvement** — it is one of four dispatches and inter-dispatch variance swamps it. That lever is closed.

The remaining levers are the **other three dispatches** and, specifically, the **repo-rediscovery and context-reconstruction tax carried inside each cold dispatch**. We are currently *guessing* where each ~6-min dispatch spends its wall and tokens. Before designing any change we must decompose a dispatch into context-construction / generation / tool-calls (repo-exploration vs shell/tests) / waiting, per stage. Doc §9 (Speed/Token Engine, `docs/specs/2026-08-11-speed-token-engine-design.md`) demands exactly this decomposition; it has not been done. **This plan leads with that measurement, done at zero cost from transcripts already captured, and only then designs levers against the measured headroom.**

Audience: the Heatwave maintainer (OWNER) and the future IMPLEMENTER/REVIEWER contexts that will act on each lever.

## Functional Requirements

- **FR-1 (Phase 0, measurement-first).** Produce a per-stage, within-stage decomposition of a LIGHT run — PLANNING, PLAN_REVIEW, IMPLEMENTING, and combined FULL+FINAL — covering wall time and tokens, split into: context-build, generation, tool-calls (repo-explore vs shell/tests), and waiting. Prefer **zero-cost** derivation from existing `agent.ndjson`; spend a live run only for the stage the existing transcripts cannot cover, and only once, capped.
- **FR-2 (Phase 1, levers).** For each candidate lever: state the mechanism; name every gate it touches and argue precisely how each gate is preserved; estimate headroom against the Phase-0 decomposition; state the risk to independence/rigor; and specify a bounded validation experiment (metric, method, cap, n). Rank by expected headroom × gate-safety.
- **FR-3 (Phase 2, validation design).** For each lever that survives Phase 1, design an A/B on the LIGHT fixtures — `lt01` plus a `lt-hidden-surface` scenario with a defect outside the pre-supplied diff — with a hard cost/wall cap, honest small-n reporting, and explicit success/kill criteria; state that no lever ships without measured evidence **and** an independent gate-preservation review.
- **FR-4.** Reject explicitly, with reason, any lever that removes or weakens any of the four gates — even a tempting one.
- **FR-5.** State that every lever's implementation is a separate future Heatwave run, gated on Phase-0/1 evidence; this investigation ships analysis, not protocol edits.

## Non-Functional Requirements

- **NFR-1 (Phase-0 cost ceiling).** The decomposition of dispatches 1–3 MUST be derivable from existing transcripts at **zero additional model spend**. The single live run needed for dispatch-4 is a **full uncapped replay** (the harness has no resume path — see Architecture), hard-bounded per AC-N-02.
- **NFR-2 (measurement fidelity).** The decomposition MUST attribute ≥ 90% of each captured dispatch's wall to a named bucket (context-build / generation / tool-call / wait), with the unattributed remainder reported, not hidden.
- **NFR-3 (honesty of n).** Every wall/token figure carries its sample size and source transcript; n=1–2 is reported as n=1–2, never smoothed into a false average.

## Architecture

The investigation has three phases and one throwaway analysis artifact. Nothing here is production code; the "components" are analysis stages.

### Phase 0 — Measurement (do first; dispatches 1–3 are zero-cost)

**Data already on disk (verified).** Each captured LIGHT trial under `benchmark/results/transcripts/*-heatwave/lt01-progress-cap-trial1/` holds:

- `agent.ndjson` — the single headless driver session (421 events in the reference trial). **Fact (verified by inspection):** it is a *flat event stream in which subagent-internal events are tagged*. `assistant` and `user` events carry `timestamp`, `parent_tool_use_id`, and `subagent_type`; `user` events additionally carry `tool_use_result`/`tool_result_meta`. Each dispatch appears as a `system/task_started` (with `subagent_type` + `tool_use_id`) and closes with a `system/task_notification` carrying `usage: {total_tokens, tool_uses, duration_ms}`. `assistant.message.usage` carries `input_tokens`, `output_tokens`, `cache_creation_input_tokens`, `cache_read_input_tokens`, and thinking tokens. The terminal `result` event carries `modelUsage` (per-model token + cost breakdown), `duration_ms`, and `duration_api_ms`.
- `state-timeline.log` — 30s-sampled `state.yaml` snapshots → coarse per-stage wall boundaries (used to cross-check the ndjson-derived boundaries).
- `heatwave-runs/*/run-record.yaml` — model-authored transition timestamps + `stage_model` per dispatch.

**Conclusion the investigation will assert as its Phase-0 finding (grounded, to be produced by the script):** the four decomposition buckets are all recoverable from `agent.ndjson` alone for any dispatch that ran to completion:

| Bucket | How it is derived from `agent.ndjson` (zero-cost) |
|---|---|
| Per-stage boundary + total | `task_started` → matching `task_notification`; `usage.duration_ms` and `usage.total_tokens` are the stage totals. |
| Context-build (cold-start tax) | `assistant.message.usage.cache_creation_input_tokens` summed per `subagent_type` — the tokens the cold context had to (re)build; plus wall from `task_started` to first `assistant` token. `cache_read_input_tokens` is the warm-reuse counterpart. |
| Generation | `output_tokens` (incl. thinking) per stage; generation wall = timestamp gaps from a `user` tool_result to the next `assistant` message. |
| Tool-calls, classified | Every `assistant` `tool_use` block carries the tool `name`, tagged to its dispatch by `parent_tool_use_id`. **Repo-explore** = Read/Grep/Glob; **shell/tests** = Bash; **authoring** = Write/Edit. Tool-call wall = `timestamp(user tool_result) − timestamp(preceding assistant tool_use)`. |
| Waiting | `result.duration_ms − duration_api_ms`, plus `rate_limit_event` spans, attributed as non-compute wall. |

**Verified sample decomposition inputs (reference trial `20260812T084538Z`, n=1; tool counts re-derived per dispatch by `parent_tool_use_id` — these are the raw facts the script will tabulate, not the analysis):**

| Dispatch | Model | Wall (task_notification) | Tokens | Tool_uses | Tool profile (this dispatch only) |
|---|---|---|---|---|---|
| PLANNING | opus | 315,733 ms (~5.3 min) | 55,391 | 20 | 8 Read / 11 Bash / 1 Write |
| PLAN_REVIEW | haiku | 160,671 ms (~2.7 min) | 60,215 | 17 | 11 Read / 4 Bash / 2 Write |
| IMPLEMENTING | opus | 403,415 ms (~6.7 min) | 93,312 | 35 | 11 Read / 17 Bash / 4 Edit / 3 Write |
| combined FULL+FINAL | opus | **CAPPED** (`status: stopped`, empty usage) | — | (27 pre-cap) | 18 Read / 9 Bash / 0 Write (pre-cap; never reached authoring) |

Whole run: `duration_ms` 1,196,835 ms (~20 min), `total_cost_usd` $6.22, opus `cacheReadInputTokens` 4.28M vs `cacheCreationInputTokens` 288K. The **Read-heavy tool profile of every stage** (combined-pass reviewer 18 Read, plan-reviewer 11 Read, implementer 11 Read, planner 8 Read) is the first-order evidence that repo re-exploration is a large, removable fraction — which is what levers 2/3/6 target. The exact wall fraction is the script's output, not asserted here.

**The one gap requiring a bounded run, and why it is a full replay.** The combined FULL+FINAL pass is **capped in every captured LIGHT trial** — verified across `20260812T084538Z` (stopped), `20260812T082507Z` (first three completed, 4th stopped), and `20260812T080631Z` (stopped at PLANNING). The ~20-min harness deadline (`HW_DEADLINE`/`with_deadline` in `benchmark/run.sh`, marker `deadline.expired`) truncates the 4th dispatch. **Verified:** `run.sh`'s `run_agent` launches a single headless `claude -p` that drives the whole loop from START and consults `state.yaml` only for logging (`LAST_STATE`) — **there is no resume/continue path**. Reaching dispatch-4's completion therefore requires **re-running the full LIGHT loop once with a raised `HW_DEADLINE`**, not resuming the prior run. Dispatches 1–3 still decompose at **zero cost** from the transcripts already on disk; only dispatch-4's `task_notification.usage` needs the replay. This is the *only* justified live spend in Phase 0, and its cost is a full LIGHT run (~$6–8 through dispatch-3) plus the uncapped 4th dispatch's generation — bounded by AC-N-02 at ≤ ~$10 / ≤ ~35 min.

**Instrumentation verdict (to be confirmed by the script, stated as the plan's inference):** No new harness instrumentation is needed for the four-bucket decomposition — the ndjson already carries per-event timestamps, per-tool names, and per-message cache/generation token splits. The only Phase-0 spend is the single uncapped replay to *complete* the 4th dispatch's capture, not to *instrument* anything. If, and only if, the script finds that first-token latency cannot be separated from thinking with timestamps alone (a known limitation — cache-read wall is not directly observable), the plan's fallback is to treat `cache_creation_input_tokens` as the context-build proxy rather than add instrumentation.

**Phase-0 deliverable:** a decomposition table (per stage: context-build tokens, generation tokens-out, repo-explore tool wall, shell/test tool wall, wait, and % of stage wall attributed) plus a one-paragraph "where the headroom is" finding. This tells us which lever has headroom *before* any lever is designed.

### Phase 1 — Candidate levers

For each: mechanism → gates touched & preservation → headroom (against Phase-0) → independence/rigor risk → bounded experiment. Ranked at the end.

The four gates, restated (the invariants no lever may weaken): **(G1)** a plan reviewed by a *separate* context (PLAN_REVIEW); **(G2)** distinct PLANNER/IMPLEMENTER/REVIEWER contexts *by authorship*; **(G3)** evidence over assertion — the reviewer runs the R-110 machine-evidence ladder *itself*; **(G4)** the completion gate — the LIGHT combined FULL+FINAL pass evaluates in full (R-118).

**Framing (honest, from ground truth):** PLANNING (~5.3 min) and IMPLEMENTING (~6.7 min) are frontier-required *authoring* dispatches and are **not removable** — the dispatch stays. Every viable lever therefore targets the **within-dispatch repo-rediscovery + context-reconstruction fraction**, not the dispatch itself. We are shrinking the cold-start tax inside each stage, not deleting stages.

---

**Lever 2 — Diff-focused context/evidence pre-supply (repo-exploration elimination).** *[Extends R-107, R-3.]*
- *Mechanism.* The driver hands each dispatch the exact artifacts it needs — task text, ACs, the unified diff (for review/impl stages), changed-file contents, prior findings, and the driver's already-computed machine-evidence outputs *as reference* — so a single-file LIGHT dispatch does near-zero repo exploration. R-3 already says the reviewer receives *artifacts*; this makes the artifact set complete enough that Read/Grep of the tree is unnecessary for the common single-file case.
- *Gates.* G3 is the one at risk and it is **preserved by construction**: the reviewer still runs the R-110 ladder *itself* (R-110 forbids trusting outputs attached by other roles) — pre-supplied machine outputs are *context/orientation*, never a substitute for the reviewer's own re-run. G1/G2/G4 untouched (authorship boundary unchanged; the combined pass still evaluates in full). The one live risk: over-narrow pre-supply could *hide* surface the reviewer should have found (R-48 dynamic scope). Mitigation in the design: pre-supply is *additive* — it never removes the reviewer's tool access; the reviewer MAY still explore, it simply rarely needs to. This risk is what the `lt-hidden-surface` fixture in Phase 2 exists to test.
- *Headroom.* **Highest.** Directly attacks the Read-heavy fraction measured in Phase 0 (18/11/11/8 Read calls per stage). If repo-explore wall is a large share, this is the biggest cut.
- *Bounded experiment.* See Phase 2 A/B-2 (both `lt01` and `lt-hidden-surface` arms).

**Lever 3 — Driver-prepared context bundle reused across dispatches.** *[Extends R-107 stable-prefix ordering; Doc §9.3 context caching.]*
- *Mechanism.* The driver computes once — language, test command, repo structure, the diff — and injects that cached bundle into *every* dispatch's stable prefix, so no dispatch rediscovers project basics. This is Lever 2's project-invariant half, hoisted to run-once.
- *Gates.* All four preserved — this is orientation data, identical in kind to R-107's stable-prefix shards; it changes no gate requirement. G3 unaffected (bundle is not evidence; the ladder still runs).
- *Headroom.* Medium-high; overlaps Lever 2. **Design note (ponytail):** Levers 2 and 3 are one mechanism at two scopes (per-dispatch diff vs run-invariant bundle). The investigation treats them as **one lever family "pre-supply"** with two knobs, measured together, not two independent builds.
- *Bounded experiment.* Folded into A/B-2.

**Lever 6 (added) — Warm authoring handoff PLANNING→IMPLEMENTING.** *[My addition; Lever-2 family applied to the implementer.]*
- *Mechanism.* The Planning Document already names the target `file:function` and the fix; the IMPLEMENTER should not re-explore to *locate* the edit. Pre-supply the plan's located edit-site + changed-file contents so IMPLEMENTING's 11 Read / 17 Bash profile collapses toward "edit + run tests."
- *Gates.* All four preserved — the plan is already the implementer's authoritative input (R-7, R-17); this supplies it more completely. No gate touches the implementer's obligation to satisfy the plan.
- *Headroom.* Attacks IMPLEMENTING (~6.7 min, the largest stage). Ranked with Lever 2.
- *Bounded experiment.* A/B-2 (implementer arm).

**Lever 1 — Extend the persistent reviewer to PLAN_REVIEW (R-117 extension for LIGHT).**
- *Mechanism.* The same reviewer context does PLAN_REVIEW and then the combined FULL+FINAL pass, so the combined pass skips cold-start task reconstruction. R-117 today persists FULL→TARGETED→FINAL but *not* PLAN_REVIEW.
- *Isolation argument.* Sound in principle: the reviewer authored *neither* the plan nor the code (G2's boundary is authorship), so one reviewer context spanning both reviews violates neither R-1 nor R-2.
- *The model complication (decisive, from ground truth).* PLAN_REVIEW at LIGHT is **cheap-eligible and runs on haiku** (verified: `stage_model: claude-haiku-4-5` in the reference run-record); the combined pass is **frontier-required (opus)** (R-116). A persistent session cannot span a model switch — you cannot "resume" a haiku context as opus. So the saving materializes **only if PLAN_REVIEW is forced back to frontier**, which *reverses the model-tiering win already banked* on that stage. Net: this lever trades a banked ~40%-of-a-cheap-stage saving for a warm-start on a ~2.7-min stage. Additionally, the current adapter dispatches **one-shot Task subagents** and records `review_session: fresh-degraded` (verified) — there is no resumable reviewer session to extend today; the host would have to gain session-resume first.
- *Safety clause.* Even where it applied, R-110's "re-run machine evidence from scratch" safety clause (R-117) still holds — persistence reuses context, never a prior verdict — so G3/G4 are not weakened by the lever *per se*.
- *Headroom.* **Low, and self-cancelling** against tiering. **Provisional verdict: reject for LIGHT** unless Phase 0 shows the combined-pass cold-start reconstruction is unexpectedly expensive *and* the adapter gains session-resume — recorded as a kill, revisitable if those two facts change.

**Lever 4 — Overlap deterministic machine-evidence with LLM review setup.**
- *Mechanism.* R-110 requires the ladder to run *before* LLM findings; the driver could pre-stage/parallelize the deterministic runs (the `tests` rung) so the reviewer isn't waiting on them serially.
- *Gate.* G3 preserved *only if the reviewer still runs the ladder itself* and records the verdicts (R-110). A driver pre-run can *warm* the result but the reviewer's own re-run is non-negotiable — so this is a wall overlap, not a compute saving, and it risks becoming a "trust the attached output" violation if mis-implemented.
- *Headroom.* **Low for LIGHT:** the LIGHT ladder is *just `tests`* (per the tier table), which is seconds, not minutes — there is little to overlap. Verified: the reviewer stage is Read-dominated (18 Read), not test-dominated.
- *Verdict: low priority.* Analyze in Phase 1 for completeness; likely not worth an A/B until Phase 0 proves the test rung is a non-trivial wall fraction (expected: it is not).

**Lever 5 / Lever 7 — structural consolidation, and the rejections.**
- *Analyzed and REJECTED — collapse PLANNING into IMPLEMENTING, or drop PLAN_REVIEW:* removes G1 (plan reviewed by a separate context) and/or G2 (distinct authorship). Out of scope by the hard constraint; stated as rejected so no one revisits it as a "speed win."
- *Analyzed and REJECTED — merge the combined FULL+FINAL pass's independence into the implementer context:* removes G2. Rejected.
- *Viable structural item to investigate:* whether there is **redundant re-establishment between IMPLEMENTING and the combined pass** that Lever-2 pre-supply already removes (the reviewer re-deriving what the implementer just established). This is not a new lever — it is a headroom question Phase 0 answers and Lever 2 captures.

**Ranking (headroom × gate-safety):**
1. **Pre-supply family (Levers 2 + 3 + 6)** — highest headroom (attacks the measured Read-heavy fraction across all three authoring/review stages), all gates preserved by construction. Primary candidate.
2. **Lever 4 (machine-evidence overlap)** — gate-safe but low LIGHT headroom (ladder = `tests` only). Secondary; may not warrant an A/B.
3. **Lever 1 (persistent reviewer → PLAN_REVIEW)** — provisional reject: self-cancels against banked tiering + needs adapter session-resume. Revisit only if Phase 0 contradicts.
4. **Levers 5/7 gate-removing consolidations** — rejected outright.

### Phase 2 — Bounded validation design

- **A/B-2 (the one A/B worth running): pre-supply family on two fixtures.**
  - *Arm A — `lt01` (throughput).* Baseline = current LIGHT run. Treatment = driver injects the diff-focused context bundle (Levers 2/3/6) into each dispatch. **Metric:** whole-run wall + `total_cost_usd` + per-stage repo-explore tool wall (from the Phase-0 script, applied to both arms). **Success:** treatment cuts whole-run wall or cost by a pre-registered margin (e.g. ≥ 15%) **with zero new open Blockers/Majors** and an unchanged terminal verdict on `lt01`. **Kill:** no measurable whole-run improvement (as tiering already taught us — a stage win that doesn't move the whole-run number is not a win), OR any gate-preservation regression.
  - *Arm B — `lt-hidden-surface` (the surface-hiding guard, closes F-002).* A LIGHT scenario whose defect lives *outside* the pre-supplied diff — either a planted regression in a file the diff does not touch, or a genuinely multi-file LIGHT change. `lt01` (single-file) structurally cannot trigger the top lever's one real risk (an R-48 miss); this fixture can. **Metric:** does the treatment reviewer still *find* the out-of-diff defect (terminal verdict must catch it, exactly as baseline does)? **Kill (hard, overrides any speed win):** treatment misses a defect baseline catches → the pre-supply lever is unsafe as specified and does not ship.
  - **Cap:** ≤ 6 trials total (2 baseline + 2 treatment on `lt01`; 1 baseline + 1 treatment on `lt-hidden-surface`), hard `HW_DEADLINE`, ≤ ~$40 and ≤ ~2.5 h aggregate. **n:** 2 per `lt01` arm (reported as n=2 with variance), 1 per `lt-hidden-surface` arm (a pass/fail correctness probe, not a timing measurement — reported as n=1).
- **Gate-preservation review is mandatory and separate.** No lever ships on the A/B number alone. Each surviving lever's *implementation* run carries an independent REVIEWER pass whose explicit charge is: does the lever leave G1–G4 intact? For pre-supply specifically the reviewer MUST confirm (a) the treatment reviewer still ran the R-110 ladder *itself*; (b) the treatment reviewer *retained full tool access* (pre-supply added context, removed no capability); (c) it **spot-checked beyond the pre-supplied set** on at least the `lt-hidden-surface` case, i.e. surface-hiding is detectable even where a fixture does not force it. This is the gate-preservation review the mission requires.
- **No full benchmark sweep.** The historical sweep is ~43 min/task; Phase 2 touches only `lt01` + `lt-hidden-surface` and only for surviving levers. Levers 1/4/5/7 get no live run unless Phase 0 overturns their provisional rejection.

## API Design

N/A — this is a measurement + design investigation; it defines no runtime API. The Phase-0 analysis script's I/O is `agent.ndjson` → a decomposition table (throwaway tooling, not a shipped contract).

## Data Design

N/A — no schema or persistent store. The only structured output is the decomposition table (a report), and the existing `run-record.yaml`/`agent.ndjson` schemas, which this investigation *reads* and does not alter.

## State Management

N/A — the investigation is stateless analysis over immutable captured transcripts; the one bounded replay uses the existing `.heatwave/runs/` state machinery unchanged.

## Error Handling Strategy

- **Decomposition script fails to parse a transcript** (schema drift across trial dates) → the script reports which fields were missing per trial and falls back to `state-timeline.log` + `run-record.yaml` transition timestamps for stage boundaries (coarser, but present in every trial). Reported, never silently averaged.
- **The bounded replay also caps or errors before dispatch-4 completes** → report the 4th-dispatch decomposition as *partial* (the pre-cap tool profile is still captured, as it is in the existing trials: 18 Read / 9 Bash / 0 Write), state the gap explicitly (R-64 discipline), and do not fabricate the missing wall. The investigation's conclusions for dispatches 1–3 stand regardless.
- **A lever's A/B shows a stage win but no whole-run win** → this is a *kill*, not a "needs more runs"; recorded as such (the tiering lesson).

## Security Considerations

N/A for threat surface — no code, no network, no user data, no new dependency. One process note: transcripts under `benchmark/results/transcripts/` may contain absolute paths and repo contents; the decomposition report cites paths but introduces no new secret-bearing surface. `change_surface: none`.

## Edge Cases

- **PLAN_REVIEW ran on haiku, others on opus** — the decomposition MUST keep per-stage `stage_model` so token/wall figures are not compared across models blindly (verified: reference run-record shows haiku PLAN_REVIEW, opus elsewhere), and MUST attribute tool calls to a single dispatch via `parent_tool_use_id` (the F-001 double-count came from summing both reviewer dispatches). Directly relevant to Lever 1's model-switch complication.
- **The combined pass is capped in *all* existing trials** — dispatch-4 decomposition is unavailable zero-cost; handled by the single bounded replay (see Architecture).
- **`review_session: fresh-degraded`** in the current adapter (verified) — there is no persistent reviewer session today; Lever 1 presupposes an adapter capability that does not yet exist. The plan states this as a precondition, not an assumption.
- **No harness resume path** (verified) — dispatch-4 capture is a full loop replay, not a resume; the cost cap reflects this.
- **n=1–2 throughout** — every figure carries its n; no smoothing (NFR-3).
- **Driver-side tool calls vs subagent tool calls** — the ndjson tags both (`subagent_type: DRIVER` vs role); the decomposition MUST attribute tool calls to the owning subagent, not the driver, or it will over-count exploration. (Verified: driver had its own 4 Agent / 7 Read / 5 Bash separate from subagents.)

## Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| Zero-cost decomposition proves lower-fidelity than hoped (first-token vs thinking inseparable from timestamps) | Medium | Use `cache_creation_input_tokens` as the context-build proxy (verified present per stage); report attribution % (NFR-2) rather than over-claim. |
| Pre-supply lever (top candidate) shows a stage win but no whole-run win — the exact failure tiering hit | Medium | Pre-registered whole-run success metric + kill criterion in A/B-2; measured before any implementation run. |
| Pre-supply lever hides review surface (R-48 miss) and `lt01` cannot expose it | Medium | The `lt-hidden-surface` fixture (Arm B) forces an out-of-diff defect; a treatment miss is a hard kill regardless of speed. |
| Reviewer/maintainer treats this plan's *provisional* lever verdicts as final | Low | Verdicts are explicitly provisional-pending-Phase-0; each is revisitable on stated conditions. |
| The bounded replay is misused to "benchmark" rather than to complete dispatch-4 capture | Low | NFR-1 caps it to one replay with a single stated purpose. |
| Someone implements a gate-removing consolidation for speed | Low | Levers 5/7 rejected in writing with the gate each removes. |

## Dependencies

- **Internal (available, verified on disk):** `benchmark/results/transcripts/*-heatwave/lt01-progress-cap-trial1/{agent.ndjson,state-timeline.log,heatwave-runs/*/run-record.yaml}`; the harness `benchmark/run.sh` (single-shot `run_agent`, no resume path — verified; `HW_DEADLINE`/`with_deadline` for the one bounded replay) and `benchmark/parse-result.py` (reusable parsing patterns for the decomposition script).
- **Internal (design inputs):** `docs/specs/2026-08-11-speed-token-engine-design.md` (§9 decomposition demand, R-116/117/118 rationale); `protocol/core.md` (R-107, R-110, R-116, R-117, R-118), `protocol/reviewer.md`, `protocol/orchestrator.md`.
- **External:** none. No new dependency (ponytail: the decomposition is a single `python3` script over JSON already produced; `parse-result.py` shows the pattern — no new library).
- **Precondition (not a dependency this run adds):** Lever 1 presumes an adapter that can resume a reviewer session; today's records `fresh-degraded`. Stated so the future run does not assume it.
- **New fixture:** `lt-hidden-surface` (Phase 2 Arm B) — a small LIGHT corpus case with an out-of-diff defect; built from the existing corpus pattern under `benchmark/corpus*/`, no new tooling.

## Testing Strategy

This investigation's "tests" are the self-checks on its analysis, not a code suite.

- **Decomposition script self-check.** The per-stage bucketed wall MUST sum to within the reported attribution tolerance of the `task_notification.duration_ms` for that stage (NFR-2), and per-stage `total_tokens` MUST reconcile with `result.modelUsage` aggregated by model. A `demo()`/`__main__` assertion on the reference trial (`20260812T084538Z`) that the three completed dispatches reconcile — and that per-dispatch tool counts are grouped by `parent_tool_use_id`, not summed across dispatches (the F-001 guard) — is the one runnable check the script leaves behind (ponytail: one assert, no framework).
- **Cross-source boundary check.** ndjson-derived stage boundaries MUST agree with `state-timeline.log` transitions within the 30s sampling granularity; disagreement beyond that is reported as a data-quality finding.
- **Bounded live replay.** Exactly one uncapped full LIGHT run to complete dispatch-4 capture; its output is the 4th row of the decomposition table. Invoked via `benchmark/run.sh` with raised `HW_DEADLINE` (no resume path exists, so it is a replay).
- **By whom.** The future IMPLEMENTER of this investigation runs the script and the one bounded replay; the REVIEWER re-runs the script against the transcripts (evidence over assertion — the numbers must reproduce, including the corrected per-dispatch tool counts).

## Rollout Plan

N/A — a plan/analysis document plus a throwaway script; nothing is rolled out to users. Each *lever* that survives becomes its own future Heatwave run with its own rollout, gated on this investigation's evidence (FR-5).

## Rollback Plan

Delete the analysis artifact and the throwaway decomposition script; there is no runtime change to revert. No protocol shard, config, or adapter is modified by this investigation. (If the one bounded replay leaves a `.heatwave/runs/` entry, it is a normal terminal run record, retained as evidence, not rolled back.)

## Acceptance Criteria

### Functional

AC-F-01 | The investigation produces a per-stage decomposition table for all four LIGHT dispatches (PLANNING, PLAN_REVIEW, IMPLEMENTING, combined FULL+FINAL) with buckets {context-build, generation, repo-explore tool wall, shell/test tool wall, wait} and per-stage `stage_model`, with tool counts grouped per dispatch by `parent_tool_use_id` (never summed across dispatches). | Verification: open the produced table; confirm 4 stages × 5 buckets present, each cell sourced to a transcript field or marked partial with reason; confirm the combined-pass row reads 18R/9B/0W, not 29/13/2.
AC-F-02 | Dispatches 1–3 are decomposed at zero additional model spend, from existing transcripts only. | Verification: the decomposition script runs against `benchmark/results/transcripts/20260812T084538Z-heatwave/...agent.ndjson` and emits stages 1–3 with no live invocation; reviewer re-runs it and reproduces the numbers.
AC-F-03 | Each of the five mission levers (plus the added Lever 6) is analyzed with: mechanism, gates-touched + per-gate preservation argument, headroom vs Phase-0, independence/rigor risk, and a bounded experiment (metric/method/cap/n). | Verification: checklist against Phase-1 section; every lever has all five fields; every Major-severity gate interaction has an explicit preservation argument.
AC-F-04 | Every lever that touches a gate for speed is either shown gate-preserving by construction or explicitly rejected with the gate it would remove named. | Verification: confirm Levers 5/7 are rejected in writing naming G1/G2; confirm Lever 1's provisional reject states its two conditions; confirm no lever weakens G3's "reviewer runs the ladder itself."
AC-F-05 | Phase 2 specifies, for each surviving lever, an A/B on `lt01` **and** a `lt-hidden-surface` scenario (defect outside the pre-supplied diff) with a hard cost/wall cap, pre-registered success/kill criteria, honest n, and a mandatory separate gate-preservation review that checks retained tool access + spot-check beyond the pre-supplied set; and states no lever ships without both. | Verification: confirm A/B-2 has both arms, metric, cap (≤ trials, ≤ $, ≤ time), success %, hard surface-hiding kill, and the sharpened separate-review charge.
AC-F-06 | The document states that every lever's implementation is a separate future Heatwave run gated on Phase-0/1 evidence, and that model-tiering re-optimization, gate removal, full sweeps, and enterprise/CLI scope are non-goals. | Verification: confirm FR-5 + Non-goals section present with those exclusions.

### Non-functional

AC-N-01 | The decomposition attributes ≥ 90% of each *completed* dispatch's `task_notification.duration_ms` to a named bucket; the unattributed remainder is reported, not hidden. | Verification: the script prints per-stage attributed-% ; assert ≥ 90% for stages 1–3 in the reference trial, or record the shortfall with cause.
AC-N-02 | Total Phase-0 live spend ≤ 1 full replay, hard-capped by `HW_DEADLINE`, ≤ ~$10 and ≤ ~35 min (reflecting that the harness has no resume path, so dispatch-4 capture replays the whole loop); Phase-2 A/B ≤ 6 trials, ≤ ~$40 and ≤ ~2.5 h aggregate. | Verification: each run records `total_cost_usd` and `duration_ms` from its own `agent.ndjson`; assert within caps; abort and report if exceeded.
AC-N-03 | Every wall/token figure in the deliverable carries its sample size (n) and source transcript path. | Verification: scan the decomposition table and lever headroom estimates; each cited number has an n and a path; n=1–2 is labelled as such.

## Review Scope

Applicable
✓ `plan-conformance` — always applicable; the deliverable must realize this investigation design (R-51).
✓ `verification-integrity` — always applicable; the central risk is asserting a decomposition/headroom number without re-running the script (R-65/R-110 discipline, mirrored for an analysis deliverable). The F-001 double-count is exactly this failure caught at plan review.
✓ `performance` (`api-latency`/`cpu` sense, repurposed) — the subject matter *is* dispatch wall/token cost; the reviewer must check the decomposition method is sound and the headroom estimates follow from it.
✓ `observability` (`metrics`/`tracing` sense) — the investigation is a measurement design; the reviewer checks the buckets are well-defined and reproducibly derivable from `agent.ndjson`.

Not applicable
✗ `ui-rendering`, `responsive-layout`, `design-system`, `navigation`, `deep-links`, `interaction`, `forms`, `client-state`, `api-integration`, `loading-states`, `empty-states`, `error-states`, `offline`, `accessibility`, `visual-regression` — no UI surface.
✗ `business-logic`, `api-contracts`, `request-validation`, `response-validation`, `status-codes`, `versioning`, `schema`, `migrations`, `transactions`, `indexes`, `query-performance`, `data-integrity` — no runtime service, no data store; the investigation reads immutable transcripts.
✗ `authentication`, `authorization`, `rbac`, `input-validation`, `output-encoding`, `injection`, `xss`, `csrf`, `ssrf`, `secret-management`, `encryption`, `secure-headers`, `secure-config` — no auth/network/secret surface (`change_surface: none`).
✗ `cache`, `concurrency`, `scalability` — the one caching subject (prompt-cache reuse) is analyzed as *content*, not implemented; no concurrency introduced.
✗ `error-handling` (reliability sense), `retry`, `circuit-breakers`, `timeouts`, `recovery`, `rate-limiting` — no runtime reliability surface; analysis-script failure modes are covered under Error Handling Strategy above.
✗ `logging`, `monitoring`, `alerting` — no running service to instrument.

(`plan-conformance` and `verification-integrity` are always applicable and are listed above.)

## Tooling Declaration

**Machine-ladder note (R-110, honest reconciliation — F-004).** This is an analysis deliverable: a markdown investigation plus a throwaway `python3` decomposition script. There is **no shippable production code diff**, so the STANDARD machine-evidence ladder mostly reads `NOT_AVAILABLE` by nature, not by missing tools — `tests` has no product suite to run, `sast` has no application code to scan, `mutation` is not a STANDARD requirement. The **real evidence for this deliverable** is (1) the decomposition script's `__main__` self-check reconciling against the reference trial, and (2) the REVIEWER's independent re-derivation of the numbers from `agent.ndjson` (the check that already caught F-001). Tier stays STANDARD (its justification is scope/blast-radius, not ladder depth); the ladder is declared truthfully rather than performed on prose.

| Test type | Tool | Invoking role | Access |
|---|---|---|---|
| Decomposition self-check | `python3` (`__main__` assert on the reference trial) — evidence: `benchmark/parse-result.py` proves python3 is the harness language | IMPLEMENTER | confirmed — the primary evidence for this deliverable |
| Transcript re-derivation | `python3` over `agent.ndjson` — evidence: files present under `benchmark/results/transcripts/*-heatwave/` | REVIEWER | confirmed — the primary independent check |
| Bounded live replay | `benchmark/run.sh` (`HW_DEADLINE`, `with_deadline`; no resume path) — evidence: `benchmark/run.sh` lines 36/57 | IMPLEMENTER | confirmed |
| Tests (R-110 rung) | — | REVIEWER | NOT AVAILABLE — no product code diff to test; deliverable is analysis + throwaway script. Leaves no AC unverified (ACs are checked by the two `python3` checks above). |
| SAST (STANDARD+ rung) | semgrep present (`companions.detected: [semgrep 1.172.0]`) | REVIEWER | NOT AVAILABLE for this deliverable — no application code diff to scan; would run only if the throwaway script is committed, and even then carries no AC. |
| Mutation | — | — | N/A — STANDARD tier does not require mutation (FULL only, R-110). |
| Secrets (FINAL rung) | gitleaks present (`companions.detected: [gitleaks 8.30.1]`) | REVIEWER | confirmed — run over any committed throwaway script; `change_surface: none`. |
| UI evidence | — | — | NOT AVAILABLE — no UI surface (no AC depends on it). |

change_surface: **none** — the investigation reads immutable transcripts and produces analysis; it touches no auth, payments, external input, endpoint, UI, dependency, secret, or public API surface. (R-122.)

---

### Non-goals (explicit)

- **Model-tiering re-optimization** — done (R-116); measured a stage win, no whole-task win; the smallest lever. Not reopened.
- **Any gate removal or weakening for speed** — the four gates hold; gate-removing consolidations are rejected in Phase 1.
- **Full benchmark sweeps** — no ~43-min/task sweep; only `lt01` + `lt-hidden-surface`, only for surviving levers, capped.
- **Enterprise / multi-repo / CLI scope** — out of scope (sub-projects G/H).
- **Implementing any lever** — every lever is a separate future Heatwave run gated on this investigation's Phase-0/1 evidence.

---

## Phase 0 Results — MEASURED & VERIFIED (2026-08-12)

Executed. Decomposition script `decompose.py` + table in `.heatwave/runs/light-dispatch-reduction-plan/`; independently re-derived by a separate REVIEWER context (own grouping script, not the table) — **CONFIRMED**, all anchors reproduce, F-001 guard holds (combined pass 18R/9B/0W ≠ the 29/13/2 double-count). n=2 on dispatches 1–3, reported un-averaged. **Dispatch-4 (combined FULL+FINAL) now measured** on the first fully-terminal LIGHT run (run `20260812T094216Z`, reached APPROVED, graded, oracle-pass/0-escaped, ~31 min / $9.98): combined-review wall 534.8 s, **generation 502.9 s = 94.0%**, tool-call wall 8.3 s (repo-explore 1.6 s) — it confirms the generation-bound finding across all four dispatches, no longer pending.

**The measured finding refutes this plan's own Phase-1 ranking rationale.** The rank put pre-supply first because the stages are *Read-heavy by tool count*. The decomposition shows that count is not wall:

- **Generation is 88–94% of every stage's wall** (PLANNING ~280 s, IMPLEMENTING ~378 s, review ~147–303 s).
- **Total tool-call wall per dispatch is 2–9 s; repo-explore (Read/Grep/Glob) wall is 0.5–1.6 s.** Eliminating repo re-exploration frees ~1 s, not minutes.
- The cold-start tax lives in **tokens, not wall**: `cache_creation` 95K–269K per cold dispatch; the run's $6.22 is dominated by opus **cache-read 4.28M tokens**.
- Whole-run idle wait is 1.3–2.3% → generation is genuine compute, not queue wait.

**Reranking (honest, over-claiming in neither direction):**
- Pre-supply (Levers 2/3/6) is a **cost lever with a measured win** (fewer rebuild tokens) and an **unproven wall win**. Whether handing a dispatch the diff + edit-site cuts any of its 280–378 s of *generation* is not decomposable from these timestamps (generation is one opaque block that may include input-processing pre-supply would shrink). It is neither established that it helps wall nor that it doesn't.
- **LIGHT wall time is generation-bound.** Under the fixed 4-dispatch gate structure, the wall is dominated by frontier-model generation doing the authoring/review work — inherent to the dispatch, not the context around it.

**Consequence for Phase 2.** The A/B's success metric MUST be **whole-run wall AND `total_cost_usd`**, reported separately: pre-supply may show a real cost reduction with no wall movement (the tiering outcome). A cost-only win is a legitimate result but is NOT the "dispatch reduction for speed" this project set out to find. The remaining genuine *wall* levers are outside context-reuse: a faster frontier model (out of scope), or a materially different gate-preserving structure (a larger bet). This is the value of measuring first — it stops us building pre-supply expecting a speed win it likely cannot deliver.
