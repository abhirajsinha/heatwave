import unittest
from stats import mean


class TestVisible(unittest.TestCase):
    def test_mean_of_ints(self):
        self.assertEqual(mean([1, 2, 3]), 2.0)

    def test_mean_of_floats(self):
        self.assertEqual(mean([2.0, 4.0]), 3.0)


if __name__ == "__main__":
    unittest.main()
