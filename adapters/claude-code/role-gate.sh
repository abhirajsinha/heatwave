#!/bin/sh
# Heatwave role gate — PreToolUse hook for Claude Code (Edit|Write|Bash matcher).
# Mechanically blocks project-source edits while an active run is in a state
# whose owner should not be writing code (PLANNING, any review state) — the
# "code before plan approval" drift, made impossible instead of discouraged.
# Two paths: Edit/Write tool calls (file_path) and common shell source-writes
# via Bash (best-effort denylist — NOT a filesystem sandbox; see the ceiling
# note below). Artifacts (.heatwave/**) are always writable. No active run = no
# gate. Exit 0 allows the tool call; exit 2 blocks it with the stderr message.

set -eu

INPUT=$(cat)

python3 - "$INPUT" <<'PYEOF'
import json, os, re, sys, glob, shlex

try:
    data = json.loads(sys.argv[1])
except (IndexError, json.JSONDecodeError):
    sys.exit(0)

ti = data.get("tool_input") or {}
path = ti.get("file_path", "")
command = ti.get("command", "")
if not path and not command:
    sys.exit(0)

ROOT = os.path.realpath(os.getcwd()) + os.sep

# R-106: the PLANNER writes the technical design doc during PLANNING —
# allow .md files under the configured design_doc_path (default docs/design),
# anchored to the project root so a same-named nested dir stays gated.
# ponytail: prefix+.md anchor; scope to PLANNING-only if the gate ever needs role awareness.
dd = "docs/design"
try:
    for line in open("heatwave.config.yaml"):
        s = line.strip()
        if s.startswith("design_doc_path:"):
            dd = s.split(":", 1)[1].split("#")[0].strip().strip("\"'") or dd
            break
except OSError:
    pass
dd_root = os.path.join(os.path.realpath(os.getcwd()), dd.strip("/")) + os.sep

NO_EDIT_STATES = {"PLANNING", "PLAN_REVIEW", "FULL_REVIEW", "TARGETED_REVIEW", "FINAL_REVIEW", "EXPRESS_CHECK"}

def active_no_edit_run():
    """First run in a NO_EDIT state as (run, state), or None.
    Behaviour-identical to the pre-G1 inline scan (same states, first match wins,
    OSError-continue)."""
    for state_file in glob.glob(".heatwave/runs/*/state.yaml"):
        state = ""
        try:
            for line in open(state_file):
                if line.strip().startswith("state:"):
                    state = line.split(":", 1)[1].strip().strip('"').split()[0]
                    break
        except OSError:
            continue
        if state in NO_EDIT_STATES:
            return os.path.basename(os.path.dirname(state_file)), state
    return None

# ---------------------------------------------------------------------------
# Edit/Write path (file_path present) — behaviour UNCHANGED from pre-G1.
# ---------------------------------------------------------------------------
if path:
    allowed_fragments = (".heatwave/", "/CLAUDE.md", "/AGENTS.md", "/GEMINI.md")
    if any(f in path for f in allowed_fragments):
        sys.exit(0)
    if os.path.realpath(path).startswith(dd_root) and path.endswith(".md"):
        sys.exit(0)
    run = active_no_edit_run()
    if run:
        print(
            f"Heatwave gate: run '{run[0]}' is in {run[1]} — project source must not be edited "
            f"in this state (R-1/R-37). If you are the driver, dispatch the owning role subagent; "
            f"if the plan is approved, update state.yaml to IMPLEMENTING first.",
            file=sys.stderr,
        )
        sys.exit(2)
    sys.exit(0)

# ---------------------------------------------------------------------------
# Bash path (command present) — NEW in G1: best-effort source-write denylist.
#
# ponytail: best-effort string/token matching, NOT a filesystem sandbox. Known
# evasions, deliberately not chased: command-string indirection (sh -c / bash -c /
# eval / xargs "echo x > src/y" — the write collapses into one unscanned quoted
# token); a helper script that writes (printf > /tmp/w.sh && sh /tmp/w.sh); a
# here-doc piped to an interpreter; base64-decoded content; chmod +x && ./writer;
# a redirect inside a quoted awk/interpreter program. The real fix is the OS-sandbox
# track (read-only bind mounts / seccomp) — this gate is a speed bump against casual
# drift; bypass attempts land in the audit trail.
# ---------------------------------------------------------------------------
run = active_no_edit_run()
if not run:
    sys.exit(0)                                    # no gated run → zero parsing cost

def allowed_target(tok):
    tok = tok.strip("'\"")
    if not tok or tok.startswith(("&", "-")):      # fd dup (2>&1) or option flag
        return True
    if ".heatwave/" in tok or tok.startswith(".heatwave"):
        return True
    if os.path.basename(tok) in ("CLAUDE.md", "AGENTS.md", "GEMINI.md"):
        return True
    rp = os.path.realpath(tok)
    if not rp.startswith(ROOT):                     # outside the project: /tmp, /dev/null…
        return True                                 # not project source
    if rp.startswith(dd_root) and tok.endswith(".md"):
        return True
    return False

# Strip here-doc bodies (a here-doc piped to an interpreter is a named evasion).
body_stripped = re.sub(r"<<-?\s*['\"]?(\w+)['\"]?.*?\n\1(\n|$)", " ", command, flags=re.S)

REDIR = re.compile(r'^(?:>\|?|>>|&>>?|>&)$')        #  >  >|  >>  &>  &>>  >&
DIGIT = re.compile(r'^\d+-?$')                      #  fd number: '2>&1' target '1'
FB    = re.compile(r'^\d*(&>>?|>>|>\|?|>&)(.*)$')   #  glued fallback: &>src/x

