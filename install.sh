#!/bin/sh
# Heatwave installer — copies the protocol runtime into a target project.
# Usage: ./install.sh /path/to/project [adapter]
# Adapters: claude codex gemini cursor copilot windsurf cline zed amp opencode aider generic
# Idempotent: re-running refreshes protocol files but never overwrites your config
# and never duplicates adapter blocks in existing instruction files.

set -eu

SRC=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
TARGET=${1:-}
ADAPTER=${2:-generic}

usage() {
  echo "Usage: $0 /path/to/project [claude|codex|gemini|cursor|copilot|windsurf|cline|zed|amp|opencode|aider|generic]" >&2
  exit 1
}

[ -n "$TARGET" ] || usage
[ -d "$TARGET" ] || { echo "error: target directory '$TARGET' does not exist" >&2; exit 1; }
case "$ADAPTER" in claude|codex|gemini|cursor|copilot|windsurf|cline|zed|amp|opencode|aider|generic) ;; *) usage ;; esac

HW="$TARGET/.heatwave"
mkdir -p "$HW/runs"

# Protocol runtime (refreshed on every run — these are Heatwave's files, not yours;
# runs/ and your config are never touched).
rm -rf "$HW/prompts" "$HW/templates" "$HW/plugins"
cp "$SRC/PROTOCOL.md" "$HW/PROTOCOL.md"
cp -R "$SRC/prompts" "$HW/"
cp -R "$SRC/templates" "$HW/"
mkdir -p "$HW/plugins"
cp -R "$SRC/plugins/ponytail" "$HW/plugins/"
cp "$SRC/adapters/generic/HEATWAVE-AGENT.md" "$HW/HEATWAVE-AGENT.md"
cp "$SRC/adapters/claude-code/GATE.md" "$HW/GATE.md"
cp "$SRC/COMPANIONS.md" "$HW/COMPANIONS.md"
cp "$SRC/keep-awake.sh" "$HW/keep-awake.sh"
chmod +x "$HW/keep-awake.sh"

# Agent Skills standard directory (agentskills.io) — Codex, Gemini CLI, and other
# compliant tools auto-discover skills here; ponytail rides along for free.
mkdir -p "$TARGET/.agents/skills"
rm -rf "$TARGET/.agents/skills/ponytail"
mkdir -p "$TARGET/.agents/skills/ponytail"
cp "$SRC/plugins/ponytail/SKILL.md" "$TARGET/.agents/skills/ponytail/SKILL.md"
cp "$SRC/plugins/ponytail/LICENSE" "$TARGET/.agents/skills/ponytail/LICENSE"

# Project config (created once, never overwritten — it is yours).
if [ ! -f "$TARGET/heatwave.config.yaml" ]; then
  cp "$SRC/heatwave.config.example.yaml" "$TARGET/heatwave.config.yaml"
  echo "created heatwave.config.yaml — all optional: models default to your session's model, test tooling is auto-detected"
fi

# Append an adapter block to an instruction file exactly once.
append_once() {
  file=$1; block=$2
  marker="Heatwave protocol (binding)"
  if [ -f "$file" ] && grep -q "$marker" "$file"; then
    echo "skipped $file (Heatwave block already present)"
  else
    [ -f "$file" ] && printf '\n' >> "$file"
    # strip installer-facing HTML comments (single-line AND multi-line) from the
    # block. A range delete /<!--/,/-->/d wipes to EOF on a one-line comment, so
    # use an awk state machine that closes inline comments and spans multi-line ones.
    awk '{ l=$0
      while (match(l,/<!--.*-->/)) { l=substr(l,1,RSTART-1) substr(l,RSTART+RLENGTH) }
      if (c) { if (match(l,/-->/)) { l=substr(l,RSTART+RLENGTH); c=0 } else next }
      if (match(l,/<!--/)) { l=substr(l,1,RSTART-1); c=1 }
      print l }' "$block" >> "$file"
    echo "updated $file"
  fi
}

