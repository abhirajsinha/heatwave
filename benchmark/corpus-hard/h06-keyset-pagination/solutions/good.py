def next_page(store, cursor, limit):
    items = store.snapshot()
    if cursor is not None:
        items = [it for it in items if it["id"] < cursor]
    rows = items[:limit]
    next_cursor = rows[-1]["id"] if rows else cursor
    return {"rows": rows, "cursor": next_cursor}
