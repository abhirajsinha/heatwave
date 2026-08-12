# Task: fix the progress percentage helper

`percent_complete(done, total)` in `progress.py` reports how far along a task
is, as a whole-number percent. It is an internal helper used to render progress
bars. Keep the file name, the function name, and its signature.

Symptom: progress bars never reach the end. When a task is fully finished, the
bar stalls just short of full and never shows completion, even though every
item has been done. Partly-finished tasks look right; only the finished state
is wrong.

Expected behavior:
- A finished task (everything done) reports `100`.
- A task with nothing done reports `0`.
- A partly-finished task reports the floor of its true percentage
  (7 of 10 done is `70`; 1 of 3 done is `33`).
- `total` must be positive and `done` must be within `[0, total]`; anything
  else raises `ValueError`.

A basic check exists in `test_visible.py`; keep it passing. Diagnose why the
finished state is wrong and correct it. Do not change the signature or add
anything new.
