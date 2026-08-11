# Task: fix the day count in datewindow.overlap_days()

Bug report: the billing report shows one fewer shared day than expected when two
service windows overlap, and windows that touch on a single day show 0 shared
days instead of 1.

Fix `datewindow.py` (keep the file and function name — reports import
`datewindow.overlap_days`).

Contract:
- `overlap_days(a_start, a_end, b_start, b_end)` takes `datetime.date` values;
  each window runs from its start date to its end date **inclusive** (both
  endpoints are part of the window).
- It returns the number of calendar days the two windows share, counting both
  endpoints. Windows that touch on exactly one day share 1 day.
- Windows that do not overlap at all share 0 days.

`test_visible.py` covers the non-overlapping case, which works today; keep it
passing.
