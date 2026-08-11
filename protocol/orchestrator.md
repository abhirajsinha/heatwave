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

*(v4)* Three speed duties likewise ride the driver's existing dispatch step, none adding a state or a gate: **(1) model selection (R-116)** — at each dispatch, pick the stage's model per R-116's sets and the config (`cheap_model`, `stage_models`, `small_diff_threshold`); reject frontier-required downgrades with a one-line recorded warning; record the serving model as `stage_model` in the transition entry. **(2) reviewer session (R-117)** — dispatch FULL_REVIEW, TARGETED_REVIEW, and FINAL_REVIEW into one persistent reviewer context where the tool can resume one; otherwise degrade to fresh explicitly, supplying prior reports and ledgers (R-4); never resume the implementer's context as reviewer; honor `fresh_final_reviewer: true` with a cold FINAL context; record `review_session` in the Run Record. **(3) delta range (R-118)** — capture `git rev-parse HEAD` as `head_sha` in each FULL_REVIEW transition entry; at FINAL_REVIEW dispatch, first verify the working tree is clean for tracked source (`git status --porcelain` empty) — a dirty tree is the explicit full-scope degrade, recorded (uncommitted fix work is invisible to a range diff); then compute and record `final_delta_range: <last-full-head_sha>..<HEAD>` and supply that diff to the reviewer; with no recorded SHA, record the explicit full-scope degrade instead.

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

