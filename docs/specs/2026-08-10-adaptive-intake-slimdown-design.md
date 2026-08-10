# Design Spec — Adaptive Intake + Slimdown (Heatwave Protocol v4, Sub-project A)

- **Date:** 2026-08-10
- **Status:** Draft, awaiting owner review
- **Scope:** Sub-project A of the Heatwave v4 redesign. Foundation only.
- **Author context:** brainstorming output; grounded in two web-cited research passes (SOTA gap analysis + ecosystem catalog).

---

## 1. Context & problem

Heatwave today runs the *same heavyweight loop for every task*. Even the lightest tier (LIGHT, §0.5) spawns a PLANNER, a separate PLAN_REVIEW context, an IMPLEMENTER, and a REVIEWER — a written plan reviewed by a separate context — for a change as small as red→white on a button. Two concrete costs:

1. **Ceremony doesn't collapse for trivial work.** There is no "just do it" tier. Worse, the tier is chosen *by the PLANNER* (§0.5 R-0a), so the run pays to spin up a planner context just to decide it didn't need one.
2. **Every role reloads the whole protocol.** The orchestrator dispatches each role in a fresh context with the entire 974-line `PROTOCOL.md` attached (`prompts/orchestrator.md`, step 2). Five-plus cold spawns per task each re-read ~974 lines + repo context. Research (see §8 refs) shows this fresh-full-context pattern forfeits a demonstrated 40–80% prompt-cache cost cut, and the doc itself is the largest recurring fixed token cost.

Two owner requirements motivate this sub-project directly:

- **Scale ceremony to task size.** A trivial change must *not* run the full pipeline.
- **Optional technical design docs.** For feature work, planning should optionally emit a beautiful technical design document — but not always (an existing repo already has designs), so it's gated by a question at intake, default off for existing-repo feature work.

## 2. Goals / non-goals

**Goals (this sub-project):**
- G1. Add intake triage: the cheap driver classifies each task into a ceremony tier *before* any fleet spawns.
- G2. Add an **EXPRESS** tier below LIGHT: trivial change → implementer + one cheap *independent* check, no planner/plan-review/full loop.
- G3. Add an optional **technical design document** gate at intake (styled Markdown), default off for existing-repo feature work.
- G4. **Slimdown + shard** the protocol so each role loads a small core spine + only its own role shard, not the full doc. Order context cache-friendly.
- G5. Introduce a compact structured **findings ledger** (YAML) as the inter-role review artifact.
- G6. Emit a structured **run-config** at intake (tier · design-doc · autonomy · scope) that the future graphical CLI (sub-project H) will surface unchanged.

**Non-goals (deferred to later sub-projects):**
- Heterogeneous reviewer model (B). *Note: config already supports per-role models — no work here.*
- Machine-evidence ladder: Semgrep / mutation adequacy / Strix / reproduce-then-fix (B, D).
- Per-stage model tiering, delta-only FINAL_REVIEW, persistent reviewer session (C).
- Ecosystem MCP wiring: Semgrep, Playwright, context7, gitleaks (D).
- Credibility benchmark (E). Positioning/README (F). Enterprise multi-repo mode (G). Graphical CLI (H).

## 3. Roadmap context (for the reader)

| # | Sub-project | Status |
|---|---|---|
| **A** | **Adaptive intake + slimdown** | **this spec** |
| B | Machine-evidence rigor layer (Semgrep/mutation/refute-or-promote/reproduce-then-fix/heterogeneous reviewer) | planned |
| C | Tiering + incremental review engine | planned |
| D | Ecosystem companions (Strix, Semgrep, gitleaks, Playwright, context7 — lazy/on-demand) | planned |
| E | Credibility benchmark (seeded-bug corpus, Heatwave vs raw) | planned |
| F | Positioning / README refresh | planned |
| G | Enterprise multi-repo autonomous mode | planned |
| H | Graphical mode-selector CLI (optional launcher; markdown stays core) | planned |

Autonomy ("run to completion, escalate only when a human is truly required") is **already** Heatwave core (§9.4 non-stop execution + §7.1 escalation triggers). It is exposed here as a run-config knob (G6), not rebuilt.

## 4. Design

### 4.1 Intake triage (new, pre-fleet)

The ORCHESTRATOR classifies every new task at intake, before dispatching any role. Classification is a cheap heuristic pass by the driver — no planner spawned.

**Tiers (extends §0.5):**

| Tier | Applies to | Pipeline |
|---|---|---|
| **EXPRESS** *(new)* | Single obvious edit: color/label/copy/typo/config-value. No new surface. | IMPLEMENTER → one independent check. No PLANNING, no PLAN_REVIEW. |
| LIGHT | Single-file fix, small new surface | Light plan → build → combined FULL+FINAL review (unchanged) |
| STANDARD | Feature/bugfix, one subsystem | Full loop (unchanged) |
| FULL | Cross-cutting: schema, auth, money, user data | Full loop + strict final checklist (unchanged) |

