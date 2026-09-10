"""Domain model helpers."""


def make_txn(txn_id, amount):
    return {"id": txn_id, "amount": amount}
