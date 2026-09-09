def save_all(store, records):
    for r in records:
        if r["amount"] <= 0:
            raise ValueError("invalid amount")
        store.save(r)
    return len(records)
