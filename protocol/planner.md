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

