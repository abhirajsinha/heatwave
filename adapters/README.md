# Adapters

An adapter is the only tool-specific piece of Heatwave: a small shim that puts the binding rules where a given agent reads its standing instructions. Everything else — PROTOCOL.md, prompts, templates, the run directory — is identical for every agent.

## Supported tools

| Tool | Where the rules land (auto-loaded) | Active enforcement |
|---|---|---|
| Claude Code | `CLAUDE.md` + `.claude/agents/` subagents | ✅ prompt hooks + `PreToolUse` write-gate |
| Codex | `AGENTS.md` | ✅ `.codex/hooks.json` per-prompt gate |
| Gemini CLI | `GEMINI.md` | ✅ `.gemini/settings.json` BeforeAgent gate |
| Cursor | `.cursor/rules/heatwave.mdc` | passive (always-on rule) |
| GitHub Copilot | `.github/copilot-instructions.md` | passive (always applied) |
| Windsurf / Devin | `.windsurf/rules/` + `.devin/rules/` | passive (`always_on`) |
| Cline | `.clinerules/` | passive (every session) |
| Zed | `.rules` | passive (first-match) |
| Amp / opencode | `AGENTS.md` standard | passive |
| Aider | `CONVENTIONS.md` + `.aider.conf.yml` | passive |
| Generic | `.heatwave/HEATWAVE-AGENT.md` | passive (paste anywhere) |

"Active enforcement" means a hook re-injects the protocol every turn (and, on Claude Code, physically blocks source edits during plan/review states) — the rules can't fade from a long conversation. "Passive" means always-on instruction text, which every listed file already is.

## Writing an adapter for a new tool

Any agent qualifies if it can (1) read/write files and (2) follow project instructions. To support one:

1. Find where the tool reads standing instructions (a root file like `AGENTS.md`, a rules directory, or a system prompt setting).
2. Create `adapters/<tool>/` with a file that says, in order:
   - This project runs under Heatwave; read `.heatwave/HEATWAVE-AGENT.md` then `.heatwave/PROTOCOL.md` before production-bound changes.
   - The one-paragraph summary of what binds the agent (copy it from `codex/AGENTS.md` — resume rule, one role per session, plan before code, evidence, non-stop, ponytail).
3. Add a case to `install.sh` that places the file (append with `append_once` for root instruction files; copy for rules directories).
4. If the tool has hooks or per-turn injection, wire `.heatwave/GATE.md` into it (see the `claude)` case) — that upgrades enforcement from passive to active.

That's the whole job — usually under 20 lines. PRs welcome.
