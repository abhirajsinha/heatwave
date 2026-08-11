# Heatwave Protocol — core (canonical shard)

Loaded by: every dispatch, all states. Section/rule numbers are global to the protocol.

---

# Heatwave — AI Development & Verification Protocol

**Version:** 4.0
**Status:** Active
**Supersedes:** v3.1 (open-source release)

Heatwave is a tool-agnostic protocol for AI-performed software development. It works with any coding agent — Claude Code, Codex, Gemini CLI, Cursor, or a plain chat session — because it governs *contexts and artifacts*, not any vendor's features. See `README.md` for installation and the per-tool adapters.

### Shard map

From v4 the protocol is maintained as canonical shards in `protocol/`; the full rendered spec is generated from them (R-108) and reads core-then-roles rather than in strict numeric order. Section and rule numbers are global and stable across shards — every v3.1 cross-reference remains valid.

| Shard | Carries | Loaded by |
|---|---|---|
| `protocol/core.md` | §0 purpose & tiers, §1 roles, §2 state machine & run-config, §3.1 artifact ground rules, §5.4 blast radius, §6.2/§6.4–§6.5 tool unavailability, evidence & companions, §8.1–8.2/§8.4 completion gate, §9.3 resume rule | every dispatch |
| `protocol/planner.md` | §3.2 (excl. 3.2.1) Planning Document, §3.2.2 acceptance criteria, §3.2.3 design doc *(v4)*, §4.1, §5.1 review scope, §6.1 tooling declaration, Appendices B & C | PLANNING; PLAN_REVIEW |
| `protocol/implementer.md` | §3.2.1 deviations, §3.3 Implementation Package, §4.3, §4.8 EXPRESS *(v4)*, §6.3 test types, Appendix G ponytail | IMPLEMENTING; EXPRESS_IMPLEMENTING |
| `protocol/reviewer.md` | §3.4 Review Report, §3.4.1 findings ledger *(v4)*, §4.2, §4.4, §4.6, §5.2–5.3, §5.5–5.6, §7.2 escalation report, Appendix A | PLAN_REVIEW; FULL/TARGETED/FINAL_REVIEW; ESCALATED |
| `protocol/fixer.md` | §3.5 Fix Report, §4.5 | FIXING |
| `protocol/final-reviewer.md` | §4.7, §8.3 production readiness | FINAL_REVIEW |
| `protocol/orchestrator.md` | §3.6, §7.1, §7.3, §9.1–9.2, §9.4–9.5, §9.6–9.7 shard dispatch & generation *(v4)* | the driver (intake) |
| `protocol/history.md` | Appendix F change history | never dispatched |

---

## 0. About This Document

### 0.1 Purpose

This protocol governs how features are planned, implemented, reviewed, tested, and approved when the work is performed by AI models. It defines who may make which decisions, what each stage must produce, how the workflow advances, and what "done" means.

It is a specification, not a prompt. Individual stages are driven by prompts derived from this document, but the document itself is the source of truth.

### 0.2 Design principles

1. **Separation of concerns.** No context evaluates its own output.
2. **Explicit authority.** Every decision has exactly one owner.
3. **Traceability.** Every claim of verification is backed by evidence or an explicit statement of its absence.
4. **Bounded loops.** Every loop has a budget and a defined behavior at exhaustion.
5. **Scope discipline.** Review effort is scoped deliberately, and scope changes are recorded, not assumed.
6. **Role-based configuration.** Model names appear in configuration, never in the workflow body.

### 0.3 Conformance language

**MUST** / **MUST NOT** — absolute requirement. Violation invalidates the run.
**SHOULD** / **SHOULD NOT** — recommended; deviation requires a recorded reason.
**MAY** — optional.

### 0.4 Scope of application

This protocol applies to any change intended to reach production. Purely exploratory work, spikes, and throwaway prototypes are out of scope and MUST be labeled as such at the outset. A spike that is later promoted to production work re-enters this protocol at Section 4.1 (PLANNING).

### 0.5 Change tiers

Ceremony scales to the change; independent verification does not. Every tier except EXPRESS keeps all four gates: a plan reviewed by a separate context, distinct role contexts, evidence over assertion, and the completion gate (Section 8) — what those tiers change is how much of the Planning Document must be written out. EXPRESS (v4) drops the plan and its review but substitutes its own independent gate: a deterministic machine check plus a confirmation glance by a fresh context that did not make the change (R-104). No tier, including EXPRESS, ever lets a context approve its own work.

