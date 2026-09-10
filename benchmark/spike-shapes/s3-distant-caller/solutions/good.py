def to_record(txn):
    cents = txn["amount"]
    return {
        "id": txn["id"],
        "amount": cents,
        "amount_display": "$%d.%02d" % (cents // 100, cents % 100),
    }
