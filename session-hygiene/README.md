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

- **`hooks/session-age.sh`** — on each prompt, injects a `SESSION HYGIENE:`
  reminder to Claude when the session is too old **or** its context too big,
  telling it to prompt you to `/clear` before a new task. Wired to
  `SessionStart` (stamps start time) + `UserPromptSubmit`.
- **`statusline.sh`** — `model | ctx <used>/<total> (%) [CLEAR?] | $cost | duration`.
  Shows **absolute tokens** (the real per-request cost on a large context window,
  where a % of a 1M window hides the cost). Also writes the live token count to a
  file the context-blind hook reads — this bridge is what makes the *context*
  trigger work.
- **`scripts/fresh-tasks.sh`** — runs each task as a fresh `claude -p` process
  (true bounded context per task; for batch/autonomous runs, not interactive).
  `fresh-tasks.sh "task a" "task b"` or `fresh-tasks.sh -f tasks.txt`.

## Thresholds (env vars, override the defaults)

| Var | Default | Meaning |
|-----|---------|---------|
| `CLAUDE_SESSION_WARN_MIN`  | 60     | warn at this session age (min) |
| `CLAUDE_SESSION_LOUD_MIN`  | 120    | louder warning at this age |
| `CLAUDE_CTX_WARN_TOKENS`   | 150000 | warn at this used-token count |
| `CLAUDE_CTX_LOUD_TOKENS`   | 300000 | louder warning at this token count |

Self-test the logic: `bash session-age.sh --selftest`.
