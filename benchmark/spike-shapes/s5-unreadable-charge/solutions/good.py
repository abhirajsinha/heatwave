def charge_order(order, client):
    key = "charge:%s" % order["id"]
    last = None
    for _ in range(3):
        try:
            return client.charge(order["id"], order["total_cents"], idempotency_key=key)
        except Exception as e:
            last = e
    raise last
