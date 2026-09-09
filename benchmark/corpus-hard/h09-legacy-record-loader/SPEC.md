# Task: implement load_record()

Implement `load_record(raw)` in `loader.py` (keep the file and function name).

A current record is a dict `{"id", "name", "tags"}` where `tags` is a list.
A legacy record has no tags field.

Contract:
- load_record returns a normalized dict {"id", "name", "tags"}.
- When tags is absent, load_record returns tags as an empty list.

A basic check exists in `test_visible.py`.
