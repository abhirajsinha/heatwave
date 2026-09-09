def place_order(store, order_id, items):
    existing = store.get_order(order_id)
    if existing is not None:
        return existing
    store.add_line_items(items)
    record = {"order_id": order_id, "items": items}
    store.save_order(order_id, record)
    return record
