# Heatwave protocol (binding)

<!-- Codex reads AGENTS.md at the repo root. Append this block to your existing AGENTS.md,
     or let install.sh do it. -->

This project runs under the Heatwave AI Development & Verification Protocol.

**Before any production-bound change, read and follow, in order:**

1. `.heatwave/HEATWAVE-AGENT.md` — your binding operating rules (single-context role sessions, the never-restart resume rule, the gates).
2. `.heatwave/PROTOCOL.md` — the full specification.

Summary of what binds you: check `.heatwave/runs/*/state.yaml` before acting and resume active runs at their recorded state; play exactly one role (PLANNER / IMPLEMENTER / REVIEWER) per session per task; no implementation before an approved plan; evidence, not assertion; reviewer owns severity; ponytail discipline (`.heatwave/plugins/ponytail/SKILL.md`) governs implementation code. Conversational turns and explicitly-labeled spikes are exempt.