case "$ADAPTER" in
  claude)
    cp "$SRC/adapters/claude-code/HEATWAVE.md" "$HW/HEATWAVE.md"
    cp "$SRC/adapters/claude-code/role-gate.sh" "$HW/role-gate.sh"
    chmod +x "$HW/role-gate.sh"
    mkdir -p "$TARGET/.claude/agents"
    for a in heatwave-planner heatwave-implementer heatwave-reviewer; do
      cp "$SRC/adapters/claude-code/.claude/agents/$a.md" "$TARGET/.claude/agents/$a.md"
    done
    append_once "$TARGET/CLAUDE.md" "$SRC/adapters/claude-code/HEATWAVE.md"
    # Active enforcement: inject the gate on every prompt + session start via hooks.
    # Passive CLAUDE.md text can be rationalized past; a hook fires every time.
    if command -v python3 >/dev/null 2>&1; then
      python3 - "$TARGET/.claude/settings.json" <<'PYEOF'
import json, os, sys
path = sys.argv[1]
cmd = "cat .heatwave/GATE.md 2>/dev/null || true"
hook = {"hooks": [{"type": "command", "command": cmd}]}
try:
    with open(path) as f: cfg = json.load(f)
except FileNotFoundError:
    cfg = {}
except json.JSONDecodeError as e:
    # Never rewrite a file we could not parse — that would destroy the user's settings.
    print(f"warning: {path} is not valid JSON ({e}) — hooks NOT installed. Fix the file and re-run.")
    sys.exit(0)
if not isinstance(cfg, dict) or not isinstance(cfg.get("hooks", {}), dict):
    print(f"warning: {path} has an unexpected shape ('hooks' is not an object) — hooks NOT installed. Fix the file and re-run.")
    sys.exit(0)
hooks = cfg.setdefault("hooks", {})
changed = False
gate_cmd = "sh .heatwave/role-gate.sh"
wanted = [
    ("UserPromptSubmit", cmd, {"hooks": [{"type": "command", "command": cmd}]}),
    ("SessionStart", cmd, {"hooks": [{"type": "command", "command": cmd}]}),
    ("PreToolUse", gate_cmd, {"matcher": "Edit|Write", "hooks": [{"type": "command", "command": gate_cmd}]}),
]
for event, want_cmd, entry in wanted:
    entries = hooks.get(event, [])
    if not isinstance(entries, list):
        print(f"warning: {path} 'hooks.{event}' is not a list — hooks NOT installed. Fix the file and re-run.")
        sys.exit(0)
    hooks[event] = entries
    if not any(want_cmd == h.get("command") for e in entries if isinstance(e, dict) for h in e.get("hooks", []) if isinstance(h, dict)):
        entries.append(entry); changed = True
if changed:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f: json.dump(cfg, f, indent=2); f.write("\n")
    print("installed protocol gate hooks in .claude/settings.json")
else:
    print("skipped hooks (already installed)")
