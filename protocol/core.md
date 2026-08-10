# Heatwave Protocol — core (canonical shard)

Loaded by: every dispatch, all states. Section/rule numbers are global to the protocol.

---

# Heatwave — AI Development & Verification Protocol

**Version:** 3.1 (open-source release)
**Status:** Active
**Supersedes:** v3.0 (AI Development & Verification Protocol)

Heatwave is a tool-agnostic protocol for AI-performed software development. It works with any coding agent — Claude Code, Codex, Gemini CLI, Cursor, or a plain chat session — because it governs *contexts and artifacts*, not any vendor's features. See `README.md` for installation and the per-tool adapters.

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

Ceremony scales to the change; the gates do not. Every tier keeps all four gates: a plan reviewed by a separate context, distinct role contexts, evidence over assertion, and the completion gate (Section 8). What a tier changes is how much of the Planning Document must be written out.

| Tier | Applies to | Planning Document | Reviews |
|---|---|---|---|
| **LIGHT** | Single-file fixes, copy changes, config tweaks with no new surface | Problem statement, acceptance criteria (may be a single AC-F), review scope, tooling declaration. All other sections MAY be collapsed to one `N/A — LIGHT tier` line each. | PLAN_REVIEW still precedes IMPLEMENTING. FULL_REVIEW and FINAL_REVIEW MAY be combined into one REVIEWER pass (full evaluation + per-criterion acceptance status + readiness checklist). A combined pass that fails behaves as a FINAL_REVIEW failure: → FIXING, increments `final_iterations`, next review is FULL (R-14). |
| **STANDARD** | A feature or bugfix touching one subsystem | All sections; N/A allowed per R-20. | Full state machine. |
| **FULL** | Cross-cutting changes: schema migrations, auth, new services, anything touching money or user data | All sections, no collapsed entries; non-functional criteria mandatory. | Full state machine; FINAL_REVIEW checklist (8.3) item-by-item. |

**R-0a.** The PLANNER proposes the tier in the Planning Document with one line of justification; the REVIEWER MAY raise it (never lower it) at PLAN_REVIEW.

**R-0b.** Tier selection is recorded in the Run Record. A change that grows beyond its tier mid-implementation is a Deviation Record (3.2.1) and re-enters PLAN_REVIEW at the higher tier.

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

---

## 2. Workflow State Machine

### 2.1 States

| State | Owner | Exit condition |
|---|---|---|
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
START
  └─→ PLANNING
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

### 2.4 Run Record

**R-15.** Every task MUST maintain a Run Record from `START` to terminal state. See Appendix E for the schema. It is append-only.

---

## 3. Artifacts & Contracts

### 3.1 General rules

**R-16.** Every state transition MUST be accompanied by its artifact. A transition without its artifact is invalid.

**R-17.** Artifacts are the sole interface between roles. If information is not in an artifact, the receiving role does not have it.

**R-18.** Every artifact MUST carry: `task_id`, `artifact_type`, `iteration`, `produced_by` (role + resolved model), `timestamp`.
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

Where "open" excludes findings with `Status: Deferred (approved)` or `Status: Waived (OWNER)`.

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

