# FAQ

**I only have one model / one subscription. Can I still use Heatwave?**
Yes. The isolation boundary is the *context*, not the model (R-12). One model playing PLANNER in one session and REVIEWER in a fresh session satisfies R-1/R-2. Different models per role is better (uncorrelated blind spots), not required.

**Isn't this a lot of ceremony for a one-line fix?**
That is what tiers are for (§0.5). A LIGHT-tier change collapses the Planning Document to four sections and merges the two post-implementation reviews into one pass — the plan is still reviewed before any code is written. What never goes away: a separate context checks the work, and claims of verification carry evidence. If even LIGHT is too much, the change is probably a spike — label it as such (§0.4) and it is out of protocol scope.

**What stops the AI from just... not following the protocol?**
Four things. The adapter file puts the rules in the tool's standing instructions, which every session reads. On Claude Code, the installer also adds **hooks** that re-inject the protocol gate on every prompt and session start — instructions at the top of a long conversation fade; a hook fires every turn and can't be forgotten. The on-disk run directory makes state visible — you can see at a glance whether a plan exists and what the reviewer said. And the artifacts make cheating auditable: a Fix Report with no evidence attached is visibly non-conforming. It is not cryptographic enforcement; it is making the honest path the easy path and violations legible.

**Claude Code has subagents. Codex/Gemini/Cursor don't. How is isolation real there?**
In Claude Code the orchestrator dispatches each role as a fresh subagent — true context isolation inside one session. In single-context tools, each role is a fresh session, and the adapter instructs a session that already played one role for a task to refuse a conflicting role. The filesystem carries everything between sessions (that is the point of R-17).

**Why is ponytail part of a verification protocol?**
A strict review gate pushes implementers to over-build — gold-plating looks like diligence. Ponytail pulls the other way: the minimal diff that meets the acceptance criteria. Small diffs are also cheaper to review and make blast-radius claims checkable. The reviewer's bar is untouched — "lazy" never means unverified (Appendix G).

**What happens when the loop can't converge?**
Budgets (§2.3): 3 plan rejections, 5 fix iterations, 2 final-review failures. Any exhaustion escalates to you — the OWNER — with a report ending in one specific, answerable question (R-72). You answer, counters reset per your decision, and the loop resumes exactly where it stopped (§7.3).

**Can I use Heatwave for docs / infra / non-app code?**
Yes — "production" means "someone depends on it." Mark inapplicable Planning Document sections `N/A` with a reason (R-20) and pick the right tier.

**How do I update Heatwave in a project?**
Re-run `install.sh`. It refreshes `.heatwave/` runtime files and never touches your `heatwave.config.yaml` or your runs.

**Does the AI ever still cut corners?**
Sometimes, and Heatwave is honest about it: in live testing, strong models follow the loop faithfully (including multi-round plan rejection for real defects), but a driver given a casually-phrased request occasionally implements directly instead of dispatching the implementer role — the artifacts on disk make that visible immediately, which is the point. Instruction-level enforcement can't be cryptographic; hook-level enforcement (blocking source edits while the run state assigns them to another role) is on the roadmap for tools that support hooks.

**What happens if my laptop goes to sleep mid-run?**
Nothing is lost — and nothing is running, either. Be clear about the physics: when the OS sleeps, every local process pauses (any tool, any vendor — no software can compute on a sleeping CPU). Heatwave's guarantee is that sleep can only *pause* a run, never break one: every artifact and `state.yaml` are already on disk before the next step starts (R-87), so on wake — or days later, in a fresh session — the run resumes at exactly the recorded state (R-88). Zero work is repeated.

If you want the loop to keep executing while you close the lid, take the work off the local CPU:

| Option | How |
|---|---|
| Keep the machine awake | `caffeinate -dims` on macOS (`systemd-inhibit` on Linux) for the duration of the run |
| Cloud agents | Run the session in your tool's cloud/remote mode (e.g. Claude Code on the web / remote agents) — the loop executes server-side and your laptop is just a viewer |
| A remote machine | Run your agent inside `tmux`/`ssh` on a VPS or devcontainer; disconnecting doesn't stop it |

Because runs live in the repo, these mix freely: start a run on the laptop, push, and let a remote session resume it overnight.

**I'm building a mobile app — which simulator does it test on?**
Your choice, asked exactly once. Pin it in `heatwave.config.yaml` (`tooling.mobile_platform: ios | android | both`) and you're never asked; leave it empty and the driver asks at the start of each mobile task, before planning begins (R-98). The answer lands in the Run Record, E2E verification runs on that simulator/emulator, and the platform you didn't pick is recorded as out of scope — never silently assumed covered.

**Will it work with agents that don't exist yet?**
By design, yes. Heatwave demands exactly two capabilities — read/write files, and follow project instructions — which is close to the definition of a coding agent. All protocol state is plain markdown/YAML in your repo, so any future tool that can read a repo can join or resume a run started by any other tool. Only the enforcement *strength* varies by what a tool offers: instructions (every agent) → always-on rules (most) → per-turn gate hooks (Claude Code today) → subagent isolation (Claude Code). When a new tool ships, its adapter is a ~15-line file — see `adapters/README.md`.

**Does Heatwave remember things between sessions?**
Task state, yes — completely. The run directory holds the plan, every review, every fix, and the current step, so any session resumes a task exactly where it stopped. That's built in. What Heatwave doesn't store is *conversational* memory — why you preferred one approach last month, lessons from past tasks. For that, pair it with a memory plugin like [claude-mem](https://github.com/thedotmack/claude-mem) (Apache-2.0, install via `/plugin marketplace add thedotmack/claude-mem` then `/plugin install claude-mem`): claude-mem remembers across conversations, Heatwave proves within tasks — they complement, not overlap. The installer prints these commands after a Claude Code install.
