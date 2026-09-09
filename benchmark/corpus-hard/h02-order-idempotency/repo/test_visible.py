import unittest
from orderstore import OrderStore
from orders import place_order


class TestVisible(unittest.TestCase):
    def test_single_order_adds_items(self):
        store = OrderStore()
        rec = place_order(store, "o1", ["a", "b"])
        self.assertEqual(store.line_items, ["a", "b"])
        self.assertEqual(rec["order_id"], "o1")


if __name__ == "__main__":
    unittest.main()