| Tier | Applies to | Planning Document | Reviews |
|---|---|---|---|
| **EXPRESS** *(v4)* | A single obvious edit: copy, label, color, config value, typo. No new surface. | None — no Planning Document. | No PLAN_REVIEW. IMPLEMENTER makes the change; one independent EXPRESS_CHECK (deterministic machine gate + fresh-context confirmation glance) gates APPROVED. Any failure promotes to LIGHT — EXPRESS never loops. |
| **LIGHT** | Single-file fixes, copy changes, config tweaks with no new surface | Problem statement, acceptance criteria (may be a single AC-F), review scope, tooling declaration. All other sections MAY be collapsed to one `N/A — LIGHT tier` line each. | PLAN_REVIEW still precedes IMPLEMENTING. FULL_REVIEW and FINAL_REVIEW MAY be combined into one REVIEWER pass (full evaluation + per-criterion acceptance status + readiness checklist). A combined pass that fails behaves as a FINAL_REVIEW failure: → FIXING, increments `final_iterations`, next review is FULL (R-14). |
| **STANDARD** | A feature or bugfix touching one subsystem | All sections; N/A allowed per R-20. | Full state machine. |
| **FULL** | Cross-cutting changes: schema migrations, auth, new services, anything touching money or user data | All sections, no collapsed entries; non-functional criteria mandatory. | Full state machine; FINAL_REVIEW checklist (8.3) item-by-item. |

**R-0a.** The PLANNER proposes the tier in the Planning Document with one line of justification; the REVIEWER MAY raise it (never lower it) at PLAN_REVIEW.

**R-0b.** Tier selection is recorded in the Run Record. A change that grows beyond its tier mid-implementation is a Deviation Record (3.2.1) and re-enters PLAN_REVIEW at the higher tier.

**R-101.** *(v4)* The driver classifies every new task into a tier at intake, before dispatching any role, and records the tier plus a one-line justification in `run_config` and the Run Record. When a PLANNER is spawned (LIGHT+), it MAY raise the tier, never lower it; the REVIEWER MAY raise it at review (R-0a).

**R-102.** *(v4)* A task touching authentication, payments/money, user data, schema/migrations, or public API surface MUST be classified STANDARD or higher. EXPRESS is forbidden on these paths.

**R-103.** *(v4)* EXPRESS applies only when ALL hold: no sensitive path (R-102); estimated ≤ 2 files; no new dependency; no new public surface; the change is a single, locatable edit. Any doubt resolves upward.

**Machine-evidence rigor by tier** *(v4)* — review is machine-first and scales with tier:

| Tier | Machine-evidence ladder (R-110) | Refute-or-promote (R-112) | Reproduce-then-fix, bugfix class (R-113) |
|---|---|---|---|
| EXPRESS | none — R-104's machine gate is unchanged | no | no |
| LIGHT | declared test command(s) | yes (Major+) | yes |
| STANDARD | tests + SAST scan of the diff | yes (Major+) | yes |
| FULL | tests + SAST + mutation adequacy on changed modules | yes (Major+) | yes |

All tiers with a FINAL_REVIEW add the `secrets` rung there when a scanner is present (R-121); dynamic security is opt-in per R-119.

**R-110.** *(v4)* At FULL_REVIEW (including the LIGHT combined pass, and FINAL_REVIEW per R-44) the REVIEWER MUST run the machine-evidence ladder for the run's tier — executing each rung itself, not trusting outputs attached by other roles — and record every rung's verdict in the findings ledger (`machine_evidence`) BEFORE authoring any LLM finding. Rungs consume the plan's tooling declaration (§6.1): `tests` = the declared test command(s); `sast` (STANDARD and FULL) = a static scan of the diff with the declared `sast` tool; `mutation` (FULL only) = mutation adequacy of the changed modules with the declared `mutation` tool, scoped to changed modules and bounded by the declared timeout. A rung whose tool is undeclared or unavailable records `verdict: NOT_AVAILABLE` naming the acceptance criteria it leaves unverified (R-64) — never a silent skip. The protocol names the checks, never specific tools. At FINAL_REVIEW every rung is re-run from scratch — no prior verdict survives by reference (R-118(b), R-117 safety clause; *v4-C supersedes B's carry-forward allowance*).

---

## 1. Roles & Responsibilities

### 1.1 Role definitions

The protocol defines four roles. Three are AI-performed; one is human.

