def create_invoice(store, order_id, note=""):
    return {
        "id": store.next_id(),
        "order_id": order_id,
        "amount": store.amount_for(order_id),
        "note": note,
    }
