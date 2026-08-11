def cart_total(items):
    return round(sum(item["price"] * item["qty"] for item in items), 2)