| Role | Performs | Decides |
|---|---|---|
| **PLANNER** | Requirements analysis, architecture, acceptance criteria, initial review scope | What to build and how |
| **IMPLEMENTER** | Code, tests, fixes, evidence collection | How to satisfy the plan within its constraints |
| **REVIEWER** | Plan review, feature review, severity classification, deferral approval, final approval | Whether the work is correct and complete |
| **OWNER** (human) | Escalation decisions, protocol waivers, scope arbitration | Everything the roles above cannot resolve |

### 1.2 Context isolation

**R-1.** PLANNER, IMPLEMENTER, and REVIEWER MUST occupy three mutually distinct contexts. No context may hold the conversational history of another role for the same task.

**R-2.** A REVIEWER context MUST NOT have authored any artifact it is reviewing. This applies to plan review as well as feature review: the context that reviews the Planning Document MUST NOT be the context that wrote it.

**R-3.** The REVIEWER receives artifacts, not conversations. Specifically, the REVIEWER is given: the Planning Document, the Implementation Package, the prior Review Reports for this task (if any), and the Fix Reports responding to them. It is not given the PLANNER's or IMPLEMENTER's reasoning transcripts.

**R-4.** Review continuity across iterations is permitted and preferred — the same REVIEWER context MAY carry through iterations 1..N, since finding reconciliation (Section 5.6) depends on it. If context limits force a fresh REVIEWER, the prior Review Reports MUST be supplied and the new context MUST perform reconciliation from them.

> **Rationale for R-2.** In v2, PLANNER and REVIEWER shared a preferred model and overlapping responsibilities, which meant the plan was reviewed by its author and, later, the acceptance criteria were validated by the party who wrote them. Both are self-review. The cost of R-2 is one additional context; the benefit is that plan defects are caught before they become implementation defects, which is where they are cheapest to fix.

