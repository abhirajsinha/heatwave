# A complete example, start to finish

This walks one real task through Heatwave — every command you type, everything the agent produces — so you can see exactly what using it feels like. The project is a small Express API and the task is deliberately simple: **add a `/health` endpoint**.

## 1 · Install (once per project)

```sh
git clone https://github.com/abhirajsinha/heatwave.git
cd heatwave
./install.sh ~/code/my-api claude
```

The installer prints what it did:

```
created heatwave.config.yaml — edit it for your project
updated /Users/you/code/my-api/CLAUDE.md
installed protocol gate hooks in .claude/settings.json
installed companion skill ui-ux-pro-max into .claude/skills/ (MIT © nextlevelbuilder — ...)
suggested: for tool-backed security review, install ECC inside Claude Code:
  /plugin marketplace add affaan-m/ECC   then   /plugin install ecc@ecc
Heatwave installed into /Users/you/code/my-api (.heatwave/, adapter: claude)
```

## 2 · Configure (once, ~2 minutes)

Edit `~/code/my-api/heatwave.config.yaml`:

```yaml
roles:
  planner:     { preferred: claude-sonnet-5, fallback: [] }
  implementer: { preferred: claude-sonnet-5, fallback: [] }
  reviewer:    { preferred: claude-sonnet-5, fallback: [] }   # same model is fine — fresh context is what matters
tooling:
  unit: "jest"          # declare only what the project actually has
  web_e2e: ""
  mobile_e2e: ""
  mobile_platform: ""
```

## 3 · Ask for the feature — like you always would

Open your agent in the project and type:

> **Add a GET /health endpoint that returns 200 with {"status":"ok"} and the uptime in seconds.**

No special command. The agent recognizes production work, creates a run, and enters the loop.

## 4 · Watch the loop work (you do nothing here)

**The run directory appears** — `.heatwave/runs/add-health-endpoint/` with:

```yaml
# state.yaml — right after creation
task_id: add-health-endpoint
tier: LIGHT              # proposed by the planner: single-file, no new surface
state: PLANNING
counters: { plan_iterations: 0, fix_iterations: 0, final_iterations: 0 }
```

**The planner produces `01-planning-document.md`.** The heart of it is acceptance criteria that can be *proven*:

```
AC-F-01 | GET /health returns HTTP 200 with JSON body {"status":"ok","uptime":<number>}
        | Verification: jest — supertest GET /health, assert status + body shape
AC-F-02 | uptime is seconds since process start, monotonically increasing
        | Verification: jest — two calls 1s apart, assert second uptime > first
AC-F-03 | endpoint requires no authentication (it's a probe)
        | Verification: jest — request without auth header, assert 200
```

**A separate reviewer context judges the plan** → `02-plan-review.md`:

```
## Verdict
GATE_NOT_MET
Blockers: 0 open | Majors: 1 open | Minor: 0 | Nit: 0

Finding F-add-health-endpoint-001 (Major, acceptance-criteria):
AC-F-02's verification sleeps 1s in a unit test and still can't prove
monotonicity in general. Recommend: mock the clock, or drop the
monotonic claim and assert uptime ≥ 0. Verification method: re-read AC-F-02.
```

A real rejection, for a real reason — the planner revises (`03-planning-document.md`), the reviewer approves (`04-plan-review.md`, GATE_MET). **Only now does code get written.**

**The implementer builds** → `05-implementation-package.md`. Note the two things that make this package trustworthy — real test output, and an honest blast radius:

```
## Diff
+ app.get('/health', (req, res) =>
+   res.json({ status: 'ok', uptime: Math.floor(process.uptime()) }))

## Test Results
PASS  tests/health.test.js
  ✓ returns 200 with status ok and numeric uptime (24 ms)
  ✓ uptime is a non-negative integer (5 ms)
  ✓ responds without authentication (4 ms)
Tests: 3 passed, 3 total

## Blast Radius Declaration
Touched: src/app.js (one route added). Consumers: none — new endpoint.
Shared state/schema: none. Contracts: adds GET /health (additive).
```

**The reviewer checks the code against the plan** → `06-review-report.md`. LIGHT tier combines the code review and final review into one pass; it re-runs the tests itself and reports every criterion:

```
## Verdict
GATE_MET
Blockers: 0 open | Majors: 0 open | Minor: 0 | Nit: 0

## Acceptance Status
| AC-F-01 | Satisfied | re-ran jest: 3/3 pass; body shape asserted |
| AC-F-02 | Satisfied | uptime ≥ 0 asserted (per revised criterion) |
| AC-F-03 | Satisfied | unauthenticated request test passes |
```

**Done.** `state.yaml` now reads `state: APPROVED`. Your agent tells you the endpoint is ready, and every claim in that sentence has a file behind it.

## 5 · The part that feels like magic: resume

Suppose your terminal died right after `04-plan-review.md` (plan approved, no code yet). Next day, any session, even a different tool:

> **continue the health endpoint task**

The driver reads `state.yaml`, sees `IMPLEMENTING`, and dispatches the implementer with the approved plan. It does not re-plan. It does not start over. Even if you say "start fresh if you need to" — the protocol forbids it. To genuinely restart, you have to say "abandon the run," and that gets recorded as your decision.

## 6 · When it needs you

Two moments in this example could have pulled you in — and only these:

- If plan review had failed **3 times**, you'd get a short escalation report ending in one specific question ("The criteria conflict about X — pick one"). You answer; the loop resumes.
- If the plan had needed a tool the project doesn't have ("load test at 50 rps" with no load tool declared), that criterion would be reported **Unverified** — and it's your call to waive it or add the tool. Never silently marked "passed."

That's the whole experience: ask normally, get proven-done work, and put your judgment only where a human's judgment is actually required.

---

*Next: [Getting started](getting-started.md) for setup details and troubleshooting · [The loop](loop.md) for how persistence works under the hood.*
