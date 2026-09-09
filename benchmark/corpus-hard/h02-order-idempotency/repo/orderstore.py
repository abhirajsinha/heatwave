"""In-memory order store. See SPEC.md. Injected into place_order()."""


class OrderStore:
    def __init__(self):
        self._orders = {}
        self.line_items = []

    def get_order(self, order_id):
        return self._orders.get(order_id)

    def save_order(self, order_id, record):
        self._orders[order_id] = record

    def add_line_items(self, items):
        self.line_items.extend(items)
