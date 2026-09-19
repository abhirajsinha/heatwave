# Heatwave Protocol — planner (canonical shard)

Loaded by: PLANNING; PLAN_REVIEW (as the contract under review); and, from v4.2, the LIGHT `IMPLEMENTING`, combined pass and `FIXING` as the contract for the LIGHT Plan's fields (R-107, R-123). Section/rule numbers are global to the protocol.

**Not dispatched at LIGHT (R-123).** At LIGHT no PLANNER runs; the IMPLEMENTER authors the **LIGHT Plan** (R-124) as §1 of its Implementation Package and carries every PLANNER duty this shard defines for that plan's fields — acceptance criteria (§3.2.2), review scope (§5.1), tooling declaration and change surface (§6.1, R-122). The authority those rules give the PLANNER reads as the plan author's; the LIGHT Plan is reviewed inside the combined pass (R-125), not in a PLAN_REVIEW state.

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

**R-19.** A Planning Document missing any required section MUST be rejected in `PLAN_REVIEW` without further evaluation. (At LIGHT the LIGHT Plan's required fields per R-124 are checked in the combined pass, R-125, not in PLAN_REVIEW.)

**R-20.** Sections that do not apply MUST be marked `N/A` with a one-line justification. Silent omission is a rejection. (At LIGHT no `N/A` rows are written — R-124 fixes the fields, R-123.)

#### 3.2.2 Acceptance criteria

**R-23.** Acceptance criteria MUST be split into functional and non-functional, and both MUST be present. If a feature genuinely has no non-functional constraints, this MUST be stated with justification rather than omitted.

**R-24.** Functional criteria MUST be independently verifiable statements of observable behavior. Each MUST be assigned a stable ID (`AC-F-01`, ...).

**R-25.** Non-functional criteria MUST be measurable, with a stated metric, threshold, and measurement method. Each MUST be assigned a stable ID (`AC-N-01`, ...).

Non-conforming: *"Performance acceptable."* *"Loads fast."* *"Scales well."*
Conforming: *"AC-N-01: p95 latency for `GET /notes` ≤ 200ms at 50 rps, measured via load test in staging."*

**R-26.** The REVIEWER MUST validate against the criteria as written and MUST NOT invent additional requirements. If the REVIEWER believes the criteria are insufficient, that is itself a finding (`Category: acceptance-criteria`, severity per judgment), raised against the plan — not silently enforced as an implementation finding.

> **Rationale for R-26.** v2 established that the reviewer validates against criteria "instead of inventing new requirements," but gave the reviewer no channel for the case where the criteria are wrong. Without that channel the rule is unenforceable — a reviewer who spots a real gap will either smuggle it in as an implementation finding or suppress it. Both are worse than a recorded finding against the plan.

**R-27.** Every acceptance criterion MUST have a stated verification method (see Appendix B), and the Final Review MUST report each criterion's status individually.

*(v5.0)* Every acceptance criterion also carries a `runtime: yes | no` tag (R-133 planner half). A `runtime: yes` criterion's accepting evidence MUST come from driving the real built artifact by the REVIEWER context (R-133 reviewer half); the `runtime-evidence` ladder rung (R-110, §0.5) machine-checks that the evidence names a `verification_matrix` runtime class. `runtime: no` criteria are unchanged.

**R-113 (planner half).** *(v4)* When the run is `change_class: bugfix` (R-114), the acceptance criteria MUST include a failing reproduction: a functional criterion whose verification method is an executable check demonstrated red on the pre-fix code and re-run green after the fix (captured by the IMPLEMENTER, R-113 implementer half). The check is any executable reproduction — a framework test, a script, a CLI invocation — not necessarily a formal test. A bugfix plan without a reproduction criterion MUST be rejected at PLAN_REVIEW. Where nothing executable can express the reproduction, the plan states so explicitly (R-64) and the criterion is unverifiable — which blocks APPROVED absent an OWNER waiver (R-66).

**R-133 (planner half).** *(v5.0)* **Runtime acceptance criteria + verification matrix.** The PLANNER tags every acceptance criterion `runtime: yes | no` (§3.2.2): `runtime: yes` when the criterion is only truly verifiable by driving the real built artifact (a rendered UI, an extension on a real page, an API response, a migration's applied state, a device, a deploy, the owner's real input). The PLANNER declares, for the change's `change_surface` and its runtime ACs, which evidence **classes** the run requires — from the fixed set `web-ui`, `chrome-extension`, `api`, `db-migration`, `mobile`, `deploy`, `real-input` — and confirms each required class has a concrete driver in the project's `verification_matrix` (config/adapter). A required class with no project mapping is declared `NOT AVAILABLE` (R-64), naming the ACs it leaves unverified. The protocol names classes only; the PLANNER never binds a class to a named tool in the plan prose — the tool lives in config. A `runtime: yes` AC's verification method names the class its accepting evidence must come from.

**R-134 (planner half).** *(v5.0)* **Exploratory owner-flow declaration.** The PLANNER declares in the plan an `exploratory_flows` list drawn from the project's config/adapter — real user/operator flows beyond the per-AC checks (e.g. cold start signed-out, real content, multi-tab, reload, extension reload, scroll-while-loading, hover/cursor). The REVIEWER exercises the subset whose surface the change touches before APPROVED (reviewer half). Per-AC scripted checks are necessary but not sufficient — the audit shows defects slipping a scripted gate; the flow list is the second net. Where the project declares no flows the list is empty and the pass is vacuous.

**R-136.** *(v5.0)* **Reproduce before planning, for bugfixes.** Strengthens R-113: on a `change_class: bugfix` run the failing reproduction MUST be captured on the **real build at or before PLANNING** — the PLANNER's first evidence is an executed red run on the real artifact, not a theory. A bugfix plan whose reproduction is theory-only (no executed red on the real build) is a PLAN_REVIEW finding (`Category: verification-integrity`, Major). Where nothing executable can reproduce the defect, the plan says so (R-64) and the reproduction criterion is unverifiable (R-66). R-136 **cross-references R-113 and does not rewrite its text** — R-113 fixes the red-then-green shape and the IMPLEMENTER's capture duty; R-136 moves the *first* red earlier, to planning, so four plan rounds are never spent on a theory one real run refutes.

#### 3.2.3 Technical design document *(v4)*

**R-106 (planner half).** *(v4)* When the run-config says `design_doc: true`, the PLANNER emits `docs/design/<task-id>.md` (path per `design_doc_path`) from `templates/technical-design.md` *before* the Planning Document, and the Planning Document references it. It is an input to the plan (resolution per core §2.5); acceptance criteria and every gate are unchanged by its presence.

#### 3.2.4 Jira-sourced planning *(v4.3)*

**R-128 (planner half).** *(v4.3)* On a Jira-sourced run the PLANNER receives the Requirement Brief as its task statement and the driver's recorded `repo_ownership` verdict. If the PLANNER's own investigation produces evidence that the current repository does **not** own the work — the brief's behavior lives in another service, the entry points are absent — it MUST overturn a `correct` verdict in the Planning Document, carrying the evidence; the driver then returns to the R-128 repository-resolution checkpoint (core §9.8). This needs no Escalation Report and no dispatch: the plan carries the evidence and the driver holds the checkpoint.

**R-130 (planner half).** *(v4.3)* A Jira-sourced Planning Document (and, at LIGHT, the LIGHT Plan) MUST carry a `jira_ac_map`: every `J-AC-i` from the brief mapped to one or more plan acceptance-criteria ids. The map MUST cover every J-AC; the plan MUST NOT narrow or redefine a J-AC (the requirement is the ticket's, not the plan's — reviewer half, R-130 in the reviewer shard, makes an unmapped or redefined J-AC a Major). A plan AC with **no** J-AC source is tagged `derived` and justified — ambiguity is surfaced (Unknowns / the GO checkpoint), never resolved by invention. Text runs carry no `jira_ac_map`; it is a required-iff-Jira field, not an N/A row on every plan.

For Jira-sourced runs the PLANNER's review-scope discovery (§3.2) follows the design-doc §4.3 **funnel**: requirement (the brief) → domain terms → entry point in the codebase → call flow → files touched → tests. This is existing PLANNER investigation work focused by the brief, not a new artifact.

#### 3.2.5 Context brief *(v4.4)*

**R-131 (planner half).** *(v4.4)* When a `00-context-brief.md` is attached (an R-3-permitted PLANNING artifact, driver half in the orchestrator shard §9.9), the PLANNER treats it as **advisory input, not fact**: it MUST verify any brief claim it relies on and cite the check, MUST record in the plan where its own investigation contradicts the brief, and its investigation duty (§3.2 review-scope discovery; the R-128 funnel on Jira runs) is **never narrowed** by the brief. A brief-contradicting discovery about repository ownership feeds the existing R-128 planner-half overturn path unchanged. The brief is convenience, not authority — a plan may rely on nothing in it that the PLANNER has not independently confirmed.

#### 3.2.6 Task packet *(v5-retrieval)*

**R-148 (planner half).** *(v5-retrieval)* When a `00-task-packet.md` is attached (an R-3-permitted artifact, driver half in the orchestrator shard §9.12), the PLANNER treats it exactly as it treats the context brief and the repo map: **advisory starting point, not fact and not a boundary.** It ranks the files the task most likely touches, their tests, their import neighbours, and any matching failure-memory — to spare the PLANNER re-discovering the tree — but the PLANNER verifies any packet claim it relies on, records where its own investigation contradicts the packet, and **never lets the packet narrow §3.2 review-scope discovery.** Reading a file the packet did not rank is expected and legal; the packet is never a gate on completeness. A plan may rely on nothing in the packet the PLANNER has not independently confirmed.

---

## 4. Stage Rules

### 4.1 PLANNING

**R-33.** The PLANNER MUST produce a complete Planning Document per 3.2 before exiting this state. (PLANNING is not entered at LIGHT — the IMPLEMENTER writes the LIGHT Plan instead, R-123.)

**R-34.** On re-entry from `PLAN_REVIEW` rejection, the PLANNER MUST address every finding in the rejecting Review Report, using the Fix Report per-finding response schema (3.5) adapted to plan findings.

*(v4-D)* When the plan leans on an external library's API and a docs companion is present (context7 MCP class, R-120), the PLANNER MAY fetch version-specific docs with an on-demand lookup — never always-on. Absent, the API claim stays a labeled assumption per the planner's claim-labeling discipline.

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

*(v4-D)* Companion detection follows the same evidence discipline (R-120): a secret scanner from a gitleaks binary on PATH, a `.gitleaks.toml`, or a pre-commit hook (`tooling.secrets` in config overrides); UI-evidence capture from Playwright MCP presence in the agent environment (`tooling.ui_evidence` overrides); a docs companion from context7 MCP presence (`tooling.docs` overrides). LIGHT+ declarations SHOULD carry a `secrets` entry — `NOT AVAILABLE` when nothing is detected (R-64) — feeding the FINAL_REVIEW secrets rung (R-121).

**R-122.** *(v4-D)* **Change surface.** For LIGHT+ runs the tooling declaration MUST carry a `change_surface` line: the subset of {auth, payments, external-input, new-endpoint, ui, deps, secrets, api-surface} the change touches, or `none`, with one line of justification, declared by the plan author (PLANNER; at LIGHT the IMPLEMENTER, R-123) from the plan's own scope (the Appendix C review-scope categories are its evidence). `external-input` means any handling of untrusted input — external, user-supplied, or crossing a service or trust boundary — the input-handling class, not only input originating outside the system. It is consumed by the companion gates: the semantic security pass fires on {auth, external-input, deps, secrets, api-surface}, UI-evidence capture on {ui}, dynamic security per R-119. Misclassification is a valid REVIEWER finding — minimum Major when it would have suppressed a security companion. EXPRESS runs have no plan and no change surface; companions never fire on EXPRESS.

*(v5.0)* The tooling declaration also carries a **runtime-evidence** line and, when `change_surface ∋ deploy`, a **deploy** line (R-133/R-137). The runtime-evidence line lists, per runtime evidence class the run requires (`web-ui`, `chrome-extension`, `api`, `db-migration`, `mobile`, `deploy`, `real-input`), the concrete driver from the project's `verification_matrix` that produces it (a browser driver, a real-Chrome load-unpacked, curl, `<migration-tool> status`, an emulator, the owner's real content), or `NOT AVAILABLE` with the ACs it leaves unverified (R-64) — the REVIEWER runs it as the `runtime-evidence` rung (R-110). The deploy line names `deploy-smoke.sh` (the vendored generic contract, R-137) plus the project's `HEALTH_URL`/`REQUEST_URL`/`SCHEMA_CMD` source; `curl` is runtime-probed, fail-closed. No class binds to a named tool in this declaration's protocol contract — only in the project's own config.

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