**R-117.** *(v4)* **Persistent reviewer session.** For one task, the REVIEWER context SHOULD persist across FULL_REVIEW → TARGETED_REVIEW → FINAL_REVIEW where the host tool can resume a context (this operationalizes R-4's continuity preference); where it cannot, the driver degrades to a fresh context **explicitly** — recorded in the Run Record, never silent. A persistent reviewer retains its findings ledger and finding memory between passes. The IMPLEMENTER context is never shared with, or resumed as, the reviewer — R-1/R-2 are unchanged: the isolation boundary is authorship, and the reviewer authored no code. **Safety clause:** FINAL_REVIEW MUST re-run all machine evidence for the tier from scratch (R-110, R-118(b)) and re-confirm every acceptance criterion with fresh evidence regardless of session continuity — a persistent session reuses *context*, never a *prior verdict*. Config `fresh_final_reviewer: true` forces a cold FINAL_REVIEW context. The driver records `review_session: persistent | fresh-degraded | fresh-configured` in the Run Record.

### 1.3 Decision authority

**R-5.** Severity classification is owned exclusively by the REVIEWER. The IMPLEMENTER MAY propose a reclassification in the Fix Report, with argument. The REVIEWER MUST respond to the proposal in the next Review Report, either accepting it (with the finding's severity updated and the change recorded) or rejecting it (with reason).

**R-6.** Deferral of a finding requires REVIEWER approval. The IMPLEMENTER MUST NOT unilaterally defer. A finding is deferred only when the Review Report records it as `Status: Deferred (approved)`.

**R-7.** The IMPLEMENTER MUST NOT modify the Planning Document, acceptance criteria, or review scope. It MAY request changes via a Deviation Record (Section 3.2.1).

**R-8.** The REVIEWER MAY expand review scope (Section 5.2). The REVIEWER MUST NOT narrow scope below what the approved plan specifies; narrowing requires OWNER approval.

**R-9.** Only the OWNER may waive any MUST in this protocol. Waivers MUST be recorded in the Run Record with scope and reason.

> **Rationale for R-5 and R-6.** In v2 the IMPLEMENTER wrote the Fix Report, which contained deferrals and their reasons — meaning the party motivated to finish decided what could be skipped. Downgrade-to-Minor-then-defer was an open path around the completion gate. Moving both decisions to the REVIEWER closes it without preventing legitimate disagreement, which now has a recorded channel.

### 1.4 Role configuration

**R-10.** Model assignment MUST be specified in a configuration block external to the workflow body, in the form:

```yaml
roles:
  planner:
    preferred: <model-id>
    fallback: <ordered list, best reasoning model available>
  implementer:
    preferred: <model-id>
    fallback: <ordered list, strongest implementation model available>
  reviewer:
    preferred: <model-id>
    fallback: <ordered list, best reasoning model available>
    # MUST resolve to a different context from planner; MAY be the same model
```

**R-11.** If a preferred model is unavailable, the highest-ranked available fallback is used automatically and the substitution MUST be recorded in the Run Record. The workflow does not change based on which model fills a role.

**R-12.** The same underlying model MAY fill multiple roles provided R-1 and R-2 (distinct contexts) hold. Model identity is not the isolation boundary; context is.

*(v4)* Stage-level model selection — `cheap_model`, `stage_models`, `small_diff_threshold`, `fresh_final_reviewer` — is likewise configuration, never workflow-body prose: see R-116/R-117 and `heatwave.config.example.yaml`. Unset, all of it, reproduces the R-10 role resolution exactly.

**R-115.** *(v4)* The reviewer role SHOULD resolve to a different model family from the implementer — a same-model reviewer under-critiques work in its own style, and uncorrelated blind spots are the cheapest review upgrade — but this is never required: zero-config (the session model in all roles) remains fully valid. When BOTH the implementer and reviewer roles have resolved for the run — at the first FULL_REVIEW (or LIGHT combined-pass) dispatch — the driver MUST compare the resolved models and record in the Run Record `hetero_reviewer: "true"` when they differ, or `hetero_reviewer: "false (self-preference bias not mitigated)"` when they are the same. The advisory is written by SETTING the record's `hetero_reviewer` field — the scalar key the run-record template already carries — never by appending a line mid-file or duplicating the key, so the record remains valid YAML; timing is evidenced by record snapshots at dispatch, not by insertion position. If either role's resolved model subsequently changes (R-11 substitution), the driver recomputes and sets the field to the updated value (the substitution entry R-11 already requires preserves the history). Advisory only — it never gates and changes no workflow step.

**R-116.** *(v4)* **Stage model-tiering.** A run MAY route mechanical stages to a configured cheap model (`cheap_model` in `heatwave.config.yaml`). With no tiering config, every stage runs on the role's configured/preferred model, else the session model — zero-config behavior is unchanged. At each dispatch the driver selects the stage's model: a cheap-eligible stage with `cheap_model` configured runs on the cheap model unless `stage_models` routes it back; every other stage runs on the role's preferred/session model. The two sets are fixed by this rule — configuration MAY narrow the eligible set, it MUST NOT widen it:

| Cheap-eligible (mechanical) | Frontier-required (rigor) |
|---|---|
| EXPRESS_CHECK | FULL_REVIEW |
| Artifact summarization performed by the driver | FINAL_REVIEW (including the LIGHT combined pass) |
| PLAN_REVIEW when tier ∈ {EXPRESS†, LIGHT} | PLAN_REVIEW when tier ∈ {STANDARD, FULL} |
| TARGETED_REVIEW when the fix delta ≤ `small_diff_threshold` changed lines | TARGETED_REVIEW above the threshold |

† vacuous — EXPRESS has no PLAN_REVIEW (§0.5); listed for completeness of the eligible set.

A `stage_models` entry that routes a frontier-required stage to the configured cheap model is **rejected**: the driver records a one-line warning in the Run Record and dispatches that stage on the role's preferred/session model. An entry naming an unknown stage is ignored with the same warning. The model that served each stage is recorded per dispatch (`stage_model` in the Run Record transitions). Model identity never changes what a gate requires — tiering changes how cheaply the same gates run, never the gates.

---

## 2. Workflow State Machine

### 2.1 States

| State | Owner | Exit condition |
|---|---|---|
| `EXPRESS_IMPLEMENTING` *(v4)* | IMPLEMENTER | EXPRESS Change note produced |
| `EXPRESS_CHECK` *(v4)* | independent checker | EXPRESS Check report produced |
| `PLANNING` | PLANNER | Planning Document produced |
| `PLAN_REVIEW` | REVIEWER | Plan approved or rejected |
| `IMPLEMENTING` | IMPLEMENTER | Implementation Package produced |
| `FULL_REVIEW` | REVIEWER | Review Report produced |
| `FIXING` | IMPLEMENTER | Fix Report produced |
| `TARGETED_REVIEW` | REVIEWER | Review Report produced |
| `FINAL_REVIEW` | REVIEWER | Review Report produced |
| `ESCALATED` | OWNER | Owner Decision Record produced |
| `APPROVED` | — | Terminal |
| `ABANDONED` | — | Terminal |

### 2.2 Transitions

```
START → intake (driver, R-101; writes run_config)
  ├─ EXPRESS → EXPRESS_IMPLEMENTING
  │              ├─ change made      → EXPRESS_CHECK
  │              └─ scope_exceeded   → PLANNING   [tier promoted per R-105]
  │            EXPRESS_CHECK
  │              ├─ pass → APPROVED
  │              └─ fail → PLANNING              [tier promoted to ≥ LIGHT, R-104; no fix loop]
  └─ LIGHT | STANDARD | FULL → PLANNING
        └─→ PLAN_REVIEW
              ├─ rejected ──→ PLANNING            [increments plan_iterations]
              └─ approved ──→ IMPLEMENTING
                                └─→ FULL_REVIEW
                                      ├─ gate met ─────→ FINAL_REVIEW
                                      └─ gate not met ─→ FIXING
                                                          └─→ TARGETED_REVIEW
                                                                ├─ gate met ─────→ FINAL_REVIEW
                                                                └─ gate not met ─→ FIXING
                                                                      [increments fix_iterations]

FINAL_REVIEW
  ├─ gate met ──────→ APPROVED
  └─ gate not met ──→ FIXING  [increments final_iterations; next review is FULL_REVIEW, not TARGETED]

Any state
  ├─ budget exhausted ──→ ESCALATED
  └─ OWNER intervention ─→ ESCALATED

ESCALATED
  ├─ owner: continue ──→ <resume state per Owner Decision Record; counters reset per §7.3>
  ├─ owner: replan ────→ PLANNING [all counters reset]
  └─ owner: abandon ───→ ABANDONED
```

**R-104.** *(v4)* EXPRESS runs `EXPRESS_IMPLEMENTING → EXPRESS_CHECK`. The check is performed by a context that did not make the change (R-1/R-2) and consists of (1) a deterministic machine gate — the project's build, lint, and tests relevant to the touched files — and (2) a confirmation glance — the diff does what was asked, touches ≤ 2 non-sensitive files, adds no dependency or public surface. Pass → `APPROVED`. Any failure → the driver promotes the run to LIGHT (or higher per R-102/R-103) and enters `PLANNING` with counters at 0. EXPRESS has no fix loop.

### 2.3 Counters and budgets

Three independent counters:

| Counter | Increments on | Budget | At exhaustion |
|---|---|---|---|
| `plan_iterations` | Each plan rejection | 3 | → `ESCALATED` |
| `fix_iterations` | Each FIXING entry from TARGETED_REVIEW | 5 | → `ESCALATED` |
| `final_iterations` | Each FIXING entry from FINAL_REVIEW | 2 | → `ESCALATED` |

**R-13.** The three budgets are independent and MUST NOT be pooled. A project MAY override the budget values in `heatwave.config.yaml` with OWNER approval; the values above are the defaults.

> **Rationale.** A feature that converges slowly (4 fix iterations) and a feature whose fixes cause regressions (failures at final review) are different pathologies with different remedies. Sharing one counter conflates them and, worse, punishes the first by leaving no budget for the second. Separate counters also make the escalation report diagnostic: which counter blew tells the OWNER what went wrong.

**R-14.** Re-entry into `FIXING` from `FINAL_REVIEW` MUST be followed by `FULL_REVIEW`, never `TARGETED_REVIEW`. A regression escaping into final review is evidence that blast-radius reasoning failed for this task; targeted review is no longer trustworthy for it.

**R-118.** *(v4)* **Delta-only FINAL_REVIEW.** FINAL_REVIEW scope is exactly: **(a)** confirm every open finding from prior reviews is closed in the findings ledger; **(b)** re-run ALL machine gates for the run's tier (build/drift, tests, SAST, mutation per R-110; secrets per R-121) — regardless of any prior verdict, carry-forward, or session continuity; **(c)** LLM review of only the **delta** — the diff since the last FULL_REVIEW, `git diff <last-full-review-sha>..HEAD`, where the driver captured `<last-full-review-sha>` at that FULL_REVIEW's transition. The delta is FINAL_REVIEW's required reading scope: the REVIEWER MUST NOT re-read files unchanged since that SHA as routine re-review. R-8/R-54 discretion survives at FINAL only as a **recorded scope expansion (R-49)**: a reviewer with grounds to suspect a delta change regressed a specific unchanged file MAY read exactly what substantiates that suspicion — the delta is the floor of FINAL reading, not a gag on a grounded suspicion; blanket re-reading of unchanged files remains forbidden. **(d)** re-confirm every acceptance criterion with evidence (R-27). The driver computes the range, supplies the diff, and records it in the Run Record (`final_delta_range`). Where no last-FULL_REVIEW SHA is recorded (pre-v4-C record, unresolvable repo state) or the working tree is dirty at dispatch, FINAL_REVIEW degrades to full scope **explicitly** — recorded, never a guessed range. The LIGHT combined FULL+FINAL pass has no prior FULL_REVIEW and always evaluates in full. A FINAL_REVIEW failure still routes to FIXING with the next review a FULL_REVIEW (R-14) — (b) is the in-pass regression backstop, R-14 the cross-pass one.

### 2.4 Run Record

**R-15.** Every task MUST maintain a Run Record from `START` to terminal state. The schema is `templates/run-record.yaml` (normative; v4 — replaces Appendix E). It is append-only.

### 2.5 Run-config *(v4)*

Written by the driver at intake into `run-record.yaml`:

```yaml
run_config:
  tier: EXPRESS            # EXPRESS | LIGHT | STANDARD | FULL — active
  tier_justification: ""   # one line, R-101 — active
  design_doc: false        # true | false — active (STANDARD/FULL only)
  change_class: feature    # v4: bugfix | feature — driver initial, PLANNER authoritative (R-114) — active
  autonomy: autopilot      # RESERVED (G/H): autopilot | gated | interactive — recorded only, no branching (YAGNI)
  scope: single_repo       # RESERVED (G): single_repo | multi_repo — recorded only, no branching (YAGNI)
```

**R-106 (driver half).** *(v4)* At intake the driver resolves `design_doc` from config (`ask` | `always` | `never`; unset defaults: existing repo → `never`, greenfield/new area → `ask`, asked once) and records it in `run_config`. It applies to STANDARD/FULL only; EXPRESS and LIGHT never generate one. *(The planner half — emitting the document — is §3.2.3.)*

**R-114.** *(v4)* At intake the driver records `change_class` in `run_config`: `bugfix` when the task's purpose is to correct defective existing behavior, else `feature`. The PLANNER declares the authoritative class in the Planning Document with one line of justification and MAY correct the driver's value (the correction is recorded in the Run Record). EXPRESS runs never carry a change class — EXPRESS has no plan. Misclassification is a valid REVIEWER finding. Only `bugfix` alters behavior (R-113); a record without the field reads `feature`.

Only `tier`, `tier_justification`, `design_doc`, and `change_class` drive behavior. `autonomy` and `scope` are RESERVED for sub-projects G/H: recorded with defaults that reproduce current behavior, consulted by nothing (YAGNI). A Run Record without a `run_config` block (pre-v4) is read as `tier` from `state.yaml`, `design_doc: false`, `autonomy: autopilot`, `scope: single_repo`, `change_class: feature`.

---

## 3. Artifacts & Contracts

### 3.1 General rules

**R-16.** Every state transition MUST be accompanied by its artifact. A transition without its artifact is invalid.

**R-17.** Artifacts are the sole interface between roles. If information is not in an artifact, the receiving role does not have it.

**R-18.** Every artifact MUST carry: `task_id`, `artifact_type`, `iteration`, `produced_by` (role + resolved model), `timestamp`.

Artifact skeletons are the files in `templates/`; they are normative. *(v4: replaces Appendix D, which duplicated them.)*

---

### 5.4 Blast radius

**R-53.** The IMPLEMENTER MUST declare blast radius in the Implementation Package and in every Fix Report, containing: components touched, components consuming those components, shared state or schema affected, contracts affected, and reasoning for the boundary drawn.

**R-54.** Blast radius is a claim, not a constraint on the REVIEWER. The REVIEWER MAY review outside the declared radius, and an inaccurate declaration is a finding (`Category: blast-radius`, minimum severity Major).

> **Rationale for R-54.** Targeted review is only as sound as the radius declaration, and the party declaring it is the party who benefits from it being small. Making inaccuracy a Major finding — rather than a shrug — is what keeps the declaration honest enough to rely on.

---

### 6.2 Tool unavailability

**R-64.** When a required tool is unavailable, the role MUST state explicitly: which tool, what it would have verified, which acceptance criteria are consequently unverified, and what was done instead (if anything).

**R-65.** A role MUST NOT assert verification it did not perform. Asserted verification without evidence is a Blocker (`Category: verification-integrity`).

**R-66.** Unverified acceptance criteria MUST NOT be marked satisfied. A feature with unverified criteria cannot reach `APPROVED`; it MUST escalate to OWNER, who MAY accept the gap via waiver (R-9).

> **Rationale for 6.2.** This is the protocol's most likely silent failure. v2 handled it correctly for backend ("if tooling is unavailable, the review must explicitly state what could not be verified") and then omitted the same sentence from the mobile and web sections — which are precisely the environments an AI reviewer is least likely to actually have. Absent an explicit rule, a model asked "did you test every button on the iOS Simulator?" will produce a plausible account of having done so. The rule generalizes v2's backend sentence to every test type and adds the consequence: unverified criteria block approval rather than passing on narration.

### 6.4 Evidence

**R-68.** Every test claim MUST be accompanied by evidence: command output, run logs, trace artifacts, screenshots, or an explicit `unavailable: <reason>`.

**R-69.** The Review Report verification log (§7) MUST enumerate: what was verified, by what method, with what result, and what was not verified and why.

**R-70.** "Verified" without a method is non-conforming and MUST be treated as unverified.

### 6.5 Companion tools *(v4-D)*

Companions are external tools Heatwave detects and uses, never dependencies. This section does not amend R-110: the `tests`/`sast`/`mutation` rungs remain tool-agnostic and any equivalent declared tool satisfies its rung — the names below are verified bindings a repo MAY present, not requirements. Setup and the full catalog: `COMPANIONS.md`.

| Companion | Stage | Trigger | Cost | Default |
|---|---|---|---|---|
| gitleaks | FINAL_REVIEW (+pre-commit) | detected; every run with a FINAL | ~0 | auto-when-present |
| Semgrep | FULL_REVIEW (SAST rung) | detected; STANDARD+ changed paths | ~0 | auto-when-present |
| Mutation (Stryker/mutmut/PIT) | FULL_REVIEW (mutation rung) | detected; FULL, changed modules | CPU | auto-when-present |
| `/security-review` | FULL_REVIEW | change_surface ∩ {auth, external-input, deps, secrets, api-surface} | med tokens | on (Claude Code) |
| Playwright MCP | FULL/FINAL evidence capture | change_surface ∋ ui; MCP present | low | auto-when-present |
| context7 MCP | PLANNING | plan cites an external API | low, on-demand | optional |
| **Strix** | FULL_REVIEW → report evidence | enabled + change_surface ∩ {auth, payments, external-input, new-endpoint} + FULL | high + Docker | **opt-in** |

**R-119.** *(v4-D)* **Dynamic security (Strix class) — opt-in, lazy, spin-up/tear-down.** A dynamic-security scan runs iff ALL hold: (a) `dynamic_security.strix: enabled` in `heatwave.config.yaml` — the default, and the absence of the key, is `disabled`; (b) the plan's `change_surface` (R-122) intersects {auth, payments, external-input, new-endpoint}; (c) the tier is FULL. When it runs, the REVIEWER at FULL_REVIEW spins the target environment up in Docker, runs the headless scan (`strix -n --target <dynamic_security.strix_target>`), and tears the environment down immediately after — spin-up and tear-down timestamps recorded in the Run Record (`companions.strix_docker_up` / `companions.strix_docker_down`); an up marker without a down marker is a protocol defect. The PoC (or clean result) is attached to the Review Report as dynamic evidence with rung `dynamic` in the ledger's `machine_evidence`; a validated exploit is a machine finding of severity Blocker. Any leg failing → the scan MUST NOT run: disabled → `companions.strix: skipped-disabled`; non-matching surface or tier → `skipped-out-of-gate`; enabled but the tool or Docker is unavailable → `NOT AVAILABLE` per R-64, naming the security acceptance criteria left to the static and semantic layers. It never runs on a routine change.

**R-120.** *(v4-D)* **Companion integration policy.** Heatwave ships detection rules, config keys, invocation guidance, and docs — never the tools, and no companion is required. Three classes govern every companion, present and future: **(1) deterministic, near-free** (secret scan, SAST, mutation) — auto-used when detected, exactly like test tooling (R-99): the PLANNER detects and declares (§6.1), the REVIEWER runs it at its bound stage; **(2) token- or LLM-priced** (semantic security pass, UI-evidence capture, docs lookup) — fires only on a matching `change_surface` (R-122) or as an explicit on-demand call, never unconditionally; **(3) heavy infrastructure** (dynamic security) — opt-in by config on top of class-2 gating (R-119). Nothing runs always-on that costs tokens. An absent companion is declared `NOT AVAILABLE` (R-64) — never a silent skip, and never by itself a failed run. Companion output enters review as candidate findings subject to refute-or-promote (R-112); for SAST-class scans only high-severity results convert (R-111).

**R-121.** *(v4-D)* **Secrets rung.** When a secret scanner is declared — a detected gitleaks binary, config (`.gitleaks.toml`), or pre-commit hook, or `tooling.secrets` in config — the FINAL_REVIEW machine-gate re-run (R-118(b); the LIGHT combined pass included) MUST include a secret scan of the run's full diff as an additional ladder rung (`rung: secrets`). Any hit is a machine finding of severity Blocker (`Category: secret-management`) — a leaked secret must block; a false positive is waived only via the OWNER Blocker-waiver path (R-9), recorded. No scanner declared → `verdict: NOT_AVAILABLE` (R-64). Installing the scanner as a pre-commit hook is RECOMMENDED and is what covers EXPRESS runs, which have no FINAL_REVIEW.

---

## 8. Completion Gate

### 8.1 Gate

**R-77.** A review reports `GATE_MET` only when:

- Blockers = 0 (open)
- Majors = 0 (open)

Where "open" excludes findings with `Status: Deferred (approved)`, `Status: Waived (OWNER)`, or `Status: Refuted` (R-112).

**R-78.** Minor and Nit findings do not gate. They MAY be deferred by REVIEWER approval (R-6) and MUST be recorded in the Run Record for backlog.

### 8.2 Severity definitions

| Severity | Definition | Gating | Deferrable |
|---|---|---|---|
| **Blocker** | Breaks functionality, security, or data integrity. Prevents build, deploy, or safe operation. Includes: undeclared deviation (R-22), asserted verification without evidence (R-65), false tooling claim (R-63). | Yes | Only by OWNER waiver |
| **Major** | Incorrect behavior, unmet acceptance criterion, performance regression against a stated threshold, missing validation, broken flow, inaccurate blast radius (R-54). | Yes | By REVIEWER approval, with recorded reason |
| **Minor** | Suboptimal but correct. Maintainability, non-blocking UX, docs. | No | Yes |
| **Nit** | Style, naming, formatting, preference. | No | Yes |

**R-79.** Blocker and Major differ operationally: a Major MAY be deferred with REVIEWER approval; a Blocker MAY NOT — it requires an OWNER waiver (R-9). Both gate when open.

> **Rationale for R-79.** In v2 both severities read "Must be fixed," making the distinction purely cosmetic. Giving Major a reviewer-approved deferral path — and reserving Blocker deferral for the human — makes the two tiers do different work while keeping both as gates by default.

**R-80.** Severity is assigned by the REVIEWER (R-5). The finding's `Why it matters` field MUST justify the severity assigned; an unjustified severity is itself grounds for the IMPLEMENTER to propose reclassification.

### 8.4 Approval

**R-81.** `APPROVED` requires:

- Plan approved (`PLAN_REVIEW` gate met)
- Implementation complete, all deviations declared
- `FINAL_REVIEW` gate met
- Production readiness checklist complete with evidence
- No unverified acceptance criteria without OWNER waiver
- Run Record complete

**R-82.** Approval is granted by the REVIEWER and recorded in the Run Record with the resolved model identity and timestamp.

---

### 9.3 The resume rule — the loop never restarts

**R-88.** At the start of any session in a project with a `.heatwave/` directory, before doing anything else, the driver MUST check for runs whose `state.yaml` is not in a terminal state. If the user's request concerns an active task, the driver MUST resume at the recorded state with the recorded counters. It MUST NOT re-enter PLANNING, regenerate existing artifacts, or reset counters — regardless of how the user phrases the request.

**R-89.** Completed artifacts are immutable. A stage that needs to change a prior artifact's content goes forward through the state machine (a Deviation Record, a rejection, an escalation) — never by editing history.

**R-90.** Abandoning a run is an OWNER decision recorded in the Run Record (`terminal_state: ABANDONED`). A run is never abandoned implicitly by starting a new session or a new task.

> **Rationale for 9.3.** The most common failure of AI-driven workflows is not a bad review — it is the loop silently starting over: a new session re-plans a planned task, re-implements reviewed code, and every guarantee in Sections 1–8 resets to zero. Anchoring state to the filesystem makes the artifacts, not any session's memory, the source of truth. Any tool that can read a file can resume the loop exactly where it stopped.

