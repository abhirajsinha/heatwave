# Verified companions

Everything below was independently verified (repo authenticity, license, official install channel, active maintenance) before being listed. Heatwave requires **none** of it — each entry strengthens a role when present, and a missing tool is always an honestly-reported gap, never a silent one. Install only from the channels shown; several projects explicitly warn against third-party mirrors.

## Protocol-wired companions (v4-D)

These companions are bound to protocol stages by core §6.5 (R-119–R-122). All remain **external, detected, optional** — absent means an explicit `NOT AVAILABLE` (R-64), never a silent skip, and never a failed run. The integration policy (R-120):

| Companion | Stage | Trigger | Cost | Default |
|---|---|---|---|---|
| gitleaks | FINAL_REVIEW (+pre-commit) | detected; every run with a FINAL | ~0 | auto-when-present |
| Semgrep | FULL_REVIEW (SAST rung) | detected; STANDARD+ changed paths | ~0 | auto-when-present |
| Mutation (Stryker/mutmut/PIT) | FULL_REVIEW (mutation rung) | detected; FULL, changed modules | CPU | auto-when-present |
| `/security-review` | FULL_REVIEW | change_surface ∩ {auth, external-input, deps, secrets, api-surface} | med tokens | on (Claude Code) |
| Playwright MCP | FULL/FINAL evidence capture | change_surface ∋ ui; MCP present | low | auto-when-present |
| context7 MCP | PLANNING | plan cites an external API | low, on-demand | optional |
| **Strix** | FULL_REVIEW → report evidence | enabled + change_surface ∩ {auth, payments, external-input, new-endpoint} + FULL | high + Docker | **opt-in** |

| Tool | What / trigger | Install | License |
|---|---|---|---|
| [Semgrep](https://github.com/semgrep/semgrep) | Binds B's `sast` gate (R-110): the reviewer runs `semgrep scan --config auto` on changed paths at STANDARD+; high-severity hits → machine findings (R-111). Detected from a `.semgrep.yml`, the binary, or a CI step. | `brew install semgrep` | LGPL-2.1 |
| [gitleaks](https://github.com/gitleaks/gitleaks) | Secrets rung at FINAL_REVIEW (R-121): scans the run's full diff; any hit is a Blocker (`secret-management`), waivable only by the OWNER (R-9). Pre-commit install RECOMMENDED — that is what covers EXPRESS runs. | `brew install gitleaks` | MIT |
| Mutation runners: [Stryker](https://github.com/stryker-mutator/stryker-js) (JS/TS), [mutmut](https://github.com/boxed/mutmut) (Python), [PIT](https://github.com/hcoles/pitest) (JVM) | Bind B's `mutation` gate (R-110) at FULL, scoped to changed modules with a declared timeout; surviving mutants → "tests inadequate" machine findings (R-111). | `npm i -D @stryker-mutator/core` / `pipx install mutmut` / Maven-Gradle plugin | Apache-2.0 / BSD-3-Clause / Apache-2.0 |
| `/security-review` (Anthropic, built into Claude Code) | Semantic security pass at FULL_REVIEW, gated by change_surface ∩ {auth, external-input, deps, secrets, api-surface} (R-120/R-122); output enters refute-or-promote (R-112). Other agents: documented equivalents below (gemini-cli-extensions/security, codex-security, ECC) or `NOT AVAILABLE`. | built in | — |
| [Strix](https://github.com/usestrix/strix) | Dynamic security scan producing PoC evidence — **opt-in only** (R-119): `dynamic_security.strix: enabled` AND change_surface ∩ {auth, payments, external-input, new-endpoint} AND tier FULL. Headless: `strix -n --target <app>`. Docker discipline: spin up → scan → tear down immediately, both timestamps in the Run Record; an up marker without a down marker is a protocol defect. Needs its own LLM credentials and a running Docker. Never routine. | `curl -sSL https://strix.ai/install \| bash` (official installer per the repo README) | Apache-2.0 |

## Evidence & verification (REVIEWER)

| Companion | What it adds | Official install | License |
|---|---|---|---|
| [Playwright MCP](https://github.com/microsoft/playwright-mcp) (Microsoft) | Real-browser E2E evidence: drive the app, click/fill/assert, screenshots + network logs. **Protocol role (v4-D, R-120):** UI-evidence capture at FULL/FINAL when `change_surface` ∋ ui — a11y assertions + screenshot cited against UI acceptance criteria | Claude: `claude mcp add playwright -- npx @playwright/mcp@latest` · Codex: `codex mcp add playwright -- npx @playwright/mcp@latest` · Gemini: `gemini mcp add playwright npx @playwright/mcp@latest` | Apache-2.0 |
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
| [Context7](https://github.com/upstash/context7) (Upstash) | Current, version-correct library docs — fewer hallucinated APIs, fewer review findings. **Protocol role (v4-D, R-120):** on-demand docs lookup at PLANNING when the plan cites an external API — never always-on | `claude mcp add context7 -- npx -y @upstash/context7-mcp` | MIT |
| [Serena](https://github.com/oraios/serena) (oraios) | LSP-backed semantic code navigation for precise edits (needs `uv`/Python) | `claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server` | MIT |
| [claude-mem](https://github.com/thedotmack/claude-mem) | Cross-session conversational memory — complements Heatwave's on-disk task state | `/plugin marketplace add thedotmack/claude-mem` → `/plugin install claude-mem` | Apache-2.0 |
| [Ponytail](https://github.com/DietrichGebert/ponytail) | The implementer's minimalism discipline — **bundled with Heatwave** (and exposed via `.agents/skills/` for Codex/Gemini) | bundled | MIT |

## Notes

- MCP suggestions use each vendor's officially documented `@latest` command. If your threat model prefers pinned versions, pin them — and know you're then responsible for updates.
- Paid SaaS reviewers (CodeRabbit, Greptile, Qodo) are documented options only, never protocol gates — Heatwave's isolated REVIEWER already has full-repo context (spec non-goal; R-120 wires nothing paid).
- Point browser/database tools at **local or dev environments**, never production.
- Roadmap (researched, deliberately deferred until designed properly): epic decomposition into linked runs; `heatwave-lint`, a deterministic CI checker for run-directory conformance.
