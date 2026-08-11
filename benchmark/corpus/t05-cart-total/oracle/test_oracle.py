import unittest
from cart import cart_total


class TestOracle(unittest.TestCase):
    def test_zero_qty_rejected(self):        # SPEC: "a zero, negative, or non-integer qty raises ValueError"
        with self.assertRaises(ValueError):
            cart_total([{"price": 1.00, "qty": 0}])

    def test_negative_qty_rejected(self):    # SPEC: "a zero, negative, or non-integer qty raises ValueError"
        with self.assertRaises(ValueError):
            cart_total([{"price": 1.00, "qty": -2}])

    def test_non_integer_qty_rejected(self): # SPEC: "qty must be an integer >= 1 ... non-integer qty raises ValueError"
        with self.assertRaises(ValueError):
            cart_total([{"price": 1.00, "qty": 1.5}])

    def test_negative_price_rejected(self):  # SPEC: "a negative price raises ValueError"
        with self.assertRaises(ValueError):
            cart_total([{"price": -5.00, "qty": 1}])

    def test_cent_exact_rounding(self):      # SPEC: "rounded to 2 decimal places (money is cent-exact)"
        self.assertEqual(cart_total([{"price": 0.10, "qty": 3}]), 0.30)
        self.assertEqual(cart_total([{"price": 19.99, "qty": 3}]), 59.97)

    def test_empty_cart(self):               # SPEC: "An empty cart totals 0.0."
        self.assertEqual(cart_total([]), 0.0)


if __name__ == "__main__":
    unittest.main()
