"""Input validation for the ledger API."""


def is_valid_txn(txn):
    return isinstance(txn.get("id"), str) and isinstance(txn.get("amount"), int)
