# FAQ

**I only have one model / one subscription. Can I still use Heatwave?**
Yes. The isolation boundary is the *context*, not the model (R-12). One model playing PLANNER in one session and REVIEWER in a fresh session satisfies R-1/R-2. Different models per role is better (uncorrelated blind spots), not required.

**Isn't this a lot of ceremony for a one-line fix?**
That is what tiers are for (§0.5). A LIGHT-tier change collapses the Planning Document to four sections and merges the two post-implementation reviews into one pass — the plan is still reviewed before any code is written. What never goes away: a separate context checks the work, and claims of verification carry evidence. If even LIGHT is too much, the change is probably a spike — label it as such (§0.4) and it is out of protocol scope.

**What stops the AI from just... not following the protocol?**
Three things. The adapter file puts the rules in the tool's standing instructions, which every session reads. The on-disk run directory makes state visible — you can see at a glance whether a plan exists and what the reviewer said. And the artifacts make cheating auditable: a Fix Report with no evidence attached is visibly non-conforming. It is not cryptographic enforcement; it is making the honest path the easy path and violations legible.

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
