# Task: fix the crash in logstats.summarize()

Bug report: the nightly job crashed with a traceback from
`logstats.summarize()`. Our logs are JSON-lines, but real log files contain
occasional corrupt lines (truncated writes) and blank lines.

Fix `logstats.py` (keep the file and function name) so that:
- Valid lines are counted by their `"level"` field, as today.
- A corrupt (unparseable) line, a blank line, or a record without a `"level"`
  field is counted under the key `"_malformed"` and processing continues.
- An empty file returns `{}`.

`test_visible.py` covers the working case; keep it passing.
