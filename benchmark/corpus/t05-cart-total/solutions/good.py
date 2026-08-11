def cart_total(items):
    total = 0.0
    for item in items:
        price = item["price"]
        qty = item["qty"]
        if isinstance(qty, bool) or not isinstance(qty, int) or qty < 1:
            raise ValueError("qty must be an integer >= 1")
        if isinstance(price, bool) or not isinstance(price, (int, float)) or price < 0:
            raise ValueError("price must be a number >= 0")
        total += price * qty
    return round(total, 2)
