# EXPRESS Check

task_id: global-role-models | artifact_type: express-check | iteration: 1 | produced_by: REVIEWER (EXPRESS check, claude-fable-5, fresh context) | timestamp: 2026-08-24

## Verdict
PASS — YAML parses, tracked diff is exactly the one declared hunk in the one declared file, no secrets, all glance items yes.

## Machine gate
All checks run by this checker; outputs are verbatim.

**YAML parse** (python `yaml` absent on host; Ruby stdlib YAML used):

```
$ ruby -ryaml -e 'YAML.load_file(".../heatwave.config.example.yaml"); puts "ok"'
ok
$ ruby -ryaml -e 'p YAML.load_file(...)["roles"]'
{"planner" => {"preferred" => "claude-fable-5", "fallback" => ["claude-opus-4-8[1m]"]}, "implementer" => {"preferred" => "claude-opus-4-8[1m]", "fallback" => ["claude-opus-4-8", "claude-opus-5"]}, "reviewer" => {"preferred" => "claude-fable-5", "fallback" => ["claude-opus-4-8[1m]"]}}
```

The bracketed id `claude-opus-4-8[1m]` is correctly quoted everywhere it appears in flow context, so it round-trips as a plain string, not a nested sequence.

**Diff confinement** (tracked diff only, per task scope; untracked files and the parked `light-2d` run excluded by instruction):

```
$ git diff --stat
 heatwave.config.example.yaml | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)
$ git diff HEAD --name-only
heatwave.config.example.yaml
```

Single hunk at lines 15–28: removes the 4 commented example `# roles:` lines, adds a 3-line explanatory comment plus the 7-line active `roles:` block. Surrounding R-115/R-10 comment prose untouched. Matches the diff embedded in `01-express-change.md` exactly.

**Secret scan** (gitleaks 8.x at /opt/homebrew/bin/gitleaks, run over the diff):

```
$ gitleaks detect --no-git --source <diff file> -v
INF scanned ~1315 bytes (1.32 KB) in 21.8ms
INF no leaks found  (exit=0)
```

Grep for key/token/secret/password/AKIA/BEGIN patterns in the diff: no hits.

**Build / lint / tests:** NOT AVAILABLE (R-64) — the repo has no package.json, pytest.ini, go.mod, Makefile, or declared test/lint tooling in `heatwave.config.yaml`; it is a markdown/shell/YAML protocol repo. `build-protocol.sh` regenerates PROTOCOL.md from `protocol/` shards and does not consume the touched file, so no drift check applies. What this leaves unverified: nothing beyond the YAML validity already verified directly — the touched file's only machine-checkable property is that it parses, which passed.

## Confirmation glance
- Diff does what was asked, nothing else: **yes** — the commented roles example is replaced by an active maintainer-default block (planner/reviewer preferred claude-fable-5 with opus fallback; implementer preferred claude-opus-4-8[1m] with fallbacks) plus a 3-line comment telling other stacks to substitute or re-comment; zero-config remains documented as valid, consistent with R-115. No other tracked line changed.
- ≤ 2 files, none sensitive (R-102): **yes** — 1 file, `heatwave.config.example.yaml`; an example config touches no auth, payments, user data, schema, or public API path.
- No new dependency / public surface (R-103): **yes** — config values only; no code, no dependency, no new interface. The global-default effect (install.sh copies this example into new projects) is precisely the requested behavior, not new surface.
