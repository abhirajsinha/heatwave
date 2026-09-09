import unittest
from booking import overlaps


class TestOracle(unittest.TestCase):
    def test_adjacent_intervals_do_not_overlap(self):
        # SPEC: Two intervals that touch only at an endpoint do not overlap.
        self.assertFalse(overlaps(0, 5, 5, 10))
        self.assertFalse(overlaps(5, 10, 0, 5))

    def test_shared_interior_overlaps(self):
        # SPEC: overlaps returns True when the two intervals share at least one point, otherwise False.
        self.assertTrue(overlaps(0, 10, 5, 15))

    def test_disjoint_do_not_overlap(self):
        # SPEC: Intervals are half-open: [start, end) includes start and excludes end.
        self.assertFalse(overlaps(0, 5, 6, 9))


if __name__ == "__main__":
    unittest.main()
