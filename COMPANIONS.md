# Verified companions

Everything below was independently verified (repo authenticity, license, official install channel, active maintenance) before being listed. Heatwave requires **none** of it — each entry strengthens a role when present, and a missing tool is always an honestly-reported gap, never a silent one. Install only from the channels shown; several projects explicitly warn against third-party mirrors.

## Evidence & verification (REVIEWER)

| Companion | What it adds | Official install | License |
|---|---|---|---|
| [Playwright MCP](https://github.com/microsoft/playwright-mcp) (Microsoft) | Real-browser E2E evidence: drive the app, click/fill/assert, screenshots + network logs | Claude: `claude mcp add playwright -- npx @playwright/mcp@latest` · Codex: `codex mcp add playwright -- npx @playwright/mcp@latest` · Gemini: `gemini mcp add playwright npx @playwright/mcp@latest` | Apache-2.0 |
| [Chrome DevTools MCP](https://github.com/ChromeDevTools/chrome-devtools-mcp) (Google) | Runtime debugging evidence: console errors, network, performance traces (use `--isolated` for CI-like runs) | `claude mcp add chrome-devtools -- npx chrome-devtools-mcp@latest` (same pattern for codex/gemini) | Apache-2.0 |
| [MCP Toolbox for Databases](https://github.com/googleapis/genai-toolbox) (Google) | Verify migrations and data effects against real databases — point it at dev/staging with a read-mostly user, never prod | `brew install mcp-toolbox`, then connect your MCP client | Apache-2.0 |
| [code-review](https://github.com/anthropics/claude-plugins-official) (Anthropic) | Confidence-scored multi-agent PR review as a second opinion | `/plugin install code-review@claude-plugins-official` | Proprietary — suggest-only |
| [pr-review-toolkit](https://github.com/anthropics/claude-plugins-official) (Anthropic) | Specialist review lenses: tests, error handling, types | `/plugin install pr-review-toolkit@claude-plugins-official` | Proprietary — suggest-only |
| [ECC security](https://github.com/affaan-m/ECC) | Security scanning for the security review categories | `/plugin marketplace add affaan-m/ECC` → `/plugin install ecc@ecc` (official channels ONLY — its own policy warns about mirrors) | MIT |
| [codex-security](https://github.com/openai/plugins) (OpenAI) | Security review pass inside Codex sessions | `codex plugin marketplace add openai/plugins` → install `codex-security` | Proprietary — suggest-only |
| [gemini-cli-extensions/security](https://github.com/gemini-cli-extensions/security) (Google) | `/security:analyze` for changes and PRs in Gemini CLI | `gemini extensions install https://github.com/gemini-cli-extensions/security` | Apache-2.0 |
| [codex-plugin-cc](https://github.com/openai/codex-plugin-cc) (OpenAI) | Cross-vendor review: run Codex as an isolated reviewer from inside Claude Code (needs an OpenAI account) | `/plugin marketplace add openai/codex-plugin-cc` → `/plugin install codex@openai-codex` | Apache-2.0 |

## Method & knowledge (PLANNER · IMPLEMENTER)

| Companion | What it adds | Official install | License |
|---|---|---|---|
| [superpowers](https://github.com/obra/superpowers) (obra) | Battle-tested process skills: brainstorming → written plans, TDD, systematic debugging, verification-before-completion | `/plugin install superpowers@claude-plugins-official` | MIT |
| [ui-ux-pro-max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | Design intelligence for UI acceptance criteria and implementation — **fetched automatically by the Claude Code install** | auto (or clone from its repo) | MIT |
| [Context7](https://github.com/upstash/context7) (Upstash) | Current, version-correct library docs — fewer hallucinated APIs, fewer review findings | `claude mcp add context7 -- npx -y @upstash/context7-mcp` | MIT |
| [Serena](https://github.com/oraios/serena) (oraios) | LSP-backed semantic code navigation for precise edits (needs `uv`/Python) | `claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server` | MIT |
| [claude-mem](https://github.com/thedotmack/claude-mem) | Cross-session conversational memory — complements Heatwave's on-disk task state | `/plugin marketplace add thedotmack/claude-mem` → `/plugin install claude-mem` | Apache-2.0 |
| [Ponytail](https://github.com/DietrichGebert/ponytail) | The implementer's minimalism discipline — **bundled with Heatwave** (and exposed via `.agents/skills/` for Codex/Gemini) | bundled | MIT |

## Notes

- MCP suggestions use each vendor's officially documented `@latest` command. If your threat model prefers pinned versions, pin them — and know you're then responsible for updates.
- Point browser/database tools at **local or dev environments**, never production.
- Roadmap (researched, deliberately deferred until designed properly): epic decomposition into linked runs; `heatwave-lint`, a deterministic CI checker for run-directory conformance.
