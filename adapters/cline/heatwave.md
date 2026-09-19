# Heatwave protocol (binding)

This project runs under the Heatwave AI Development & Verification Protocol.

Before any production-bound change, read and follow, in order: `.heatwave/HEATWAVE-AGENT.md` (binding operating rules), then `.heatwave/PROTOCOL.md` (full rendered spec) — your working set is `.heatwave/protocol/core.md` + your role's shard.

Summary of what binds you: check `.heatwave/runs/*/state.yaml` before acting and resume active runs at their recorded state; play exactly one role (PLANNER / IMPLEMENTER / REVIEWER) per session per task; no implementation before an approved plan (EXPRESS excepted, R-104; at LIGHT the implementer writes the plan first and one combined independent review judges it, R-123); evidence, not assertion; reviewer owns severity; ponytail discipline (`.heatwave/plugins/ponytail/SKILL.md`) governs implementation code. The loop runs non-stop (R-95): stop only at a terminal state, an escalation, or a decision reserved for the human. Conversational turns and explicitly-labeled spikes are exempt.

Jira mode (v4.3): when a task names a Jira issue — a key like `NAV-1234` as its first token, or an `atlassian.net/browse/<KEY>` URL — the driver fetches the ticket read-only through the Atlassian MCP and works from a structured Requirement Brief; if the MCP is absent it reports `NOT AVAILABLE` with the install pointer and asks you to paste the ticket, never a silent fall-through to free text (R-127–R-130).

- v5 (R-133 / R-142): the REVIEWER drives the real built product for every runtime acceptance criterion before APPROVED — a code read is never enough; and every report (plan review, review, final, escalation, express, LIGHT, run summary) opens with a plain-language section a non-technical reader understands, moving rule IDs and file:line into a "For the engineer" part below.

## Context/token engine (v5.1, R-143–R-147)

- **Fresh implementer slice = artifacts only.** A long build or fix may be sliced: the IMPLEMENTER writes a compact handoff (`.heatwave/templates/implementer-handoff.md`: done ACs, files changed, failing checks, hypothesis, next action — paths/names only) and a fresh IMPLEMENTER context continues from **artifacts only** — the plan, the repo map, the latest handoff, prior reports — never a transcript (R-85/R-144). Slices are re-dispatches within the same IMPLEMENTING/FIXING state and do not touch counters.
- **Repo map (R-146):** the driver hands `.heatwave/cache/repo-map.md` (cached, LLM-free, keyed on HEAD sha + working-tree content hash) to the planner and implementer so a fresh context does not re-explore the tree.
- **Stall-proof writing (R-147):** write long artifacts incrementally (small write, then appends); bound slow commands with a portable timeout `perl -e 'alarm N; exec @ARGV' <cmd>` (macOS has no `timeout(1)`); cite long output by file path; a watchdog stall is a **resumable** event (R-88), never a restart.
