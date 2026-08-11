<!-- GENERATED FILE — do not edit. Canonical source: protocol/*.md. Rebuild: sh build-protocol.sh -->

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
| `protocol/core.md` | §0 purpose & tiers, §1 roles, §2 state machine & run-config, §3.1 artifact ground rules, §5.4 blast radius, §6.2/§6.4 tool unavailability & evidence, §8.1–8.2/§8.4 completion gate, §9.3 resume rule | every dispatch |
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

**R-118.** *(v4)* **Delta-only FINAL_REVIEW.** FINAL_REVIEW scope is exactly: **(a)** confirm every open finding from prior reviews is closed in the findings ledger; **(b)** re-run ALL machine gates for the run's tier (build/drift, tests, SAST, mutation per R-110) — regardless of any prior verdict, carry-forward, or session continuity; **(c)** LLM review of only the **delta** — the diff since the last FULL_REVIEW, `git diff <last-full-review-sha>..HEAD`, where the driver captured `<last-full-review-sha>` at that FULL_REVIEW's transition. The delta is FINAL_REVIEW's required reading scope: the REVIEWER MUST NOT re-read files unchanged since that SHA as routine re-review. R-8/R-54 discretion survives at FINAL only as a **recorded scope expansion (R-49)**: a reviewer with grounds to suspect a delta change regressed a specific unchanged file MAY read exactly what substantiates that suspicion — the delta is the floor of FINAL reading, not a gag on a grounded suspicion; blanket re-reading of unchanged files remains forbidden. **(d)** re-confirm every acceptance criterion with evidence (R-27). The driver computes the range, supplies the diff, and records it in the Run Record (`final_delta_range`). Where no last-FULL_REVIEW SHA is recorded (pre-v4-C record, unresolvable repo state) or the working tree is dirty at dispatch, FINAL_REVIEW degrades to full scope **explicitly** — recorded, never a guessed range. The LIGHT combined FULL+FINAL pass has no prior FULL_REVIEW and always evaluates in full. A FINAL_REVIEW failure still routes to FIXING with the next review a FULL_REVIEW (R-14) — (b) is the in-pass regression backstop, R-14 the cross-pass one.

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


---

# Heatwave Protocol — planner (canonical shard)

Loaded by: PLANNING; PLAN_REVIEW (as the contract under review). Section/rule numbers are global to the protocol.

---

### 3.2 Planning Document

Produced by PLANNER in `PLANNING`. Consumed by REVIEWER and IMPLEMENTER.

**Required sections:**

| Section | Content |
|---|---|
| Problem statement | What is being solved and for whom |
| Functional requirements | What the system must do |
| Non-functional requirements | Measurable targets — see 3.2.2 |
| Architecture | Components, boundaries, data flow |
| API design | Contracts, if applicable per scope |
| Data design | Schema, migrations, if applicable per scope |
| State management | Client and server state, if applicable |
| Error handling strategy | Failure modes and responses |
| Security considerations | Threat surface introduced by this change |
| Edge cases | Enumerated, not gestured at |
| Risks | With likelihood and mitigation |
| Dependencies | Internal and external, with availability status |
| Testing strategy | What is tested, how, by whom, with what tools |
| Rollout plan | Including flags, staging, phasing |
| Rollback plan | Concrete steps, not "revert the commit" |
| **Acceptance criteria** | See 3.2.2 and Appendix B |
| **Review scope** | See 5.1 and Appendix C |
| **Tooling declaration** | See 6.1 |

**R-19.** A Planning Document missing any required section MUST be rejected in `PLAN_REVIEW` without further evaluation.

**R-20.** Sections that do not apply MUST be marked `N/A` with a one-line justification. Silent omission is a rejection.

#### 3.2.2 Acceptance criteria

**R-23.** Acceptance criteria MUST be split into functional and non-functional, and both MUST be present. If a feature genuinely has no non-functional constraints, this MUST be stated with justification rather than omitted.

**R-24.** Functional criteria MUST be independently verifiable statements of observable behavior. Each MUST be assigned a stable ID (`AC-F-01`, ...).

**R-25.** Non-functional criteria MUST be measurable, with a stated metric, threshold, and measurement method. Each MUST be assigned a stable ID (`AC-N-01`, ...).

Non-conforming: *"Performance acceptable."* *"Loads fast."* *"Scales well."*
Conforming: *"AC-N-01: p95 latency for `GET /notes` ≤ 200ms at 50 rps, measured via load test in staging."*

**R-26.** The REVIEWER MUST validate against the criteria as written and MUST NOT invent additional requirements. If the REVIEWER believes the criteria are insufficient, that is itself a finding (`Category: acceptance-criteria`, severity per judgment), raised against the plan — not silently enforced as an implementation finding.

> **Rationale for R-26.** v2 established that the reviewer validates against criteria "instead of inventing new requirements," but gave the reviewer no channel for the case where the criteria are wrong. Without that channel the rule is unenforceable — a reviewer who spots a real gap will either smuggle it in as an implementation finding or suppress it. Both are worse than a recorded finding against the plan.

**R-27.** Every acceptance criterion MUST have a stated verification method (see Appendix B), and the Final Review MUST report each criterion's status individually.

**R-113 (planner half).** *(v4)* When the run is `change_class: bugfix` (R-114), the acceptance criteria MUST include a failing reproduction: a functional criterion whose verification method is an executable check demonstrated red on the pre-fix code and re-run green after the fix (captured by the IMPLEMENTER, R-113 implementer half). The check is any executable reproduction — a framework test, a script, a CLI invocation — not necessarily a formal test. A bugfix plan without a reproduction criterion MUST be rejected at PLAN_REVIEW. Where nothing executable can express the reproduction, the plan states so explicitly (R-64) and the criterion is unverifiable — which blocks APPROVED absent an OWNER waiver (R-66).

#### 3.2.3 Technical design document *(v4)*

**R-106 (planner half).** *(v4)* When the run-config says `design_doc: true`, the PLANNER emits `docs/design/<task-id>.md` (path per `design_doc_path`) from `templates/technical-design.md` *before* the Planning Document, and the Planning Document references it. It is an input to the plan (resolution per core §2.5); acceptance criteria and every gate are unchanged by its presence.

---

## 4. Stage Rules

### 4.1 PLANNING

**R-33.** The PLANNER MUST produce a complete Planning Document per 3.2 before exiting this state.

**R-34.** On re-entry from `PLAN_REVIEW` rejection, the PLANNER MUST address every finding in the rejecting Review Report, using the Fix Report per-finding response schema (3.5) adapted to plan findings.

---

## 5. Review Rules

### 5.1 Review scope

**R-46.** The PLANNER MUST declare, in the Planning Document, which review categories apply and which do not, each with justification. See Appendix C for the category list and template.

**R-47.** `N/A` MUST carry a reason. `✗ Rate Limiting` is non-conforming; `✗ Rate Limiting — feature is local-only, no network surface` conforms.

---

## 6. Testing Rules

### 6.1 Tooling declaration

**R-62.** The Planning Document MUST declare, per test type: what will be tested, which tool performs it, which role invokes it, and whether that role has verified access to the tool.

Example:

```
Mobile E2E   | iOS Simulator | REVIEWER | access: confirmed
Web E2E      | Playwright          | REVIEWER | access: confirmed
Unit         | <framework>         | IMPLEMENTER | access: confirmed
Load         | <tool>              | IMPLEMENTER | access: NOT AVAILABLE — see AC-N-01 note
SAST         | <per detection/config> | REVIEWER | access: NOT AVAILABLE — rung degrades per R-110/R-64
Mutation     | <per detection/config> | REVIEWER | access: confirmed — stryker.conf.mjs; timeout 10m
```

**R-63.** A tooling declaration claiming access that does not exist is a Blocker at `PLAN_REVIEW` if detectable, and a Blocker at whichever review discovers it otherwise.

**R-98.** *(v3.1)* For a task touching a mobile surface, the target test platform MUST be resolved before `PLANNING` exits: from `heatwave.config.yaml` (`tooling.mobile_platform: ios | android | both`) if set, otherwise by asking the OWNER **once, at run start** — this is a valid stopping point under R-95(3). The answer is recorded in the Run Record, the tooling declaration names the corresponding simulator/emulator, and E2E verification runs there. Platforms not chosen are recorded as out of scope for the run — never silently assumed covered.

**R-99.** *(v3.1)* The tooling declaration SHOULD be **derived by the PLANNER from project evidence**, not typed by the OWNER: test frameworks from manifests and config files (`package.json` scripts and devDependencies, `pytest.ini`/`pyproject.toml`, `go.mod`, `Cargo.toml`, `playwright.config.*`, `cypress.config.*`, `.maestro/`, `ios/`/`android/` directories, CI workflows), each entry citing the file that proves the tool exists. Entries in `heatwave.config.yaml` override detection where present. A tool declared with neither project evidence nor a config entry is a false access claim under R-63. Where a required test type has no detectable tool, the declaration says so explicitly (R-64) — detection failure is stated, never papered over.

*(v4)* For STANDARD and FULL runs the declaration MUST also carry a `sast` entry, and for FULL runs a `mutation` entry — the REVIEWER's ladder rungs consume them (R-110). Detect them from project evidence like any other tool (a Semgrep/CodeQL config, `stryker.conf.*`, `mutmut`/`cargo-mutants` in dev-dependencies, CI workflows); `tooling.sast` / `tooling.mutation` in `heatwave.config.yaml` override detection. A mutation entry states its timeout ceiling. No evidence and no config entry → the entry reads `NOT AVAILABLE`, naming the acceptance criteria left unverified (R-64) — the rung then degrades per R-110, never silently.

---

## Appendix B — Acceptance Criteria Template

```
Functional

AC-F-01 | <observable behavior> | Verification: <method>
AC-F-02 | <observable behavior> | Verification: <method>

Non-functional

AC-N-01 | <metric> <operator> <threshold> under <conditions> | Verification: <method>
AC-N-02 | <metric> <operator> <threshold> under <conditions> | Verification: <method>
```

Example:

```
Functional

AC-F-01 | User can create a note with title and body; note persists across app restart
        | Verification: iOS Simulator — create note, force-quit, relaunch, confirm present
AC-F-02 | Search returns notes matching title or body substring, case-insensitive
        | Verification: unit test suite `search_spec` + simulator spot-check
AC-F-03 | Offline mode loads cached notes and queues writes; queue flushes on reconnect
        | Verification: simulator with network link conditioner — airplane mode, create note,
          restore network, confirm sync

Non-functional

AC-N-01 | Note list renders ≤ 100ms for 1000 notes, p95, on iOS Simulator
        | Verification: instrumented timing, 20 runs, p95 reported
AC-N-02 | `POST /notes` p95 ≤ 150ms at 30 rps
        | Verification: load test in staging; results attached
AC-N-03 | Offline queue survives app termination; no write loss across 50 queued writes
        | Verification: simulator — queue 50 writes offline, force-quit, relaunch, restore
          network, confirm 50/50 synced
```

**Rules:**

- Every criterion has an ID (R-24, R-25)
- Every criterion has a verification method (R-27)
- Non-functional criteria state metric, threshold, conditions (R-25)
- If a feature has no non-functional constraints, state so with justification (R-23)

---

## Appendix C — Review Categories

Declared in the Planning Document; each marked applicable or N/A with reason.

**Frontend**

`ui-rendering` · `responsive-layout` · `design-system` · `navigation` · `deep-links` · `interaction` · `forms` · `client-state` · `api-integration` · `loading-states` · `empty-states` · `error-states` · `offline` · `accessibility` · `visual-regression`

**Backend**

`business-logic` · `api-contracts` · `request-validation` · `response-validation` · `status-codes` · `versioning` · `schema` · `migrations` · `transactions` · `indexes` · `query-performance` · `data-integrity`

**Security**

`authentication` · `authorization` · `rbac` · `input-validation` · `output-encoding` · `injection` · `xss` · `csrf` · `ssrf` · `secret-management` · `encryption` · `secure-headers` · `secure-config`

**Performance**

`api-latency` · `db-latency` · `memory` · `cpu` · `cache` · `concurrency` · `scalability`

**Reliability**

`error-handling` · `retry` · `circuit-breakers` · `timeouts` · `recovery` · `rate-limiting`

**Observability**

`logging` · `metrics` · `tracing` · `monitoring` · `alerting`

**Always applicable — MUST NOT be marked N/A**

`plan-conformance` · `verification-integrity`

**Template:**

```
Applicable
✓ <category> — <why>

Not applicable
✗ <category> — <why not>
```


---

# Heatwave Protocol — implementer (canonical shard)

Loaded by: IMPLEMENTING; EXPRESS_IMPLEMENTING. Section/rule numbers are global to the protocol.

---

#### 3.2.1 Deviation Records

**R-21.** When implementation diverges from the approved plan, the IMPLEMENTER MUST record a Deviation Record in the Implementation Package containing:

- What the plan specified
- What was built instead
- Why
- Whether it affects review scope, acceptance criteria, or non-functional targets
- Whether it affects the threat surface

**R-22.** An undeclared deviation discovered in review is a **Blocker**, categorized as `plan-conformance`, regardless of whether the deviation itself is otherwise benign.

> **Rationale for R-22.** The severity attaches to the concealment, not the change. A better-than-planned approach that arrives undeclared has still defeated scope control: the reviewer evaluated against a scope that no longer describes the system. Making this a Blocker without exception removes the judgment call about whether "this one was fine."

### 3.3 Implementation Package

Produced by IMPLEMENTER in `IMPLEMENTING`. Consumed by REVIEWER.

**Required contents:**

| Item | Detail |
|---|---|
| Change summary | What was built, in prose, ≤ 200 words |
| Files changed | Path, change type, line delta |
| Diff | Or a reference the REVIEWER can resolve |
| Deviation Records | Per 3.2.1; explicit `None` if none |
| Migration notes | Forward and backward |
| Configuration changes | Including new env vars, flags, secrets |
| Test additions | What was added and what it covers |
| Test results | Per 6.4 — evidence, not assertion; bugfix runs attach the red-then-green reproduction pair (R-113) |
| Blast radius declaration | Per 5.4 |
| Known limitations | Explicit `None` if none |
| Tooling status | Per 6.2 |

**R-28.** `Blast radius declaration` and `Deviation Records` MUST NOT be empty fields. Absence is expressed as an explicit `None`, which is a claim the REVIEWER may find against.

---

### 4.3 IMPLEMENTING

**R-37.** The IMPLEMENTER MUST build to the approved plan. Divergence is permitted but MUST be declared per 3.2.1.

**R-38.** The IMPLEMENTER MUST NOT expand functional scope beyond the acceptance criteria. Additional work identified during implementation is a Deviation Record requesting plan change, not a unilateral addition.

**R-113 (implementer half).** *(v4)* For a `change_class: bugfix` run (R-114), the IMPLEMENTER MUST capture the failing reproduction FIRST: run the plan's reproduction check against unmodified code and attach the red output to the Implementation Package, then fix, then re-run the same check and attach the green output. Red-then-green is the verification evidence for the reproduction criterion; a fix authored before the red run is captured is a deviation (3.2.1).

### 4.8 EXPRESS_IMPLEMENTING *(v4)*

**R-105.** *(v4)* If the EXPRESS IMPLEMENTER finds the change larger or riskier than classified, it MUST NOT edit; it produces an EXPRESS Change note with `Result: scope_exceeded — <reason>`. The driver promotes the tier and enters `PLANNING`. This is the R-0b deviation path applied to intake misclassification.

In EXPRESS mode the ponytail discipline (Appendix G) applies in full — the tier exists precisely for the single smallest change that works — and the evidence rules are unchanged: attach real output for every check run (R-65), and declare any check that does not exist as `NOT AVAILABLE` (R-64), never narrated as run.

---

### 6.3 Test type requirements

Applicability is per review scope (5.1).

| Type | Environment | Requirement |
|---|---|---|
| Unit | Project standard | All relevant suites pass; results attached |
| Integration | Project standard | All relevant suites pass; results attached |
| API contract | Project standard | Contracts verified against plan |
| Mobile E2E | Per `heatwave.config.yaml` (`tooling.mobile_e2e`), unless plan specifies otherwise with reason | Complete journeys per acceptance criteria |
| Web E2E | Playwright | Realistic journeys, not isolated page checks |
| Load / performance | Per plan | Only where non-functional criteria specify thresholds |
| Accessibility | Per plan | Where applicable |

**R-67.** E2E tests MUST exercise the acceptance criteria, not a reviewer's improvised checklist.

---

## Appendix G — Ponytail: the IMPLEMENTER's coding discipline

*New in v3.1.* Heatwave vendors [Ponytail](https://github.com/DietrichGebert/ponytail) (MIT, © Dietrich Gebert) at `plugins/ponytail/SKILL.md` and binds it to one role.

**R-91.** The IMPLEMENTER MUST apply the ponytail ladder when writing code: question whether the code needs to exist, reuse what the codebase already has, prefer stdlib and native platform features over dependencies, and ship the shortest working diff — after fully understanding the problem, never instead of it.

**R-92.** Ponytail governs the IMPLEMENTER only. The REVIEWER's severity rules (8.2), the evidence rules (6.4), and every gate are unchanged — "lazy" never means unverified. Ponytail's own guardrails agree: input validation at trust boundaries, error handling that prevents data loss, security, and anything the plan explicitly requires are never simplified away.

**R-93.** Deliberate simplifications with a known ceiling MUST carry a `ponytail:` comment naming the ceiling and upgrade path, and MUST be listed under `Known limitations` in the Implementation Package — which makes each one a claim the REVIEWER can find against.

**R-94.** A REVIEWER finding of over-engineering (speculative abstraction, unneeded dependency, reinvented stdlib) is a valid finding, `Category: over-engineering`, severity per judgment. The completion gate is symmetric: code can fail review for doing too much, not only too little.

> **Rationale.** A verification protocol this strict invites over-building — an implementer graded on passing review will gold-plate. Binding a minimalism discipline to the same role that faces the gate keeps diffs small, which also makes every review cheaper and blast-radius claims easier to check.


---

# Heatwave Protocol — reviewer (canonical shard)

Loaded by: PLAN_REVIEW; FULL_REVIEW; TARGETED_REVIEW; FINAL_REVIEW; ESCALATED (report). Section/rule numbers are global to the protocol.

---

### 3.4 Review Report

Produced by REVIEWER in `PLAN_REVIEW`, `FULL_REVIEW`, `TARGETED_REVIEW`, `FINAL_REVIEW`. Consumed by IMPLEMENTER and OWNER.

**Structure:**

```
1. Header            — task_id, iteration, review_type, scope evaluated
2. Verdict           — GATE_MET | GATE_NOT_MET, with counts by severity
3. Scope changes     — per 5.2; explicit "None" if none
4. Reconciliation    — per 5.6; required from iteration 2 onward
5. Acceptance status — per criterion; required in FINAL_REVIEW
6. Findings          — summary per finding; canonical Appendix-A detail lives in the findings ledger (R-109)
7. Verification log  — per 6.4; what was verified, how, what was not, why
8. Summary narrative — free prose, ≤ 400 words, no findings introduced here
```

**R-29.** Findings MUST use the Appendix A schema, carried in the findings ledger from v4 (R-109); the report's Findings section summarizes and references it. Narrative belongs in §8 and MUST NOT introduce a finding. A concern that does not merit a structured finding is not a finding and MUST NOT gate approval.

> **Rationale for R-29.** v2 said free-form comments were "discouraged," which is not an enforceable rule — reviewers produce prose, and prose concerns then float in an undefined state where they neither block nor get tracked. Giving narrative a sanctioned home with an explicit no-findings rule resolves this without pretending reviewers won't write prose.

**R-30.** Every finding MUST carry a stable ID per 5.5.

#### 3.4.1 Findings ledger *(v4)*

**R-109.** *(v4)* From v4, each FULL/TARGETED/FINAL review produces `NN-findings-K.yaml` (schema: `templates/findings-ledger.yaml`) as the machine artifact of record, alongside the prose Review Report as its rendered human view. A review transition produces the ledger and its rendered report under the same sequence number NN; the pair counts as one artifact for §9.2 numbering. The FIXER responds by finding `id`; reconciliation (R-58) and TARGETED_REVIEW are driven from the ledger's `status` fields. Appendix A field semantics are the ledger's field semantics — the ledger is their compact carrier (the v4 machine-evidence additions `Origin`, `Refutation`, and the `Refuted` status live in both; §3.4.2).

#### 3.4.2 Machine evidence & refutation *(v4)*

**R-111.** *(v4)* Ladder verdicts (R-110) convert to findings mechanically, recorded in the ledger with `origin: machine` and their `rung`: a failing declared test is a machine finding of severity Blocker; a high-severity SAST result on changed lines is a machine finding, default Major; a surviving mutant on changed lines is a machine finding — `tests inadequate for <file>`, naming what to cover — default Major. Default categories: a failing test takes the category of the acceptance criterion it verifies, else `verification-integrity`; a SAST hit takes the matching Security category from Appendix C; a surviving mutant takes `verification-integrity`. The REVIEWER MAY reclassify a machine finding's default severity or category per R-5 with recorded reason; it MUST NOT discard one silently. All other Appendix A semantics apply, including stable IDs (R-55). The LLM review that follows covers what machines cannot — logic, design, plan conformance — and MUST NOT restate as prose findings what a rung already verified.

**R-112.** *(v4)* Refute-or-promote: before any candidate finding of severity Major or Blocker enters the ledger as `open`, the REVIEWER MUST attempt to refute it — is it actually reachable, actually wrong, not already handled? — and record the attempt and outcome in the finding's `refutation` field. A finding that survives is promoted (`status: open`) and gates per Section 8; one that is refuted is recorded with `status: refuted` and the refuting reason, MUST NOT enter FIXING, and MUST NOT gate (R-77 excludes it from "open"). Minors and Nits are exempt. A machine finding's refutation attempt is re-running its rung and checking the result is attributable to the change under review rather than a pre-existing baseline failure. Refuted findings remain in the ledger — visible, reconciled per 5.6, reopenable per R-59 — and are outside the set of findings R-31 obliges the FIXER to answer. Applies to ledger-producing reviews (R-109); PLAN_REVIEW findings are unaffected.

---

### 4.2 PLAN_REVIEW

**R-35.** The REVIEWER MUST evaluate: completeness against 3.2, acceptance criteria conformance against 3.2.2, review scope justification against 5.1, tooling declaration realism against 6.1, and internal consistency (does the architecture support the requirements; do the criteria cover the requirements; is the rollback plan actually executable).

**R-36.** Plan approval requires zero Blockers and zero Majors, per the same gate as feature review (Section 8).

### 4.4 FULL_REVIEW

**R-39.** The REVIEWER MUST evaluate every category in the effective review scope (5.1 as amended by 5.2), plus plan conformance (5.3), across the entire feature — not only changed files.

FULL_REVIEW opens with the machine-evidence ladder for the run's tier (R-110); LLM findings follow it.

**R-113 (reviewer half).** *(v4)* For a `change_class: bugfix` run (R-114), the REVIEWER MUST confirm the reproduction: red evidence captured on pre-fix code, and the same check re-run green after the fix. A bugfix with no reproducing check, or with no red-run evidence, is a Major (`Category: verification-integrity`) regardless of how plausible the fix reads.

### 4.6 TARGETED_REVIEW

**R-42.** The REVIEWER MUST evaluate: each finding's claimed resolution against its verification evidence, the declared blast radius of the fixes, regression risk in components the fixes touch, and any new Deviation Records.

**R-43.** The REVIEWER MUST NOT re-litigate areas passed in prior iterations unless a fix's blast radius reaches them, or reconciliation (5.6) justifies reopening.

---

### 5.2 Dynamic scope

**R-48.** The REVIEWER MAY expand the effective review scope beyond the plan's declaration when the implementation introduces surface the plan did not anticipate — a new endpoint, a cache, a background job, a third-party call, a new data store, a new permission.

**R-49.** Scope expansion MUST be recorded in the Review Report §3 with: category added, what triggered it, and whether a Deviation Record declared the trigger (if not, see R-22).

**R-50.** The REVIEWER MUST NOT narrow scope below the plan's declaration without OWNER approval.

> **Rationale for R-48.** A scope fixed at planning time is stale the moment implementation surprises anyone, and v2 bound the reviewer to ignore whatever the plan marked N/A. That converts an honest planning-time estimate into a permanent blind spot: an implementer who adds a cache the plan didn't foresee gets no cache review, forever. Expansion is one-directional by design — the reviewer can add surface, never remove it.

### 5.3 Plan conformance

**R-51.** Plan conformance is a mandatory review category in every `FULL_REVIEW` and `FINAL_REVIEW`. It MUST NOT be marked N/A.

**R-52.** The REVIEWER MUST verify: the implementation realizes the planned architecture, all Deviation Records are declared, no undeclared divergence exists, and the acceptance criteria are satisfied by what was actually built rather than by something adjacent to it.

> **Rationale.** v2 required implementation "according to the approved plan" but had no review category that checked it. An implementer who solved the problem differently — even competently — passed every listed check, because every check examined the code on its own terms rather than against the plan. Plan conformance is the category that makes plan approval load-bearing.

### 5.5 Finding identity

**R-55.** Every finding MUST have an ID stable for the task's lifetime: `F-<task_id>-<NNN>`, assigned sequentially, never reused.

**R-56.** A finding that recurs across iterations MUST retain its original ID. A finding that is genuinely new gets a new ID.

**R-57.** A finding's severity MAY change across iterations, but each change MUST be recorded in the reconciliation section with reason.

### 5.6 Reconciliation

**R-58.** From iteration 2 onward, every Review Report MUST contain a reconciliation section addressing every finding from all prior reports:

```
Finding ID | Prior status | Current status | Change reason (required if changed)
```

**R-59.** Reopening a previously-resolved finding requires a stated reason: the fix regressed, the fix was inadequate, or the earlier resolution was accepted in error.

**R-60.** A finding raised at iteration N against code unchanged since iteration 1 MUST be flagged as a **late finding** and MUST state why earlier iterations passed it. Late findings are valid — a reviewer who spots a real problem late should say so — but they MUST be visible as a review-quality signal rather than absorbed silently into the count.

**R-61.** Severity reversals (a finding downgraded or upgraded without a corresponding code change) MUST be justified in reconciliation.

> **Rationale for 5.6.** Without reconciliation, a review loop can churn indefinitely: iteration 3 raises what iteration 1 passed, iteration 4 quietly drops it, and nobody can tell whether the code is converging or the reviewer is drifting. Stable IDs plus mandatory reconciliation make the loop's trajectory legible — and make review quality itself measurable, since a run with many late findings indicates the early reviews were shallow.

---

### 7.2 Escalation Report

Produced by the REVIEWER upon entering `ESCALATED` (the driver dispatches it with the Run Record and all prior artifacts). Consumed by the OWNER.

**R-71.** Entering `ESCALATED` MUST produce an Escalation Report containing:

| Section | Content |
|---|---|
| Trigger | Which condition fired; which counter, if applicable |
| State | Current state, all counter values |
| Outstanding findings | Full list with IDs, severity, history |
| Root cause analysis | Why convergence failed — not a restatement of the findings |
| Attempted fixes | What was tried, per finding, and why it did not work |
| Unverified criteria | Per R-66 |
| Options | Concrete alternatives with tradeoffs |
| Decision required | The specific question the OWNER must answer |

**R-72.** The "Decision required" section MUST pose an answerable question. "Please advise" is non-conforming.

---

## Appendix A — Finding Schema

```
Finding ID:           F-<task_id>-<NNN>
Severity:             Blocker | Major | Minor | Nit
Category:             <from Appendix C, or: blast-radius |
                       acceptance-criteria | over-engineering>
Origin:               reviewer | machine (R-111; absent = reviewer)
Location:             <file:line, endpoint, screen, or artifact section>
Problem:              <what is wrong — observable, specific>
Why it matters:       <consequence; MUST justify the severity assigned>
Recommended fix:      <actionable; not "consider improving">
Verification method:  <how the fix will be proven — MUST be executable by
                       the IMPLEMENTER; this field is consumed by R-32>
Refutation:           <refutation attempt + outcome — REQUIRED for
                       Major/Blocker (R-112)>
Introduced in:        <iteration first raised>
Status:               Open | Fixed | Deferred (approved) | Waived (OWNER) |
                      Disputed | Refuted
```

Notes:

- `Verification method` MUST be concrete enough to execute and to produce evidence. "Retest the flow" is non-conforming; "Run `<suite>::<test>`; expect pass" or "In the simulator, navigate Home → Settings → Delete Account; expect confirmation modal, then logout" conforms.
- `Why it matters` is where severity is defended. A Blocker whose consequence reads like a Nit will be reclassified.


---

# Heatwave Protocol — fixer (canonical shard)

Loaded by: FIXING. Section/rule numbers are global to the protocol.

---

### 3.5 Fix Report

Produced by IMPLEMENTER in `FIXING`. Consumed by REVIEWER.

**Structure:**

```
1. Header                 — task_id, iteration, responding to <Review Report ID>
2. Per-finding response   — one entry per finding in the report being answered
3. Deviation Records      — new deviations introduced by fixes
4. Blast radius           — for the fixes themselves, per 5.4
5. Notes
```

**R-31.** Every finding in the Review Report being answered MUST have exactly one response entry. Silence is not a response. Findings with `status: refuted` (R-112) require no response.

**Per-finding response schema:**

```
Finding ID:            <stable ID>
Response:              Fixed | Reclassification proposed | Deferral requested | Disputed
Change:                <what was changed, or "none">
Verification:          <evidence per the finding's Verification Method>
Evidence:              <output, artifact reference, or explicit "unavailable: reason">
Argument:              <required for Reclassification proposed | Deferral requested | Disputed>
```

**R-32.** For any finding marked `Fixed`, the IMPLEMENTER MUST execute the finding's stated `Verification Method` and attach its result. If the method cannot be executed, the response MUST be `Disputed` or the evidence field MUST read `unavailable: <reason>` — and per R-70, the REVIEWER MUST NOT mark it resolved on that basis alone. *(v3.1 erratum: v3.0 cited R-46 here, an unrelated rule.)*

> **Rationale for R-32.** In v2, `Verification Method` was part of the finding schema but nothing consumed it, which made it decorative. Closing the loop — the method is stated by the reviewer, executed by the implementer, and checked by the reviewer — is what turns "fixed" from an assertion into a claim with evidence behind it.

---

### 4.5 FIXING

**R-40.** The IMPLEMENTER MUST address every finding per 3.5, including those it disputes.

**R-41.** The IMPLEMENTER MUST NOT make changes unrelated to the findings being addressed. Opportunistic refactoring during `FIXING` invalidates blast-radius reasoning and is itself a finding.


---

# Heatwave Protocol — final-reviewer (canonical shard)

Loaded by: FINAL_REVIEW. Section/rule numbers are global to the protocol.

---

### 4.7 FINAL_REVIEW

**R-44.** The REVIEWER MUST perform a complete evaluation equivalent to `FULL_REVIEW`, plus per-criterion acceptance status (R-27), plus the production readiness checklist (Section 8.3).

**R-45.** Findings raised in `FINAL_REVIEW` that were passable in prior iterations MUST be reconciled per 5.6 — the report MUST state why the earlier pass was wrong or what changed.

---

### 8.3 Production readiness

Verified at `FINAL_REVIEW`. Each item MUST have status and evidence.

| Item | Requirement |
|---|---|
| Acceptance criteria | Every AC-F and AC-N reported individually: Satisfied / Not satisfied / Unverified |
| Plan conformance | Passed (5.3) |
| In-scope review categories | All passed (5.1 + 5.2) |
| Tests | All declared suites executed; results attached |
| Non-functional targets | Measured against thresholds; measurements attached |
| Tooling gaps | Enumerated per R-64; none affecting an unwaived criterion |
| Reconciliation | Complete; no unexplained reversals |
| Open findings | Blockers = 0, Majors = 0 |
| Deferred findings | Recorded with approver |
| Waived findings | Recorded with OWNER rationale |
| Documentation | Updated per plan |
| Observability | Per scope |
| Rollback | Plan present and executable |


---

# Heatwave Protocol — orchestrator (canonical shard)

Loaded by: intake (the driver itself). Section/rule numbers are global to the protocol.

---

### 3.6 Owner Decision Record

Produced by OWNER in `ESCALATED`. See 7.3.

---

## 7. Escalation

### 7.1 Triggers

Escalation to `ESCALATED` occurs when:

- Any counter exhausts its budget (2.3)
- Acceptance criteria remain unverified at `FINAL_REVIEW` (R-66)
- A dispute between IMPLEMENTER and REVIEWER persists across two iterations without resolution
- A required tool is unavailable and no alternative satisfies the affected criteria
- Any role determines the task cannot proceed within protocol

### 7.3 Owner Decision Record and resume

**R-73.** The OWNER MUST produce an Owner Decision Record:

```
Decision:        continue | replan | abandon
Resume state:    <state>            (required if continue)
Counter reset:   <which counters, to what>   (required if continue)
Waivers:         <finding IDs waived, with reason>  (optional)
Scope changes:   <additions or removals, with reason>  (optional)
Criteria changes:<AC IDs added/modified/removed, with reason>  (optional)
Rationale:       <why>
```

**R-74.** `continue` MUST reset at least one counter. A resume with all counters at budget re-escalates on the next transition, which is a null decision.

**R-75.** Waived findings MUST be recorded in the Run Record and MUST appear in the Final Review report as `Status: Waived (OWNER)` with the waiver reason — they are not deleted from the finding list.

**R-76.** `replan` returns to `PLANNING` and resets all counters. The existing Planning Document is superseded, not amended.

> **Rationale for 7.3.** v2 capped iterations at 5 and required an escalation report, but said nothing about what happens after the human answers — which makes every escalation effectively terminal, since resuming at the budget means immediately re-escalating. Requiring a counter reset and an explicit resume state turns escalation into what it should be: a checkpoint where a human supplies judgment the loop couldn't, after which work continues.

---

## 9. Driver & Persistence

*New in v3.1.* Sections 1–8 define who decides what; this section defines the mechanism that runs the loop and the guarantee that it never restarts.

### 9.1 The driver

**R-83.** Every run has exactly one **driver**: the context that reads the current state, dispatches the owning role, receives the artifact, and records the transition. The driver holds no role authority — it MUST NOT plan, implement, review, or alter artifacts.

**R-84.** How role contexts are obtained is per adapter:

- **Subagent-capable tools** (e.g. Claude Code): the driver is the main session; each role is dispatched as a fresh subagent receiving only the artifacts R-3 permits.
- **Single-context tools** (e.g. Codex CLI, Gemini CLI, Cursor, plain chat): each role is a fresh session/conversation. The driver is the human starting each session, or the current session acting as driver *between* role turns — but a session that performed a role for a task MUST NOT perform a conflicting role (R-1, R-2) for that task.

**R-85.** The driver MUST dispatch a role with artifacts only, never with another role's transcript.

*(v4)* Two recording duties ride the driver's existing steps: at intake it records `change_class` in `run_config` (R-114 — the PLANNER may correct it, and the correction is recorded); at the first FULL_REVIEW (or LIGHT combined-pass) dispatch — once both the implementer and reviewer roles have resolved — it records the `hetero_reviewer` advisory computed from the resolved models by setting the record's `hetero_reviewer` field (R-115 — set in place, valid YAML, never a mid-file append or duplicate key), recomputing and re-setting the field if a later substitution changes either. Neither duty adds a state or a gate.

### 9.2 On-disk run state

**R-86.** Every run lives in `.heatwave/runs/<task-id>/` inside the project:

```
.heatwave/runs/<task-id>/
├── state.yaml            # current state, tier, counters — the resume anchor
├── run-record.yaml       # append-only; schema: templates/run-record.yaml
├── 01-planning-document.md
├── 02-plan-review-1.md
├── 03-implementation-package.md
├── 04-review-report-1.md
├── 05-fix-report-1.md
└── ...                   # numbered sequentially in transition order
```

`state.yaml`:

```yaml
task_id:
tier:            # EXPRESS | LIGHT | STANDARD | FULL
state:           # one of the states in §2.1 (incl. EXPRESS_IMPLEMENTING, EXPRESS_CHECK from v4)
counters: { plan_iterations: 0, fix_iterations: 0, final_iterations: 0 }
next_artifact:   # filename the current state's owner must produce
updated:         # timestamp of last transition
```

A run directory created before v4 (no `run_config`) resumes with the §2.5 defaults; the driver MUST NOT rewrite old records to add the block.

**R-87.** The driver MUST update `state.yaml` immediately after each artifact lands, before dispatching the next role. An artifact on disk with a stale `state.yaml` is resolved in favor of the artifacts: replay the transitions the artifacts prove happened.

Run Record schema is `templates/run-record.yaml`; it is normative. *(v4: replaces Appendix E, which duplicated it.)*

### 9.4 Non-stop execution — the loop runs to the end

**R-95.** Once a run starts (or resumes), the driver MUST advance the loop continuously until one of exactly three stopping points:

1. A **terminal state** — `APPROVED` or `ABANDONED`.
2. **`ESCALATED`** — a budget exhausted or a §7.1 trigger fired; the driver stops *with the Escalation Report and its one answerable question* (R-72), never with an open-ended pause.
3. A **blocking OWNER decision** the protocol itself requires — a Blocker waiver (R-9), an unverifiable acceptance criterion (R-66), or a checkpoint the OWNER configured in advance.

**R-96.** The driver MUST NOT stop between states to ask permission to continue, report intermediate progress and wait, offer choices the protocol already decides ("shall I run the review now?"), or end its session after completing an individual stage. Progress reporting is done in passing; the loop keeps moving. Stopping anywhere other than the three points in R-95 is a protocol violation — the run is not "paused", it is stranded mid-state, and the next session must resume it per R-88.

**R-97.** When the driver stops at a valid point, it MUST state which of the three stopping points applies and, for points 2 and 3, pose the specific decision required. "Done for now, let me know how to proceed" is non-conforming.

> **Rationale for 9.4.** Agents are trained to be polite, and polite looks like stopping to ask. In a gated protocol every such pause is pure loss: the human's judgment is already encoded in the plan, the criteria, and the budgets — the protocol *is* the permission. Interruptions belong only where the protocol genuinely cannot decide: escalations and waivers. Everything else runs.

### 9.5 The machine stays awake while the loop runs

**R-100.** *(v3.1)* While a run is in a non-terminal state, the driver SHOULD hold a system-sleep inhibitor: `sh .heatwave/keep-awake.sh start <run-dir>` when the run starts or resumes, `stop` when it reaches `APPROVED`, `ABANDONED`, or `ESCALATED`. The inhibitor blocks **system sleep only** — the display may lock and dim as the OWNER's settings dictate; screen lock never pauses a process. A lid close or shutdown still suspends the machine; §9.3 makes that loss-free rather than work-losing.

### 9.6 Shard dispatch *(v4)*

**R-107.** *(v4)* The driver dispatches each role with `protocol/core.md` plus the role shard(s) in the dispatch matrix — never the full `PROTOCOL.md`. Context is assembled stable-prefix-first: shards, then config, then prompt, then task artifacts. The ordering is a cache optimization, never a correctness dependency.

### 9.7 Generated protocol *(v4)*

**R-108.** *(v4)* `protocol/` shards are canonical; `PROTOCOL.md` is generated by `build-protocol.sh`. Editing `PROTOCOL.md` directly is a defect. `sh build-protocol.sh --check` MUST exit 0 before a Heatwave release or install.


---

# Heatwave Protocol — history (canonical shard)

Loaded by: never dispatched — rendered into the full generated spec only.

---

## Appendix F — Changes from v2

| Change | Rules | Addresses |
|---|---|---|
| Planner/reviewer context separation | R-2 | Plan was self-reviewed; criteria validated by their author |
| Dynamic review scope | R-48–R-50 | Scope fixed at plan time went stale on deviation |
| Plan conformance as a review category | R-51–R-52 | "Build to plan" was unenforced by any check |
| Final review reopens loop, own budget | 2.2, 2.3, R-14 | Post-loop Blockers had nowhere to go |
| Escalation resume path | R-73–R-76 | Escalation was effectively terminal |
| Stable finding IDs + reconciliation | R-55–R-61 | Findings could churn between iterations undetected |
| Reviewer-owned severity and deferral | R-5, R-6 | Implementer decided what it could skip |
| Verification method consumed | R-32, R-42 | Field existed but nothing acted on it |
| Non-functional acceptance criteria | R-23, R-25 | "Performance acceptable" gated nothing |
| Tooling declaration + unavailability rules | R-62–R-66 | Reviewer could assert untested verification |
| Blocker/Major operational distinction | R-79 | Both read "must be fixed" |
| Narrative given a sanctioned home | R-29 | "Discouraged" was unenforceable |
| Reviewer channel for bad criteria | R-26 | No path for "the criteria are wrong" |
| Blast radius as auditable claim | R-53–R-54 | Targeted review rested on undeclared reasoning |
| Run Record | R-15, Appendix E | No traceability across the run |
| Role config externalized | R-10–R-12 | Model names embedded in workflow prose |
| One diagram, not two | §2.2 | Duplicate diagrams drift |


---

## Appendix F.1 — Changes in v4

| Change | Rules | Addresses |
|---|---|---|
| EXPRESS tier + intake triage by the driver | R-101–R-105 | No "just do it" path; tier selection cost a planner context |
| `protocol/` shards canonical; the rendered spec generated by `build-protocol.sh` | R-107, R-108 | Every dispatch reloaded the full 974-line doc |
| Findings ledger as the machine artifact of record | R-109 | Findings round-tripped as prose |
| `run_config` block (tier, design_doc; autonomy/scope reserved) | core §2.5 | No per-run configuration record at intake |
| Technical design-doc gate (STANDARD/FULL, opt-in) | R-106 | No pre-plan design artifact for greenfield work |
| Appendix D/E replaced by normative `templates/` pointers | core §3.1, orchestrator §9.2 | Skeletons/schema duplicated the template files |
| Machine-evidence ladder, refute-or-promote, reproduce-then-fix, hetero-reviewer visibility | R-110–R-115 | Rigor rested on LLM prose; false-positive Majors cost full fix cycles; "verified" bugfixes were claims; same-model self-preference was invisible |
