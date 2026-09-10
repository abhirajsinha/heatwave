def to_record(txn):
    cents = txn["amount"]
    return {"id": txn["id"], "amount": "$%d.%02d" % (cents // 100, cents % 100)}
