def next_page(store, cursor, limit):
    offset = cursor or 0
    items = store.snapshot()
    rows = items[offset:offset + limit]
    return {"rows": rows, "cursor": offset + limit}
