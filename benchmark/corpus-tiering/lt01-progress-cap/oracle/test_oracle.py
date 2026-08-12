import unittest
from progress import percent_complete


class TestOracle(unittest.TestCase):
    def test_fully_done_is_100(self):            # SPEC: "A finished task ... reports 100."
        self.assertEqual(percent_complete(10, 10), 100)

    def test_small_fully_done_is_100(self):      # SPEC: "A finished task ... reports 100." (small total)
        self.assertEqual(percent_complete(3, 3), 100)

    def test_partial_floor_seven_tenths(self):   # SPEC: "the floor of its true percentage" (7 of 10 -> 70)
        self.assertEqual(percent_complete(7, 10), 70)

    def test_partial_floor_one_third(self):      # SPEC: "the floor of its true percentage" (1 of 3 -> 33)
        self.assertEqual(percent_complete(1, 3), 33)

    def test_partial_floor_two_thirds(self):     # SPEC: "the floor of its true percentage" (2 of 3 -> 66)
        self.assertEqual(percent_complete(2, 3), 66)

    def test_nonpositive_total_rejected(self):   # SPEC: "total must be positive ... raises ValueError"
        with self.assertRaises(ValueError):
            percent_complete(0, 0)

    def test_done_out_of_range_rejected(self):   # SPEC: "done must be within [0, total] ... raises ValueError"
        with self.assertRaises(ValueError):
            percent_complete(11, 10)


if __name__ == "__main__":
    unittest.main()
