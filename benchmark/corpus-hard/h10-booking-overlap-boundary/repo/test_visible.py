import unittest
from booking import overlaps


class TestVisible(unittest.TestCase):
    def test_clear_overlap(self):
        self.assertTrue(overlaps(0, 10, 5, 15))

    def test_clear_gap(self):
        self.assertFalse(overlaps(0, 5, 10, 15))


if __name__ == "__main__":
    unittest.main()
