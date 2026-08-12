import unittest
from progress import percent_complete


class TestVisible(unittest.TestCase):
    def test_nothing_done(self):
        self.assertEqual(percent_complete(0, 10), 0)

    def test_half_done(self):
        self.assertEqual(percent_complete(5, 10), 50)

    def test_zero_total_rejected(self):
        with self.assertRaises(ValueError):
            percent_complete(0, 0)


if __name__ == "__main__":
    unittest.main()
