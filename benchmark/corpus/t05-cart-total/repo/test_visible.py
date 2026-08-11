import unittest
from cart import cart_total


class TestVisible(unittest.TestCase):
    def test_two_item_cart(self):
        items = [{"price": 2.50, "qty": 2}, {"price": 1.00, "qty": 3}]
        self.assertEqual(cart_total(items), 8.00)

    def test_single_item(self):
        self.assertEqual(cart_total([{"price": 9.99, "qty": 1}]), 9.99)


if __name__ == "__main__":
    unittest.main()
