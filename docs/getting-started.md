# Getting started — full walkthrough

From zero to your first protocol-verified feature, step by step.

## Prerequisites

- Any AI coding agent: Claude Code, Codex, Gemini CLI, Cursor, or anything that reads project instruction files
- `git` and a POSIX shell (macOS, Linux, WSL — all fine)
- A project you want to build in (existing or brand new)

## Step 1 — Get Heatwave

```sh
git clone https://github.com/abhirajsinha/heatwave.git
```

Clone it anywhere — your home directory is fine. This copy is the "source"; you install *from* it into each project.

## Step 2 — Install into your project

```sh
cd heatwave
./install.sh /path/to/your/project claude
```

Replace `claude` with your tool: `codex` · `gemini` · `cursor` · `generic`.

What lands in your project:

```
your-project/
├── .heatwave/               ← protocol, prompts, templates, ponytail (Heatwave's runtime)
│   └── runs/                ← every task's state + artifacts will live here
├── heatwave.config.yaml     ← yours to edit (created once, never overwritten)
├── CLAUDE.md                ← adapter block appended (AGENTS.md / GEMINI.md / .cursor/rules per tool)
├── .claude/agents/          ← 3 role subagents (Claude Code only)
├── .claude/settings.json    ← gate hooks merged in (Claude Code only): the protocol gate is
│                              re-injected on every prompt + session start via .heatwave/GATE.md
└── .claude/skills/ui-ux-pro-max/  ← companion design skill (Claude Code only), fetched from its
                               official repo at install time; skipped gracefully when offline
```

Re-running `install.sh` later upgrades `.heatwave/` and never touches your config or runs.

## Step 3 — Configure (usually: nothing)

Out of the box, no configuration is needed:

- **Models** — every role runs on the model your session already uses. One model in three fresh contexts satisfies the isolation rules; different models per role is an upgrade, not a requirement.
- **Test tooling** — auto-detected from your project by the planner (R-99): `package.json` scripts and devDependencies (jest, vitest, mocha, playwright, cypress), `pytest.ini`/`pyproject.toml`, `go.mod`, `Cargo.toml`, `.maestro/`, `ios/` and `android/` folders, CI workflows. The plan cites the file proving each tool exists, and the plan reviewer checks those citations against the repo — so nothing can be "declared" that isn't really there.

The generated `heatwave.config.yaml` is entirely commented-out overrides. Open it only when you want to:

- run different models per role (uncorrelated blind spots),
- declare a tool that leaves no trace in the repo (a load-test rig, a device farm),
- pin `mobile_platform: ios | android | both` so mobile tasks never ask,
- change iteration budgets or the default tier.

If a test type genuinely has no tool (nothing detected, nothing configured), Heatwave says so honestly: affected criteria are reported *Unverified* for you to waive — never silently marked passed.

## Step 4 — Start your first task

Open your agent in the project and ask for something real:

> "Add a dark-mode toggle to the settings screen."

No special command, no magic words. The adapter makes your agent check for the protocol, and you'll see it enter the loop:

1. **A run directory appears** — `.heatwave/runs/dark-mode-toggle/` with `state.yaml`
2. *(Mobile projects only)* it asks once: **"Test on iOS, Android, or both?"**
3. **PLANNING** — a planner context writes `01-planning-document.md`: acceptance criteria with IDs, review scope, tooling declaration
4. **PLAN_REVIEW** — a *different* context reviews the plan. Rejections are normal and good — the plan iterates until 0 Blockers / 0 Majors
5. **IMPLEMENTING** — only now is code written, to the approved plan, minimal-diff (ponytail)
6. **FULL_REVIEW → (FIXING ⇄ TARGETED_REVIEW) → FINAL_REVIEW** — findings get fixed *with executed verification evidence attached*, until the gate is met
7. **APPROVED** — you get the summary; every claim traceable to an artifact

The loop runs non-stop. You're interrupted only for: the platform question (once), an escalation (a budget ran out — you get one specific question), or a decision the protocol reserves for humans.

## Step 5 — Reading a run (optional but satisfying)

Everything is plain markdown in `.heatwave/runs/<task>/`:

| File | What it tells you |
|---|---|
| `state.yaml` | Where the run is right now, and the iteration counters |
| `01-planning-document.md` | What was agreed before any code |
| `*-plan-review*.md`, `*-review-report*.md` | Every finding, severity, and verdict |
| `*-fix-report*.md` | What was fixed, with the actual command output as proof |
| `run-record.yaml` | The append-only audit trail of the whole run |

Want to check on a run? `cat .heatwave/runs/*/state.yaml`.

## Resuming — the part that just works

Terminal died? Laptop slept? Context window ran out? Days passed?

Open a new session and say **"continue the dark-mode toggle"** (or just mention the task). The driver reads `state.yaml` and resumes at the exact recorded state — it will refuse to re-plan or re-implement finished stages, even if you say "start fresh." To genuinely start over, tell it to abandon the run; that's recorded as an OWNER decision.

You can even switch tools mid-run: the artifacts on disk are the whole interface.

## Escalations — when it needs you

If a loop can't converge (plan rejected 3×, fixes failing 5×, final review failing 2×), the run stops with an **Escalation Report** ending in one specific question, like:

> "AC-N-01 requires load testing but no load tool is declared. Waive the criterion, add a tool, or descope it?"

You answer, counters reset per your decision, the loop resumes. Escalation is a checkpoint, not a failure.

## Uninstalling

Delete `.heatwave/`, `heatwave.config.yaml`, and the Heatwave block from your instruction file. On Claude Code, also delete `.claude/agents/heatwave-*.md`, `.claude/skills/ui-ux-pro-max/` (if you don't want to keep the companion skill), and remove the two Heatwave hook entries (the ones running `cat .heatwave/GATE.md …`) from `.claude/settings.json`. Runs are plain files — archive them if you want the audit history.

## Troubleshooting

| Symptom | Fix |
|---|---|
| Agent ignores the protocol entirely | Check the adapter block exists in the file your tool actually reads (`CLAUDE.md` / `AGENTS.md` / `GEMINI.md` / `.cursor/rules/heatwave.mdc`) and starts with "Heatwave protocol (binding)" |
| Agent implements directly without dispatching roles | Happens occasionally with casual phrasing on weaker models — say "follow the Heatwave protocol" once; the artifacts make any skip visible |
| "Model not available" | Fill the `fallback:` lists in `heatwave.config.yaml`; substitutions are recorded automatically |
| Run seems stuck mid-state | Nothing is lost — `cat .heatwave/runs/<task>/state.yaml`, then tell a new session to continue the task |