**Classification rules (driver, at intake):**
- **Sensitive-path denylist forces tier up.** If the task touches auth, payments/money, user data, schema/migrations, or public API surface → **minimum STANDARD**, EXPRESS forbidden. (Same spirit as existing FULL-tier triggers.)
- **EXPRESS is allowed only if all hold:** no sensitive path; estimated ≤ 2 files; no new dependency; no new public surface; the change is a single, locatable edit.
- The driver records the chosen tier + one-line justification in the run-config and run-record. When a PLANNER *is* spawned (LIGHT+), it may still raise the tier (never lower); the REVIEWER may raise at review (existing R-0a).

**Auto-promotion (reuses R-0b).** If the EXPRESS implementer finds the change is larger/riskier than classified, it emits a `scope_exceeded` signal instead of editing; the driver promotes to the appropriate tier and enters normal PLANNING. This is the existing Deviation Record path, applied to intake misclassification.

### 4.2 EXPRESS pipeline (new mini-path)

```
START → (driver classifies EXPRESS)
   → EXPRESS_IMPLEMENTING   (IMPLEMENTER: make the single change; or emit scope_exceeded)
   → EXPRESS_CHECK          (independent context, cheap:
                              1. machine gate — build + lint + relevant test pass (deterministic, ~0 LLM tokens)
                              2. confirmation glance — diff matches the request AND touches nothing sensitive)
   → gate met      → APPROVED
   → gate not met  → promote to LIGHT → PLANNING   (scope/quality was underestimated)
```

The independent check preserves Heatwave's core "no context reviews its own work" (R-1/R-2): the checker is a *fresh* context, and the primary gate is a deterministic machine run, not the implementer's own say-so. It drops the planner, the plan-review, and the full review/fix loop. Minimal run-record entries keep the run resumable (R-88).

### 4.3 Technical design document gate (new)

- At intake the driver resolves `design_doc` from config (`ask` | `always` | `never`); when `ask`, it asks the owner once: *"Generate a technical design doc for this?"* Default resolution when unset: **existing repo → `never` unless asked; greenfield/new area → `ask`.**
- Applies to **STANDARD / FULL only.** EXPRESS and LIGHT never generate design docs.
- When enabled, the PLANNER emits a **styled-Markdown technical design** from a new template `templates/technical-design.md` — sections: Context · Goals / Non-goals · Architecture · Data flow · Alternatives considered · Risks · Test strategy — committed to `docs/design/<task-id>.md` (path configurable). It is an **input to** the Planning Document (referenced by it), never a replacement for it. The Planning Document's acceptance criteria and gates are unchanged.

### 4.4 Slimdown + shard (the token foundation)

**Canonical inversion:** today `PROTOCOL.md` is the single source and is loaded whole. New model:

- **Shards become canonical.** A small **core spine** `protocol/core.md` (~150 lines: roles, decision authority, state machine + transitions, tiers, counters/budgets, completion gate, resume rule) + **per-role shards** carrying only that role's normative rules:
  - `protocol/planner.md` ← §3.2 planning contract, §4.1, §6.1 tooling, §0.5 tiers, design-doc gate
  - `protocol/implementer.md` ← §3.3, §4.3, EXPRESS implementer rules, ponytail (Appendix G)
  - `protocol/reviewer.md` ← §4.4/4.6/4.7, §5 review rules, §8 gate, Appendix A finding schema, findings-ledger contract
  - `protocol/fixer.md` ← §3.5 fix contract, §4.5
  - `protocol/final-reviewer.md` ← §4.7, §8.3 readiness, LIGHT combined-pass rules
  - `protocol/orchestrator.md` ← §9 driver, intake triage, run-config
- **`PROTOCOL.md` becomes a generated artifact:** `build-protocol.sh` concatenates core + shards into the canonical human-readable `PROTOCOL.md`. One source of truth; the full doc is a rendered view. A CI/self-check asserts `PROTOCOL.md` equals the regenerated concatenation (drift guard).
- **Dispatch change (`orchestrator.md` step 2):** each role is handed **`protocol/core.md` + its role shard + config + permitted artifacts** — not the full `PROTOCOL.md`.
- **Cache-friendly ordering:** dispatch context is assembled as `[core spine][role shard][config]` (stable prefix, identical across tasks) then `[task artifacts]` (dynamic) last, so the stable prefix is cacheable.

Result: a role loads ~250–300 lines (core + its shard) instead of 974, and the stable prefix is reused across dispatches.

### 4.5 Compact findings ledger (new inter-role artifact)

- The artifact passed REVIEWER → FIXER → REVIEWER becomes `findings.yaml` (`templates/findings-ledger.yaml`): each finding `{ id, file, line, severity, category, evidence_ref, status }`. The FIXER answers by finding `id`.
- The prose Review Report (`templates/review-report.md`) is retained as a **rendered human view** with a short summary; the YAML ledger is the machine-passed source. This penalizes reviewer verbosity (a measured judge bias) and shrinks inter-role token transfer.

### 4.6 Run-config (new, forward-compatible with H)

At intake the driver writes a `run_config` block into `run-record.yaml`:

