# Task: implement mean()

Implement `mean(values)` in `stats.py` (keep the file and function name —
dashboards import `stats.mean`).

Contract:
- `values` is a list of numbers; return their arithmetic mean as a `float`.
- An empty list raises `ValueError` (a silent 0 or a crash from division would
  corrupt downstream averages).
- Any element that is not an `int` or `float` raises `TypeError`. Booleans are
  not numbers for this function: a `bool` element also raises `TypeError`.
- A single-element list returns that element as a `float`.

A basic check exists in `test_visible.py`; make it pass.
