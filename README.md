<p align="center">
  <img src="assets/banner.svg" width="880" alt="Heatwave — a verification protocol for AI-written code. Plan, build, review, prove, in a loop that never silently restarts.">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/license-MIT-ff6b35?style=for-the-badge" alt="MIT license">
  <img src="https://img.shields.io/badge/dependencies-zero-ff6b35?style=for-the-badge" alt="Zero dependencies">
  <img src="https://img.shields.io/badge/protocol-v3.1-ff6b35?style=for-the-badge" alt="Protocol v3.1">
</p>

<p align="center">
  <strong>Works with</strong><br><br>
  <img src="https://img.shields.io/badge/Claude%20Code-subagent%20isolation-1a1027?style=flat-square&labelColor=d97757&logoColor=white" alt="Claude Code">
  <img src="https://img.shields.io/badge/Codex-AGENTS.md-1a1027?style=flat-square&labelColor=333333" alt="Codex">
  <img src="https://img.shields.io/badge/Gemini%20CLI-GEMINI.md-1a1027?style=flat-square&labelColor=4285f4" alt="Gemini CLI">
  <img src="https://img.shields.io/badge/Cursor-rules-1a1027?style=flat-square&labelColor=6c47ff" alt="Cursor">
  <img src="https://img.shields.io/badge/any%20agent-generic%20adapter-1a1027?style=flat-square&labelColor=10b981" alt="Any agent">
</p>

---

## Your AI agent is lying to you (politely)

Not maliciously — structurally. Every AI coding agent has the same three failure modes:

<table>
<tr>
<td width="33%" valign="top">

### 🪞 It grades its own homework
The same context that wrote the code decides the code is fine. That isn't review — it's a mirror. Real defects survive because the author's blind spots review the author's blind spots.

</td>
<td width="33%" valign="top">

### 🗣️ It says "verified ✅"
Ask if it tested every screen and you'll get a confident, detailed, *plausible* account of testing that never happened. No method, no output, no evidence — just vibes.

</td>
<td width="33%" valign="top">

### 🔁 It restarts from zero
Session dies at 80% done. The next session re-plans the planned, re-implements the reviewed, and every guarantee you thought you had resets to nothing.

</td>
</tr>
</table>

**Heatwave closes all three** — with nothing but markdown files and a folder. No server, no SDK, no API keys, no lock-in. If your AI tool can read files, it can run Heatwave.

| Failure | Heatwave's answer |
|---|---|
| Self-review | **Three isolated roles** — PLANNER, IMPLEMENTER, REVIEWER — in separate contexts. No context ever evaluates its own output. Ever. (R-1, R-2) |
| Asserted verification | **Evidence or it didn't happen.** Every "fixed" must attach the executed verification output. A claimed verification with no evidence is an automatic Blocker — same severity as a data-loss bug. (R-65) |
| The random restart | **The loop lives on disk**, not in any session's memory. Any session, in any tool, must resume a run exactly where it stopped. Restarting is a protocol violation, not an accident. (R-88) |

## How it works

One state machine. Each state owned by one role. Every transition produces an artifact file the next role consumes:

<p align="center">
  <img src="assets/loop.svg" width="920" alt="The Heatwave loop: PLANNING → PLAN_REVIEW → IMPLEMENTING → FULL_REVIEW → FIXING ⇄ TARGETED_REVIEW → FINAL_REVIEW → APPROVED, with rejection loops, budgets 3/5/2, and ESCALATED to the human owner when a budget is exhausted. Every transition lands in state.yaml first.">
</p>

**The gate is absolute:** zero open Blockers, zero open Majors — and the REVIEWER, never the implementer, decides severity and what may be deferred. Every loop has an iteration budget (3 plan rejections / 5 fix rounds / 2 final-review failures); when one runs out, Heatwave stops and asks *you* one specific, answerable question. You decide, counters reset, the loop resumes. Nothing is terminal except `APPROVED` and `ABANDONED`.

### The cast

