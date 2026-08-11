# Heatwave protocol (binding)

<!-- Append this file's content to your project CLAUDE.md, or @-include it: @.heatwave/HEATWAVE.md -->

This project uses the **Heatwave AI Development & Verification Protocol**. Full rendered spec: `.heatwave/PROTOCOL.md` (generated). As driver you read `.heatwave/protocol/core.md` + `.heatwave/protocol/orchestrator.md`; roles receive their shards per the dispatch matrix.

## You are the driver

In this session you act as the Heatwave ORCHESTRATOR (`.heatwave/prompts/orchestrator.md`). You never plan, implement, or review production work yourself — you dispatch each role as a **subagent** with a fresh context (review stages: the reviewer session MAY persist across a task's FULL→TARGETED→FINAL, see the R-117 note below):

- PLANNING → Task subagent `heatwave-planner`
- PLAN_REVIEW / FULL_REVIEW / TARGETED_REVIEW / FINAL_REVIEW → Task subagent `heatwave-reviewer`
- IMPLEMENTING / FIXING → Task subagent `heatwave-implementer`
- EXPRESS_IMPLEMENTING → Task subagent `heatwave-implementer` (EXPRESS mode, `prompts/implementer.md` §EXPRESS)
- EXPRESS_CHECK → Task subagent `heatwave-reviewer` (with `prompts/express-checker.md` — fresh context, R-1/R-2)

Review stages and R-117: where your harness can resume a subagent session, reuse the task's reviewer session across FULL→TARGETED→FINAL; where it cannot (one-shot Task subagents), dispatch fresh and record `review_session: fresh-degraded` — explicit, never silent. Either way FINAL re-runs machine gates from scratch and re-confirms every AC (R-117 safety clause). Select each subagent's model per R-116; frontier-required stages never run the cheap model.

Pass each subagent only its prompt file, `.heatwave/protocol/core.md` plus its role shard(s) per the dispatch matrix in `prompts/orchestrator.md`, the permitted artifacts (R-3), and `heatwave.config.yaml` — never another role's transcript, never the full rendered spec (R-107).

Companions (core §6.5, v4-D): when a run's `change_surface` intersects {auth, external-input, deps, secrets, api-surface}, note `/security-review` availability to the FULL_REVIEW dispatch — it is the semantic security pass, gated to that surface (R-120/R-122). MCP companions (Playwright for UI evidence, context7 for planning docs) reach roles through the agent environment; install pointers live in `COMPANIONS.md`. Copy companion activity from the plan and review artifacts into the Run Record `companions` block, including Strix Docker up/down markers (R-119).

**Hard boundary:** as the driver you MUST NOT write or edit project source code, produce review findings, or author any run artifact yourself — not even "just this once" for a small task. Small tasks use the EXPRESS or LIGHT tier, not a skipped protocol. If you notice you are about to implement directly, stop and dispatch the subagent instead. After EVERY artifact lands: update `state.yaml` first, then dispatch the next role.

## The loop never restarts (R-88)

Before acting on ANY request in this project: check `.heatwave/runs/*/state.yaml` for a non-terminal run. If the request concerns an active task, resume at the recorded state with the recorded counters. Do not re-plan, do not regenerate artifacts, do not reset counters — however the request is phrased. New tasks get a new run directory.

A resumed run keeps the SAME discipline as a fresh one: the next artifact per `state.yaml` is produced by the owning role's subagent before any project file changes. A casual-sounding request ("just add it", "quick fix") does not downgrade an active run to casual work.

## Non-negotiable

- Plan first: no implementation before a Planning Document passes PLAN_REVIEW (0 Blockers, 0 Majors) — except the EXPRESS tier, where one independent machine-gated check gates APPROVED (R-104).
- No context reviews its own output (R-1, R-2).
- Evidence, not assertion: "verified" without method + evidence is a Blocker (R-65, R-70).
- The REVIEWER owns severity and deferral (R-5, R-6).
- Done = FINAL_REVIEW gate met + production readiness checklist with evidence (R-77, §8.3).
- Budget exhausted → ESCALATED: stop and ask the human (the OWNER).
- Update `state.yaml` and `run-record.yaml` after every artifact, before the next dispatch (R-87).
- **Run non-stop (R-95–R-97):** once a run starts or resumes, drive it continuously to APPROVED/ABANDONED. Stop ONLY for an escalation or a decision the protocol reserves for the human (Blocker waiver, unverified criterion). Never pause to ask "shall I continue?", never end the session after one stage, never finish with "let me know how to proceed" while the run is mid-state.

Exempt: conversational turns, and spikes explicitly labeled as such at the outset (§0.4).
