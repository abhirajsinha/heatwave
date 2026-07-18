# The loop, and why it never restarts

Heatwave's core promise: **a task started under the protocol runs the whole loop to APPROVED (or a human decision), and a new session can never accidentally start it over.**

## Why loops restart everywhere else

An AI agent's memory is its session. Kill the terminal, hit the context limit, come back tomorrow — and the next session has no idea a plan was approved yesterday, so it "helpfully" re-plans, re-implements reviewed code, and every guarantee resets to zero. Sometimes it restarts *within* a session: asked to "fix the review findings," it rewrites the feature from scratch instead.

## How Heatwave prevents it

Two spec rules do all the work:

1. **Artifacts are the only interface between roles** (R-17). The plan, the diff summary, the review findings, the fix evidence — all of it lives as numbered files in `.heatwave/runs/<task-id>/`. Nothing important exists only in a session's memory.
2. **The resume rule** (R-88). Any session, in any tool, must check `state.yaml` before acting, and must resume a non-terminal run at its recorded state with its recorded counters. Re-planning a planned task is a protocol violation, not a style choice.

Because of (1), resuming is lossless: a fresh REVIEWER given the artifacts has everything the spec allows a reviewer to see anyway.

## Anatomy of a run

```
.heatwave/runs/2026-07-18-add-export/
├── state.yaml                    # ← the resume anchor
├── run-record.yaml               # append-only audit trail
├── 01-planning-document.md       # PLANNER
├── 02-plan-review-1.md           # REVIEWER  → approved
├── 03-implementation-package.md  # IMPLEMENTER
├── 04-review-report-1.md         # REVIEWER  → 2 Majors
├── 05-fix-report-1.md            # IMPLEMENTER, with executed verification evidence
├── 06-review-report-2.md         # REVIEWER  → gate met
└── 07-review-report-final.md     # REVIEWER  → APPROVED
```

`state.yaml` after artifact 05 lands:

```yaml
task_id: 2026-07-18-add-export
tier: STANDARD
state: TARGETED_REVIEW
counters: { plan_iterations: 0, fix_iterations: 0, final_iterations: 0 }
next_artifact: 06-review-report-2.md
updated: 2026-07-18T14:02:00Z
```

Kill the session here. Open a new one, in any tool, and say "continue the export feature." The driver reads `state.yaml`, sees `TARGETED_REVIEW`, and dispatches a reviewer with artifacts 01–05. Nothing is redone. That is the whole trick.

## The state machine (from PROTOCOL.md §2)

```
PLANNING → PLAN_REVIEW ─rejected→ PLANNING            (budget: 3)
                └─approved→ IMPLEMENTING → FULL_REVIEW
                                             ├─gate met→ FINAL_REVIEW
                                             └─not met→ FIXING → TARGETED_REVIEW ─┐
                                                          ↑          (budget: 5)  │
                                                          └───────not met─────────┘
FINAL_REVIEW ─gate met→ APPROVED
     └─not met→ FIXING (budget: 2; next review is FULL, not targeted)
any budget exhausted → ESCALATED → human decides: continue / replan / abandon
```

Every loop is bounded (§2.3), and escalation resumes cleanly (§7.3) — a human answers one specific question, counters reset, work continues. Nothing is terminal except APPROVED and ABANDONED.

## Edge cases

- **Crash between artifact and state update:** artifacts win (R-87). The driver replays the transitions the files prove happened and repairs `state.yaml`.
- **User asks for something mid-run that changes the task:** that is a Deviation Record or a replan through ESCALATED — never a silent restart (R-89, R-90).
- **Two tasks at once:** two run directories. Runs are independent; the resume rule matches the user's request to its task.