| Role | Played by | Owns |
|---|---|---|
| 🧠 **PLANNER** | an AI context | What to build — plan, acceptance criteria, review scope |
| 🔨 **IMPLEMENTER** | a *different* AI context | The code, tests, and evidence — under the [ponytail](#-ponytail-built-in) minimalism discipline |
| 🔍 **REVIEWER** | a *different* AI context | Whether it's correct — findings, severity, final approval |
| 👤 **OWNER** | **you** | Escalations, waivers, judgment calls |

> The isolation boundary is the **context, not the model** — one model can play all three roles from fresh contexts (R-12). The REVIEWER receives *artifacts, never transcripts*: it judges what was produced, not what was intended.

### The loop that survives anything

Everything a run produces lives in your repo:

```
.heatwave/runs/2026-07-18-add-export/
├── state.yaml                    ← current state + counters: the resume anchor
├── run-record.yaml               ← append-only audit trail
├── 01-planning-document.md       🧠
├── 02-plan-review-1.md           🔍  approved
├── 03-implementation-package.md  🔨
├── 04-review-report-1.md         🔍  2 Majors found
├── 05-fix-report-1.md            🔨  fixes + executed verification output
└── ...
```

Kill your terminal after artifact 05. Tomorrow — in a new session, even in a **different tool** — say *"continue the export feature."* The driver reads `state.yaml`, sees `TARGETED_REVIEW`, and dispatches a reviewer with artifacts 01–05. Nothing re-planned, nothing re-implemented, no counter reset. You can plan with Claude Code today and review with Gemini tomorrow; the files on disk are the interface. Deep dive: [docs/loop.md](docs/loop.md).

### Right-sized ceremony

A one-line copy fix doesn't need a rollout plan. Three tiers scale the paperwork — never the gates:

| | LIGHT | STANDARD | FULL |
|---|---|---|---|
| **For** | one-file fixes, copy, config | a normal feature or bugfix | migrations, auth, money, user data |
| **Planning doc** | 4 sections | all sections, N/A allowed | everything, no shortcuts |
| **Reviews** | plan review, then one combined code+final pass | full state machine | full machine + item-by-item readiness checklist |
| **Plan reviewed before code?** | ✅ always | ✅ always | ✅ always |
| **Evidence required?** | ✅ always | ✅ always | ✅ always |

## 🚀 Get running in 60 seconds

```sh
git clone https://github.com/abhirajsinha/heatwave.git
cd heatwave
./install.sh /path/to/your/project claude    # or: codex | gemini | cursor | generic
```

Then edit the generated `heatwave.config.yaml` once (your models, which test tooling actually exists), and ask your agent for a feature:

> *"Add CSV export to the reports page."*

That's it. The agent enters `PLANNING` and the loop takes over. You're pulled in only when the protocol genuinely needs a human.

<details>
<summary><strong>What exactly does install.sh do?</strong></summary>

<br>

- Copies `PROTOCOL.md`, `prompts/`, `templates/`, and the ponytail skill into `<project>/.heatwave/`
- Installs your tool's adapter: appends a Heatwave block to `CLAUDE.md` / `AGENTS.md` / `GEMINI.md`, or drops `.cursor/rules/heatwave.mdc`, plus three subagent definitions for Claude Code
- Creates `heatwave.config.yaml` from the example (once — never overwritten)
- Is idempotent: re-run anytime to update; your config and your runs are never touched

</details>

## 🤖 One protocol, every agent

Heatwave governs **contexts and artifacts**, not vendor features — so it ports anywhere:

| Tool | Adapter installs | How role isolation works |
|---|---|---|
| **Claude Code** | `CLAUDE.md` block + 3 subagents | Session = driver; each role runs as a **fresh subagent** — true isolation inside one session |
| **Codex** | `AGENTS.md` block | Each role is a fresh session; the run directory carries state between them |
| **Gemini CLI** | `GEMINI.md` block | Same sequential-session driver |
| **Cursor** | `.cursor/rules/heatwave.mdc` | Same sequential-session driver |
| **Anything else** | `.heatwave/HEATWAVE-AGENT.md` | Paste into any tool's system prompt or rules — works with anything that reads and writes files |

## 🧳 Zero dependencies, by design

What Heatwave is made of — and everything it *doesn't* need:

| | |
|---|---|
| **Uses** | Markdown files, one POSIX `sh` script, a folder in your repo. Nothing else. |
| **Bundles** | The [Ponytail](https://github.com/DietrichGebert/ponytail) skill *text* (MIT, vendored with attribution) — plain instructions, portable everywhere. |
| **Does NOT use** | ❌ MCP servers ❌ plugins ❌ frameworks ❌ SDKs ❌ API keys ❌ a server ❌ any other skill system |

Your agent's own plugins (superpowers, MCP tools, whatever you've installed) can happily coexist and even make the roles better at their jobs — but Heatwave never depends on them. Clone on a bare machine; everything works.

## 🦥 Ponytail, built in

Strict verification has a side effect: implementers gold-plate, because over-building *looks* like diligence. Heatwave counters it by bundling **[Ponytail](https://github.com/DietrichGebert/ponytail)** (MIT, © Dietrich Gebert) and binding it to the IMPLEMENTER role:

> Does this need to exist? → Already in the codebase? → Stdlib? → Native platform feature? → Existing dependency? → One line? → *Only then* write the minimum code that works.

The result is the **shortest diff that meets the acceptance criteria** — which is also the cheapest diff to review honestly. The reviewer's bar is untouched ("lazy" never means unverified), over-engineering is itself a reviewable finding, and every deliberate shortcut gets a `ponytail:` comment that lands in the package's Known Limitations for the reviewer to judge.

## 📦 What's in the box

```
heatwave/
├── PROTOCOL.md                  ★ the full spec (v3.1) — 96 numbered rules, each with
│                                  the failure it exists to prevent
├── install.sh                   one-command install into any project
├── heatwave.config.example.yaml models per role · budgets · your project's real tooling
├── prompts/                     7 ready-made role prompts (driver, planner, plan-reviewer,
│                                  implementer, reviewer, fixer, final-reviewer)
├── templates/                   6 artifact templates (plan, package, review, fix,
│                                  escalation, run record)
├── adapters/                    claude-code · codex · gemini · cursor · generic
├── plugins/ponytail/            vendored skill + license + attribution
└── docs/                        loop.md (persistence deep-dive) · faq.md
```

## 📖 Go deeper

- **[PROTOCOL.md](PROTOCOL.md)** — the spec itself. Readable by humans, enforceable on AIs.
- **[docs/loop.md](docs/loop.md)** — anatomy of a run, the resume rule, crash edge cases.
- **[docs/faq.md](docs/faq.md)** — *one model? too much ceremony? what stops the AI from cheating?*

## License

MIT © Abhiraj Sinha · vendored Ponytail skill MIT © Dietrich Gebert ([attribution](plugins/ponytail/ATTRIBUTION.md))

---

<p align="center"><sub>Heatwave grew out of a real production workflow for shipping AI-built apps, hardened over three protocol versions.<br>The failure modes it guards against are ones we hit — not ones we imagined.</sub></p>
