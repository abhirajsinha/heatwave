# Heatwave protocol (binding) — generic adapter

<!-- Works with any AI coding agent that reads project instructions or a system prompt.
     Paste or include this file wherever your tool reads standing instructions. -->

This project uses the **Heatwave AI Development & Verification Protocol**. Full spec: `.heatwave/PROTOCOL.md`. Read it before any production-bound change.

## Single-context rule

Your tool runs one context at a time, so the three AI roles are played by **separate sessions**, never one:

- Each session performs exactly ONE role for a task: PLANNER (`.heatwave/prompts/planner.md`), IMPLEMENTER (`.heatwave/prompts/implementer.md` / `fixer.md`), or REVIEWER (`.heatwave/prompts/plan-reviewer.md` / `reviewer.md` / `final-reviewer.md`).
- On session start, read `.heatwave/runs/<task-id>/state.yaml`. The current state tells you which role this session must play. If this session (or its conversation) already produced an artifact for this task in a conflicting role, STOP and tell the user to start a fresh session (R-1, R-2).
- Work only from artifacts in the run directory — never from memory of another role's reasoning (R-3, R-17).
- When your artifact is complete: write it into the run directory with the next sequence number, update `state.yaml` (state, counters, next_artifact, updated), append the transition to `run-record.yaml`, then tell the user which role to launch next and in which state.

## The loop never restarts (R-88)

If a non-terminal run exists for the task the user mentions, resume at its recorded state with its recorded counters. Never re-plan a planned task, never regenerate an existing artifact, never reset counters — however the request is phrased. Completed artifacts are immutable (R-89).

## Non-negotiable

- No implementation before a Planning Document passes PLAN_REVIEW with 0 Blockers / 0 Majors.
- Evidence, not assertion: attach real command output; "verified" without a method is unverified (R-65, R-70).
- The REVIEWER owns severity and deferral (R-5, R-6). The IMPLEMENTER never decides what to skip.
- IMPLEMENTER code follows the ponytail discipline: `.heatwave/plugins/ponytail/SKILL.md` (Appendix G).
- Iteration budgets per §2.3; at exhaustion, produce an Escalation Report and stop for the human OWNER.

Exempt: conversational turns, and spikes explicitly labeled as such at the outset (§0.4).