PYEOF
    else
      echo "note: python3 not found — add the gate hooks manually to .claude/settings.json:"
      echo '  {"hooks":{"UserPromptSubmit":[{"hooks":[{"type":"command","command":"cat .heatwave/GATE.md 2>/dev/null || true"}]}],"SessionStart":[{"hooks":[{"type":"command","command":"cat .heatwave/GATE.md 2>/dev/null || true"}]}]}}'
    fi
    # Companion skill: ui-ux-pro-max (MIT © nextlevelbuilder) — fetched from upstream at
    # install time, not vendored, so this repo stays lean and the skill stays current.
    # Offline or no git? Skipped gracefully — Heatwave itself needs neither.
    SKILL_DIR="$TARGET/.claude/skills/ui-ux-pro-max"
    if [ -d "$SKILL_DIR" ]; then
      echo "skipped companion skill ui-ux-pro-max (already installed)"
    elif command -v git >/dev/null 2>&1 && git clone --depth 1 --quiet https://github.com/nextlevelbuilder/ui-ux-pro-max-skill "$HW/.uiux-tmp" 2>/dev/null; then
      if [ -d "$HW/.uiux-tmp/.claude/skills/ui-ux-pro-max" ]; then
        mkdir -p "$TARGET/.claude/skills"
        cp "$HW/.uiux-tmp/LICENSE" "$HW/.uiux-tmp/.claude/skills/ui-ux-pro-max/LICENSE" 2>/dev/null || true
        mv "$HW/.uiux-tmp/.claude/skills/ui-ux-pro-max" "$SKILL_DIR"
        echo "installed companion skill ui-ux-pro-max into .claude/skills/ (MIT © nextlevelbuilder — github.com/nextlevelbuilder/ui-ux-pro-max-skill)"
      else
        echo "note: ui-ux-pro-max upstream layout changed — install it manually from github.com/nextlevelbuilder/ui-ux-pro-max-skill"
      fi
      rm -rf "$HW/.uiux-tmp"
    else
      echo "note: could not fetch companion skill ui-ux-pro-max (offline or git missing) — install later from github.com/nextlevelbuilder/ui-ux-pro-max-skill"
    fi
    # Suggested (not auto-installed — plugin installs are user-level; official channels only):
    echo "suggested companions, installed inside Claude Code (full verified list: .heatwave/COMPANIONS.md):"
    echo "  process skills:       /plugin install superpowers@claude-plugins-official"
    echo "  review second-opinion:/plugin install code-review@claude-plugins-official"
    echo "  security review:      /plugin marketplace add affaan-m/ECC   then   /plugin install ecc@ecc"
    echo "  cross-session memory: /plugin marketplace add thedotmack/claude-mem   then   /plugin install claude-mem"
    echo "  browser evidence:     claude mcp add playwright -- npx @playwright/mcp@latest"
    echo "  runtime debugging:    claude mcp add chrome-devtools -- npx chrome-devtools-mcp@latest"
    echo "  current library docs: claude mcp add context7 -- npx -y @upstash/context7-mcp"
    ;;
  codex)
    append_once "$TARGET/AGENTS.md" "$SRC/adapters/codex/AGENTS.md"
    # Active enforcement: per-prompt gate via Codex project hooks.
    if [ ! -f "$TARGET/.codex/hooks.json" ]; then
      mkdir -p "$TARGET/.codex"
      cp "$SRC/adapters/codex/hooks.json" "$TARGET/.codex/hooks.json"
      echo "installed .codex/hooks.json (per-prompt gate — Codex asks you to trust project hooks on first run)"
    elif grep -q "GATE.md" "$TARGET/.codex/hooks.json"; then
      echo "skipped .codex/hooks.json (gate already present)"
    else
      echo "note: .codex/hooks.json exists — add a UserPromptSubmit hook running: cat .heatwave/GATE.md"
    fi
    echo "suggested (official channels): codex plugin marketplace add openai/plugins  then install codex-security"
    ;;
  gemini)
    append_once "$TARGET/GEMINI.md" "$SRC/adapters/gemini/GEMINI.md"
    cp "$SRC/adapters/gemini/gemini-gate.sh" "$HW/gemini-gate.sh"
    chmod +x "$HW/gemini-gate.sh"
    # Active enforcement: BeforeAgent gate hook merged into project settings.
    if command -v python3 >/dev/null 2>&1; then
      python3 - "$TARGET/.gemini/settings.json" <<'PYEOF'
import json, os, sys
path = sys.argv[1]
cmd = "sh .heatwave/gemini-gate.sh"
entry = {"hooks": [{"type": "command", "command": cmd}]}
try:
    with open(path) as f: cfg = json.load(f)
except FileNotFoundError:
    cfg = {}
