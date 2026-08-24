# EXPRESS Change

task_id: global-role-models | artifact_type: express-change | iteration: 1 | produced_by: IMPLEMENTER (claude-opus-4-8) | timestamp: 2026-08-24

## Request
Replace the commented-out roles example block in heatwave.config.example.yaml with an active roles block carrying the maintainer defaults (fable plans/reviews, opus 4.8 implements), globally directed by the owner on 2026-08-24.

## Result
done

## Change
`heatwave.config.example.yaml` (1 file):

```diff
@@ -15,10 +15,13 @@
 # implementer — a same-model reviewer under-critiques its own style. The run
 # record flags the gap either way: hetero_reviewer: "false (self-preference
 # bias not mitigated)" when they match. Advisory only — zero-config stays valid.
-# roles:
-#   planner:     { preferred: your-best-reasoning-model, fallback: [] }
-#   implementer: { preferred: your-best-coding-model,    fallback: [] }
-#   reviewer:    { preferred: your-best-reasoning-model, fallback: [] }
+# Maintainer defaults (strongest reasoning model plans and reviews, strongest
+# coding model implements). On another stack, substitute your own model ids or
+# re-comment this block for zero-config session-model behavior.
+roles:
+  planner:     { preferred: claude-fable-5, fallback: ["claude-opus-4-8[1m]"] }
+  implementer: { preferred: "claude-opus-4-8[1m]", fallback: [claude-opus-4-8, claude-opus-5] }
+  reviewer:    { preferred: claude-fable-5, fallback: ["claude-opus-4-8[1m]"] }
```

The surrounding explanatory comments (R-115 advisory, R-10 role-config form) are untouched. No other file or line changed. install.sh copies this example into each new project — that is what makes the default global.

## Self-run checks
YAML parse (python `yaml` module absent; `yq` absent; used Ruby's stdlib YAML):

```
$ ruby -ryaml -e 'p YAML.load_file("heatwave.config.example.yaml")["roles"]'
{"planner" => {"preferred" => "claude-fable-5", "fallback" => ["claude-opus-4-8[1m]"]}, "implementer" => {"preferred" => "claude-opus-4-8[1m]", "fallback" => ["claude-opus-4-8", "claude-opus-5"]}, "reviewer" => {"preferred" => "claude-fable-5", "fallback" => ["claude-opus-4-8[1m]"]}}
```

File parses as valid YAML; the `roles` mapping resolves with the three roles and the intended preferred/fallback model ids. No build/lint step applies to an example config file.