```yaml
run_config:
  tier: EXPRESS | LIGHT | STANDARD | FULL   # active in A
  design_doc: true | false                   # active in A (STANDARD/FULL only)
  autonomy: autopilot                        # reserved (G/H): autopilot | gated | interactive; default autopilot = current behavior
  scope: single_repo                         # reserved (G): single_repo | multi_repo; default single_repo
```

Only `tier` and `design_doc` drive behavior in A. `autonomy` and `scope` are recorded with defaults that reproduce today's behavior; the graphical CLI (H) and enterprise mode (G) will activate them without changing this schema. No branching logic is built for the reserved fields in A (YAGNI) — they are declared, defaulted, and documented only.

## 5. Affected files

**New:**
- `protocol/core.md`, `protocol/{planner,implementer,reviewer,fixer,final-reviewer,orchestrator}.md` (canonical shards)
- `build-protocol.sh` (assemble `PROTOCOL.md`; drift self-check)
- `templates/technical-design.md`, `templates/findings-ledger.yaml`

**Modified:**
- `prompts/orchestrator.md` — intake triage, run-config, design-doc question, EXPRESS path, shard-based dispatch, cache ordering
- `PROTOCOL.md` — now generated; §0.5 gains EXPRESS row; §2 gains intake + EXPRESS states/transitions; §2.4 gains run-config
- `prompts/*.md` — reference shards instead of full protocol where applicable
- `templates/run-record.yaml` — `run_config` block
- `heatwave.config.example.yaml` — `design_doc: ask|always|never`, EXPRESS settings, `design_doc_path`
- `install.sh` — copy new shard/template files into `.heatwave/`

## 6. Alternatives considered

1. **Keep tier selection in the PLANNER (status quo).** Rejected: pays to spawn a planner just to decide ceremony; the whole point is to classify before the fleet.
2. **EXPRESS with zero verification.** Rejected by owner: keep one cheap independent check — dropping independent verification breaks Heatwave's core promise even for tiny changes.
3. **Design doc as a rendered HTML artifact.** Rejected by owner for now: styled Markdown is git-native, portable across tools, and lazy. (Revisit as an optional render in H.)
4. **Keep `PROTOCOL.md` canonical and hand-maintain separate shards.** Rejected: two sources of truth drift. Shards canonical + generated `PROTOCOL.md` + drift check is the clean inversion.
5. **Full rewrite of the protocol.** Rejected: the rules are sound; the problem is packaging and intake, not content. Extract, don't rewrite.

## 7. Risks & mitigations

| Risk | Mitigation |
|---|---|
| Shard ↔ `PROTOCOL.md` drift | `PROTOCOL.md` generated from shards; self-check asserts equality |
| EXPRESS misclassification (a "trivial" change that wasn't) | sensitive-path denylist + ≤2-file/no-new-surface rule + mandatory machine gate + auto-promotion on `scope_exceeded` |
| Cache-ordering assumptions vary by tool/adapter | order is a best-effort optimization, not a correctness dependency; document, never require |
| Breaking resume of in-flight runs | new run-record fields are optional with defaults reproducing current behavior; existing states resume unchanged (R-88) |
| Design doc diverging from the plan | design doc is an *input referenced by* the Planning Document, not a parallel authority; plan gates unchanged |

## 8. Verification strategy (evidence, not assertion)

Heatwave is Markdown + shell; "tests" are **live adapter runs against a throwaway target repo** through the claude-code adapter, plus deterministic self-checks. Required evidence before this sub-project is APPROVED:

1. **EXPRESS skips the fleet.** Run a color-change task; transcript shows NO PLANNING/PLAN_REVIEW dispatch — only implementer + independent check — ending APPROVED. Evidence: run-record + dispatch transcript.
2. **Sensitive-path guard.** An auth-touching "small" change is refused EXPRESS and classified ≥ STANDARD. Evidence: run-record tier + justification.
3. **Auto-promotion.** An EXPRESS task whose implementer emits `scope_exceeded` promotes to LIGHT/PLANNING. Evidence: run-record transition.
4. **Design-doc gate.** A STANDARD task with `design_doc: true` produces `docs/design/<task>.md` referenced by the plan; with `false`, none is produced. Evidence: file presence/absence + plan reference.
5. **Shard loading.** Each role dispatch loads core + its shard, not full `PROTOCOL.md`. Evidence: dispatch payload inspection; measured context-size drop vs baseline.
6. **Generation drift check.** `build-protocol.sh` regenerates `PROTOCOL.md` byte-identical to the committed file. Evidence: self-check exit 0.
7. **Regression.** A normal STANDARD feature still completes the full loop to APPROVED. Evidence: full run-record.
8. **Findings ledger.** A review round produces `findings.yaml`; the fixer answers by id; the ledger drives TARGETED_REVIEW. Evidence: artifacts.

Tooling that is unavailable is declared explicitly (R-64), never silently skipped.

## 9. Open questions

None blocking. Reserved run-config fields (`autonomy`, `scope`) are intentionally inert until G/H.