except json.JSONDecodeError as e:
    print(f"warning: {path} is not valid JSON ({e}) — gate hook NOT installed. Fix the file and re-run.")
    sys.exit(0)
if not isinstance(cfg, dict) or not isinstance(cfg.get("hooks", {}), dict):
    print(f"warning: {path} has an unexpected shape — gate hook NOT installed.")
    sys.exit(0)
hooks = cfg.setdefault("hooks", {})
entries = hooks.get("BeforeAgent", [])
if not isinstance(entries, list):
    print(f"warning: {path} 'hooks.BeforeAgent' is not a list — gate hook NOT installed.")
    sys.exit(0)
hooks["BeforeAgent"] = entries
if any(cmd == h.get("command") for e in entries if isinstance(e, dict) for h in e.get("hooks", []) if isinstance(h, dict)):
    print("skipped gemini gate hook (already installed)")
else:
    entries.append(entry)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f: json.dump(cfg, f, indent=2); f.write("\n")
    print("installed gemini gate hook in .gemini/settings.json (BeforeAgent)")
PYEOF
    else
      echo "note: python3 not found — add a BeforeAgent hook running 'sh .heatwave/gemini-gate.sh' to .gemini/settings.json"
    fi
    echo "suggested (official channel): gemini extensions install https://github.com/gemini-cli-extensions/security"
    ;;
  cursor)
    mkdir -p "$TARGET/.cursor/rules"
    cp "$SRC/adapters/cursor/heatwave.mdc" "$TARGET/.cursor/rules/heatwave.mdc"
    echo "installed .cursor/rules/heatwave.mdc"
    ;;
  copilot)
    mkdir -p "$TARGET/.github"
    append_once "$TARGET/.github/copilot-instructions.md" "$SRC/adapters/copilot/copilot-instructions.md"
    ;;
  windsurf)
    mkdir -p "$TARGET/.windsurf/rules" "$TARGET/.devin/rules"
    cp "$SRC/adapters/windsurf/heatwave.md" "$TARGET/.windsurf/rules/heatwave.md"
    cp "$SRC/adapters/windsurf/heatwave.md" "$TARGET/.devin/rules/heatwave.md"
    echo "installed .windsurf/rules/heatwave.md (+ .devin/rules mirror)"
    ;;
  cline)
    mkdir -p "$TARGET/.clinerules"
    cp "$SRC/adapters/cline/heatwave.md" "$TARGET/.clinerules/heatwave.md"
    echo "installed .clinerules/heatwave.md"
    ;;
  zed)
    # Zed reads .rules first-match; appending preserves any existing rules.
    append_once "$TARGET/.rules" "$SRC/adapters/zed/rules"
    ;;
  amp|opencode)
    # Both read repo-root AGENTS.md (the agents.md standard) — same block as Codex.
    append_once "$TARGET/AGENTS.md" "$SRC/adapters/codex/AGENTS.md"
    ;;
  aider)
    append_once "$TARGET/CONVENTIONS.md" "$SRC/adapters/aider/CONVENTIONS.md"
    # Aider auto-reads .aider.conf.yml, not CONVENTIONS.md — wire the read: entry.
    if [ ! -f "$TARGET/.aider.conf.yml" ]; then
      printf 'read: [CONVENTIONS.md]\n' > "$TARGET/.aider.conf.yml"
      echo "created .aider.conf.yml (read: [CONVENTIONS.md])"
    elif grep -q "CONVENTIONS.md" "$TARGET/.aider.conf.yml"; then
      echo "skipped .aider.conf.yml (CONVENTIONS.md already wired)"
    else
      echo "note: .aider.conf.yml exists — add CONVENTIONS.md to its 'read:' list yourself"
    fi
    ;;
  generic)
    echo "generic adapter: point your tool's standing instructions at .heatwave/HEATWAVE-AGENT.md"
    ;;
esac

echo "Heatwave installed into $TARGET (.heatwave/, adapter: $ADAPTER)"
