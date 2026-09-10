def charge_order(order, client):
    return client.charge(order["id"], order["total_cents"])
