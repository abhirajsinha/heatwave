# Task: implement paginate()

Implement `paginate(items, page, page_size)` in `pagination.py` (keep the file
and function name — callers import `pagination.paginate`).

Contract:
- `items` is a list; `page` is 1-indexed (the first page is page 1).
- Returns the list of items belonging to that page, in order.
- The last page may be partial. A page past the last page returns `[]`.
- `page` and `page_size` must be integers >= 1; anything else raises `ValueError`.

A basic check exists in `test_visible.py`; make it pass. The function is used
to render search-result pages, so boundary behavior matters.
