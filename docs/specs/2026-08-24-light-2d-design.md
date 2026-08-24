# Design Spec — LIGHT-2D: two-dispatch, output-capped LIGHT tier (Heatwave v4.2)

- **Date:** 2026-08-24
- **Status:** Implemented — run light-2d, v4.2 (see benchmark/RESULTS.md addendum)
- **Scope:** LIGHT tier only. EXPRESS, STANDARD, FULL untouched.
- **Author context:** driver spec, grounded in the E2–E7 measurements (benchmark/RESULTS.md, docs/specs/2026-08-12-light-dispatch-reduction-design.md §"Phase 0 Results").

---

## 1. Problem

Nobody uses Heatwave for a normal daily story. The floor for such a story is LIGHT (EXPRESS is a single locatable edit), and LIGHT today costs **4 sequential fresh-context frontier dispatches** — PLANNING → PLAN_REVIEW → IMPLEMENTING → combined FULL+FINAL — at ~6 min each. The only LIGHT run that ever reached APPROVED took **~31 min / $9.98** (run 094216Z, lt01). A bare "just do it" is one dispatch, ~6 min, ~$1. At 5× the bare cost the protocol loses on adoption before it can win on correctness.

Measured facts that constrain the fix (E6, E7; n small but verified by two contexts):

1. **Wall is generation-bound: 88–94% of every stage's wall is the model writing its artifact.** Repo exploration wall is 0.5–1.6 s/dispatch. Cold context costs tokens (95–269K cache_creation/dispatch), not wall.
2. Model-tiering a single stage cut that stage 40% and the run 0% (swallowed by variance). Context reuse is a cost lever, not a wall lever.
3. Founder decision 2026-08-12: the remaining levers are a faster frontier model, or **a different gate-preserving structure**. This spec is the latter.

Corollary of (1): **every word the protocol requires a LIGHT role to write is latency.** The §3.2 Planning Document, the prose Review Report, the narrative Implementation Package and the separate PLAN_REVIEW round-trip are the cost, not the repo, not the model.

## 2. Goals / non-goals

**Goals**
- G1. LIGHT runs in **two dispatches**: one IMPLEMENTER (plan-then-code-then-machine-ladder) and one independent REVIEWER (plan + diff + evidence, combined FULL+FINAL). No PLANNER dispatch, no separate PLAN_REVIEW dispatch at LIGHT.
- G2. **Output caps** on every LIGHT artifact: narrative prose bounded to a fixed shape; evidence (R-65) never truncated to satisfy a cap.
- G3. All four gates hold (R-1/R-2 isolation, plan reviewed by a separate context before APPROVED, evidence over assertion, R-77 completion gate). No context ever approves its own work.
- G4. Zero-config unchanged; no new dependency; no new binary; adapters other than claude-code degrade to the same two-session pattern.
- G5. **Measured, not asserted:** an A/B on the existing `benchmark/corpus-tiering/lt01-progress-cap` fixture with the existing harness, reported honestly in RESULTS.md with n stated.

**Non-goals**
- No new tier, no tier rename. LIGHT stays LIGHT; the intake cascade (R-103a) is unchanged.
- No change to EXPRESS, STANDARD, FULL state machines, ceremonies, or output shapes.
- No model tiering, context pre-supply, or companion changes (measured not to move wall).
- Not a change to what counts as evidence (R-64/R-65/R-68/R-70 unchanged).

## 3. Design

### 3.1 Two-dispatch LIGHT

```
INTAKE (driver, tier=LIGHT)
  └─ IMPLEMENTING  (IMPLEMENTER, fresh context)
        output = Implementation Package whose FIRST section is the LIGHT Plan
        ├─ scope exceeded / sensitive path found → R-105 path: no edit, promote tier, enter PLANNING at STANDARD
        └─ done → FULL_REVIEW (combined pass, as §0.5 LIGHT already allows)
              REVIEWER (fresh or persistent-reviewer context, never the implementer's — R-117)
              reviews the LIGHT Plan, the diff, and re-runs the machine ladder (R-110)
              ├─ GATE_MET → APPROVED
              ├─ findings, tier still LIGHT → FIXING (fixer shard; may revise plan section AND code) → FULL_REVIEW … (existing §2.3 budgets)
              └─ plan wrong at the tier level (should be STANDARD+) → REVIEWER raises tier (R-0a); driver enters PLANNING at the raised tier, counters per R-0b
```