def scan_redirects(toks):
    for i, t in enumerate(toks):
        if REDIR.match(t):
            tgt = toks[i + 1] if i + 1 < len(toks) else ""
            if not tgt or DIGIT.match(tgt):         # dangling, or fd-dup (2>&1, >&2)
                continue
            if not allowed_target(tgt):
                return True
    return False

def scan_redirects_fallback(parts):
    for j, t in enumerate(parts):
        m = FB.match(t)
        if m:
            tgt = m.group(2) or (parts[j + 1] if j + 1 < len(parts) else "")
            if tgt and not DIGIT.match(tgt) and not allowed_target(tgt):
                return True
    return False

# Interpreter one-liners. Write mode = any mode string containing w/a/x/+ (r+, w+,
# a+ all permit writing — folds in PLAN_REVIEW MINOR-4: r+ update-mode is a write).
WRITE_IND = re.compile(
    r"open\s*\([^)]*,\s*['\"][^'\"]*[wax+]"
    r"|writeFile|appendFile|createWriteStream|File\.write"
    r"|File\.(?:open|new)\s*\([^)]*['\"][^'\"]*[wax+]")
WRITE_TARGET = re.compile(
    r"(?:open|File\.open|File\.new)\s*\(\s*['\"]([^'\"]+)['\"]\s*,\s*['\"][^'\"]*[wax+]"
    r"|(?:writeFile|writeFileSync|appendFile|appendFileSync|createWriteStream|File\.write)\s*\(\s*['\"]([^'\"]+)['\"]")

def scan_interpreter(code):
    if not WRITE_IND.search(code):
        return False                                # read-mode / no write → allow
    targets = [g for m in WRITE_TARGET.finditer(code) for g in m.groups() if g]
    if not targets:
        return True                                 # write-class default → block
    return any(not allowed_target(t) for t in targets)

SEP = re.compile(r'^[;&|()]+$')                     # command-position reset tokens
INTERP = {"python", "python3", "perl", "ruby", "node"}

def segments(toks):
    segs, cur = [], []
    for t in toks:
        if t == '$' or SEP.match(t):
            if cur:
                segs.append(cur); cur = []
        else:
            cur.append(t)
    if cur:
        segs.append(cur)
    return segs

def plain_args(args):
    """Segment args with redirect operators + their targets removed."""
    out, skip = [], False
    for a in args:
        if skip:
            skip = False
            continue
        if REDIR.match(a):
            if out and re.fullmatch(r'\d+', out[-1]):
                out.pop()                           # drop the leading fd digit
            skip = True
            continue
        out.append(a)
    return out

def nonopt(args):
    return [a for a in args if not a.startswith("-")]

def scan_tools(seg):
    if not seg:
        return False
    cmd = os.path.basename(seg[0].strip("'\""))
    raw = seg[1:]
    args = plain_args(raw)                          # redirects handled separately
    na = nonopt(args)

    if cmd == "tee":
        return any(not allowed_target(a) for a in na)               # no files → stdout only → allow

    if cmd == "sed" and any(a.startswith("-i") for a in raw):
        rest = na[1:]                               # drop the script arg
        return (not rest) or any(not allowed_target(a) for a in rest)

    if cmd == "perl" and any(re.match(r'^-[A-Za-z]*i', a) for a in raw):
        rest = na[1:]
        return (not rest) or any(not allowed_target(a) for a in rest)

    if cmd == "dd":
        for a in raw:
            if a.startswith("of="):
                return not allowed_target(a[3:])
        return False

    if cmd == "install":
        return any(not allowed_target(a) for a in na)

    if cmd == "patch":
        return not any(a == "--dry-run" for a in raw)               # read-only trial allowed

    if cmd == "git":
        sub = na[0] if na else ""
        if sub == "apply":
            return not any(a in ("--check", "--stat") for a in raw)
        if sub == "restore":
            return True
        if sub == "checkout":
            return any(a == "--" for a in raw)
        return False

    if cmd == "cp":
        return bool(na) and not allowed_target(na[-1])              # dest = last arg

    if cmd in ("mv", "truncate"):
        return any(not allowed_target(a) for a in na)

    if cmd in ("ex", "ed"):
        return (not na) or any(not allowed_target(a) for a in na)   # write-class default

    if cmd in INTERP:
        for i, a in enumerate(raw):
            if re.match(r'^-[A-Za-z]*[ce]$', a) and i + 1 < len(raw):
                return scan_interpreter(raw[i + 1])
        return False

    return False                                    # unmatched command → err toward ALLOW

blocked = False
try:
    lexer = shlex.shlex(body_stripped, posix=True, punctuation_chars=True)
    lexer.whitespace_split = True
    toks = list(lexer)
    if scan_redirects(toks):
        blocked = True
    else:
        for seg in segments(toks):
            if scan_tools(seg):
                blocked = True
                break
except ValueError:
    # Unbalanced quotes/heredocs → whitespace-split fallback, err toward allow.
    if scan_redirects_fallback(body_stripped.split()):
        blocked = True

if blocked:
    print(
        f"Heatwave gate: run '{run[0]}' is in {run[1]} — this Bash command matches a source-write\n"
        f"pattern targeting a non-allowlisted path (R-1/R-37). Reads, tests and linters run\n"
        f"freely; project source is written by the owning role in IMPLEMENTING/FIXING.\n"
        f"Artifacts under .heatwave/ are always writable. (Best-effort denylist — bypasses\n"
        f"land in the audit trail.)",
        file=sys.stderr,
    )
    sys.exit(2)

sys.exit(0)
PYEOF
