---
trigger: always_on
description: Heatwave AI Development & Verification Protocol (binding)
---

# Heatwave protocol (binding)

This project runs under the Heatwave AI Development & Verification Protocol.

Before any production-bound change, read and follow, in order: `.heatwave/HEATWAVE-AGENT.md` (binding operating rules), then `.heatwave/PROTOCOL.md` (full spec).

Summary of what binds you: check `.heatwave/runs/*/state.yaml` before acting and resume active runs at their recorded state; play exactly one role (PLANNER / IMPLEMENTER / REVIEWER) per session per task; no implementation before an approved plan; evidence, not assertion; reviewer owns severity; ponytail discipline (`.heatwave/plugins/ponytail/SKILL.md`) governs implementation code. The loop runs non-stop (R-95): stop only at a terminal state, an escalation, or a decision reserved for the human. Conversational turns and explicitly-labeled spikes are exempt.
