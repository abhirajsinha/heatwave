# Session hygiene (Claude Code)

Machine-wide nudges to keep Claude Code sessions short and context small — the
two levers that actually move weekly-usage cost (session count + context
lifetime), not model choice. Claude Code has no native auto-clear or
auto-new-session at a threshold, and hooks cannot trigger `/clear`, so this is a
**nudge**, not a forced restart.

## Install (user-global, once per machine)

```sh
./install.sh --session-hygiene
```

Copies three scripts into `~/.claude` and merges a statusline + two hooks into
`~/.claude/settings.json` (idempotent; preserves your existing hooks; won't
clobber a custom statusline). Active in every **new** session (restart Claude
Code, or open `/hooks` once, to load it in a running session).

## What you get

- **`hooks/session-age.sh`** — injects a `SESSION HYGIENE:` reminder to Claude
  **once per session** when the session passes an age threshold, telling it to
  `/clear` before a new/unrelated task. Time only — context bloat is handled
  automatically by auto-compact (see below), so this no longer warns on tokens.
  Wired to `SessionStart` (stamps start time) + `UserPromptSubmit`.
- **`statusline.sh`** — `model | ctx <used>/<total> (%) | $cost | duration`.
  Informational readout of absolute tokens (a % of a 1M window hides the real
  per-request cost).
- **`scripts/fresh-tasks.sh`** — runs each task as a fresh `claude -p` process
  (true bounded context per task; for batch/autonomous runs, not interactive).
  `fresh-tasks.sh "task a" "task b"` or `fresh-tasks.sh -f tasks.txt`.

## Context is handled by auto-compact, not this

Claude Code's native **auto-compact** summarizes older history (keeps what the
task needs) and continues without stopping or asking, once context passes a
threshold — set `autoCompactWindow` (or `CLAUDE_CODE_AUTO_COMPACT_WINDOW`) to the
token budget, e.g. `800000` to compact at ~80% of a 1M window. That owns context
bloat, so the nudge here is time-only.

## Threshold (env var)

| Var | Default | Meaning |
|-----|---------|---------|
| `CLAUDE_SESSION_WARN_MIN` | 60 | remind once when the session passes this age (min) |

Self-test the logic: `bash session-age.sh --selftest`.
