# Task: implement next_page()

Implement `next_page(store, cursor, limit)` in `pager.py` (keep the file and
function name).

`store.snapshot()` returns the current list of items, ordered newest-first.
Each item is a dict with an integer `id`. `store.insert_newest(item)` may add a
newer item at any time.

Contract:
- `next_page` returns `{"rows": <list of up to limit items>, "cursor": <token>}`.
- For the first page, `cursor` is `None`.
- To fetch the next page, pass back the cursor from the previous result.
- Items are ordered newest-first: a higher id is newer.
- An item returned on an earlier page must never appear again on a later page.

A basic check exists in `test_visible.py`.
