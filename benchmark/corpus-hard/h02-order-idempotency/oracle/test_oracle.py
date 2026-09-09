import unittest
from orderstore import OrderStore
from orders import place_order


class TestOracle(unittest.TestCase):
    def test_retry_does_not_readd_items(self):
        # SPEC: A retried order with the same order_id must not add its line items again.
        store = OrderStore()
        place_order(store, "o1", ["a", "b"])
        place_order(store, "o1", ["a", "b"])
        self.assertEqual(store.line_items, ["a", "b"])

    def test_retry_returns_first_record(self):
        # SPEC: A repeated call returns the order recorded by the first call.
        store = OrderStore()
        first = place_order(store, "o1", ["a", "b"])
        second = place_order(store, "o1", ["a", "b"])
        self.assertEqual(second, first)

    def test_distinct_orders_each_add(self):
        # SPEC: place_order is idempotent on order_id.
        store = OrderStore()
        place_order(store, "o1", ["a"])
        place_order(store, "o2", ["b"])
        self.assertEqual(store.line_items, ["a", "b"])


if __name__ == "__main__":
    unittest.main()
