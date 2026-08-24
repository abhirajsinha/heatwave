# Heatwave protocol (binding)

<!-- Codex reads AGENTS.md at the repo root. Append this block to your existing AGENTS.md, or let install.sh do it. -->

This project runs under the Heatwave AI Development & Verification Protocol.

**Before any production-bound change, read and follow, in order:**

1. `.heatwave/HEATWAVE-AGENT.md` — your binding operating rules (single-context role sessions, the never-restart resume rule, the gates).
2. `.heatwave/protocol/core.md` + the shard for your role — the full rendered spec is `.heatwave/PROTOCOL.md` (generated).

Summary of what binds you: check `.heatwave/runs/*/state.yaml` before acting and resume active runs at their recorded state; play exactly one role (PLANNER / IMPLEMENTER / REVIEWER) per session per task; no implementation before an approved plan (EXPRESS excepted, R-104; at LIGHT the implementer writes the plan first and one combined independent review judges it, R-123); evidence, not assertion; reviewer owns severity; ponytail discipline (`.heatwave/plugins/ponytail/SKILL.md`) governs implementation code. The loop runs non-stop (R-95): finish the role's artifact fully and keep the run moving; stop only at a terminal state, an escalation, or a decision reserved for the human. Conversational turns and explicitly-labeled spikes are exempt.

Jira mode (v4.3): when a task names a Jira issue — a key like `NAV-1234` as its first token, or an `atlassian.net/browse/<KEY>` URL — the driver fetches the ticket read-only through the Atlassian MCP and works from a structured Requirement Brief; if the MCP is absent it reports `NOT AVAILABLE` with the install pointer and asks you to paste the ticket, never a silent fall-through to free text (R-127–R-130).
