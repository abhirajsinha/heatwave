# Heatwave protocol (binding)

<!-- Gemini CLI reads GEMINI.md at the repo root. Append this block to your existing GEMINI.md, or let install.sh do it. -->

This project runs under the Heatwave AI Development & Verification Protocol.

**Before any production-bound change, read and follow, in order:**

1. `.heatwave/HEATWAVE-AGENT.md` — your binding operating rules (single-context role sessions, the never-restart resume rule, the gates).
2. `.heatwave/protocol/core.md` + the shard for your role — the full rendered spec is `.heatwave/PROTOCOL.md` (generated).

Summary of what binds you: check `.heatwave/runs/*/state.yaml` before acting and resume active runs at their recorded state; play exactly one role (PLANNER / IMPLEMENTER / REVIEWER) per session per task; no implementation before an approved plan (EXPRESS tier excepted: one independent machine-gated check gates APPROVED, R-104); evidence, not assertion; reviewer owns severity; ponytail discipline (`.heatwave/plugins/ponytail/SKILL.md`) governs implementation code. The loop runs non-stop (R-95): finish the role's artifact fully and keep the run moving; stop only at a terminal state, an escalation, or a decision reserved for the human. Conversational turns and explicitly-labeled spikes are exempt.
