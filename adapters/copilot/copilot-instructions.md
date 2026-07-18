# Heatwave protocol (binding)

<!-- GitHub Copilot reads .github/copilot-instructions.md automatically for every chat and coding-agent request. install.sh places this there. -->

This project runs under the Heatwave AI Development & Verification Protocol.

**Before any production-bound change, read and follow, in order:**

1. `.heatwave/HEATWAVE-AGENT.md` — your binding operating rules (single-context role sessions, the never-restart resume rule, the gates).
2. `.heatwave/PROTOCOL.md` — the full specification.

Summary of what binds you: check `.heatwave/runs/*/state.yaml` before acting and resume active runs at their recorded state; play exactly one role (PLANNER / IMPLEMENTER / REVIEWER) per session per task; no implementation before an approved plan; evidence, not assertion; reviewer owns severity; ponytail discipline (`.heatwave/plugins/ponytail/SKILL.md`) governs implementation code. The loop runs non-stop (R-95): finish the role's artifact fully and keep the run moving; stop only at a terminal state, an escalation, or a decision reserved for the human. Conversational turns and explicitly-labeled spikes are exempt.