- The **LIGHT Plan** is the §0.5 LIGHT-minimum Planning Document (problem statement, acceptance criteria, review scope, tooling declaration, plus the v4 fields the later stages consume: `change_class` R-114, `change_surface` R-122, tier justification) authored by the IMPLEMENTER *before it edits*, as the first section of its Implementation Package. At LIGHT the IMPLEMENTER's plan section carries the authority §3.2 gives the PLANNER (R-114 "PLANNER authoritative" reads as "plan author authoritative").
- "Plan first" survives inside the dispatch: the plan section is written before the diff, and the REVIEWER MUST treat plan defects (wrong ACs, missing review scope, misclassified surface/class) as findings with the normal severities. A plan that was never written, or written after the code (evidenced by the package's own ordering/timestamps where available), is a Blocker.
- "Plan reviewed by a separate context" survives: the REVIEWER is a distinct context and rejects the plan the same way PLAN_REVIEW does today; the difference is that at LIGHT the rejection lands after one ~5 min implementation instead of before it. This is the accepted trade: an always-paid ~12 min (PLANNING + PLAN_REVIEW) exchanged for a sometimes-paid ~5 min re-implementation.
- No new state. LIGHT transitions INTAKE → IMPLEMENTING directly; `PLANNING` and `PLAN_REVIEW` are simply not entered at LIGHT. `plan_iterations` stays 0 at LIGHT; plan defects consume `fix_iterations`.
- EXPRESS is the precedent (v4 already dropped the pre-review for a tier with its own independent gate); LIGHT-2D is the same move one rung up, with the full combined review kept.

### 3.2 Output caps (LIGHT only)

Narrative is capped; evidence is not.

| Artifact | Shape at LIGHT |
|---|---|
| LIGHT Plan (in Implementation Package §1) | ≤ ~25 lines total: problem (1–3 lines), ACs (one line each, ≥1 AC-F), review scope (file list), tooling declaration (command(s)), `change_class`, `change_surface`, tier justification. No other §3.2 sections, no `N/A` filler rows. |
| Implementation Package | plan section + touched-file list + machine-evidence output (real, per R-65; long output may be trimmed to the relevant lines with the total line count stated, never summarized in prose) + a ≤5-line change note. No narrative walkthrough. |
| Review Report (combined) | the YAML findings ledger (machine_evidence rungs + LLM findings) + per-AC status table + §8.3 checklist as a table + one-line verdict. No prose narrative outside a finding's own body. |
| Fix Report | ledger delta (finding id → status + one-line proof pointer) + re-run evidence. |

The caps are MUST for LIGHT, expressed as shape (which sections exist) rather than token counts, so they are checkable by a reviewer and by a grep in a test.

### 3.3 What changes on disk (expected; PLANNER scopes exactly)

- `protocol/core.md` §0.5 table row LIGHT + gate sentence; §2.1/2.2 state table + transition diagram LIGHT branch; new rules (numbering per history).
- `protocol/implementer.md` — LIGHT Plan section spec + cap; R-105 wording generalized to LIGHT.
- `protocol/reviewer.md`, `protocol/final-reviewer.md`, `protocol/fixer.md` — LIGHT shape of report/fix report; plan-defect findings at the combined pass.
- `protocol/planner.md` — note that at LIGHT the PLANNER is not dispatched.
- `protocol/orchestrator.md` — driver dispatch at LIGHT; run-record transitions.
- `protocol/history.md` — v4.2 row.
- `PROTOCOL.md` regenerated (`build-protocol.sh --check` green).
- `adapters/claude-code/HEATWAVE.md`, `GATE.md`, `role-gate.sh` no-edit-state list (LIGHT never enters PLANNING/PLAN_REVIEW; IMPLEMENTING already an edit state) + other adapters' prose; `prompts/` if they enumerate stages.
- `templates/` — LIGHT Implementation Package / review templates if templates exist per artifact.
- `docs/` — README/FAQ/loop.md/getting-started wherever "four dispatches"/LIGHT ceremony is described; `benchmark/RESULTS.md` addendum.

## 4. Acceptance criteria (spec-level; PLANNER refines into AC-F/AC-N)

- AC-1. A LIGHT run's Run Record shows exactly two role dispatches on the happy path (IMPLEMENTING, FULL_REVIEW-combined) and zero PLANNING/PLAN_REVIEW transitions.
- AC-2. The Implementation Package's first section is the LIGHT Plan and contains every field in §3.2 of this spec; a package without it is rejected by the reviewer as a Blocker (rule exists and the reviewer shard says so).
- AC-3. Plan defects are reviewable: the reviewer shard names plan-section findings (ACs, scope, class, surface) as in-scope for the combined pass with normal severities; tier-level misclassification routes to PLANNING at the raised tier (R-0a/R-0b), not to FIXING.
- AC-4. Output shapes of §3.2 are MUST at LIGHT and checkable (a deterministic check under the run dir demonstrates a conforming and a non-conforming package/report are told apart).
- AC-5. R-1/R-2/R-117 hold: the reviewer context is never the implementer's; the driver never resumes the implementer as reviewer.
- AC-6. `sh build-protocol.sh --check` exits 0; the rule count in README/history matches; no adapter or doc still describes LIGHT as PLANNING→PLAN_REVIEW→IMPLEMENTING→review.
- AC-7. **A/B measured** on lt01 via `benchmark/run.sh` (`CORPUS=corpus-tiering`, `HW_DEADLINE=1200`, n=2 new-arm runs; baseline = the existing terminal LIGHT run 094216Z ~31 min/$9.98 plus the E6 rows): each new-arm run reaches a terminal state, is classified LIGHT at intake, and passes the lt01 oracle. Wall and cost per run reported in RESULTS.md against the baseline with n stated; **no percentage claim beyond what n=2 supports.** Target (not a gate): ≤ 50% of baseline wall and cost. An honest miss is a valid result; a fabricated hit is a Blocker.
- AC-8. Zero new dependencies; `install.sh` delta 0 binaries; zero-config file unchanged in meaning.

## 5. Risks

- **Weaker plan gate at LIGHT.** Mitigated by: full combined review still reads the plan first; tier-level errors escalate to PLANNING at STANDARD; LIGHT is already bounded to non-sensitive, same-subsystem changes by R-102/R-103a.
- **Caps eroding evidence.** Mitigated by stating caps as shape on narrative only, with R-65 explicitly exempt.
- **Implementer self-serving plan** (writes ACs it already satisfied). Mitigated by the reviewer being told, in-shard, to check ACs against the task statement, not the diff.
- **Measurement noise.** n=2, generation variance ±3 min/stage (E6). Reported as directional; no significance claimed.

## 6. Roadmap context

Follows E7 (generation-bound finding, founder-accepted). Supersedes the "dispatch reduction via context reuse" line: this is dispatch reduction via structure. Sub-projects G/H unaffected.
