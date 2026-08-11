import unittest
from datetime import date
from datewindow import overlap_days


class TestOracle(unittest.TestCase):
    def test_single_shared_day(self):        # SPEC: "Windows that touch on exactly one day share 1 day."
        self.assertEqual(
            overlap_days(date(2026, 1, 1), date(2026, 1, 5),
                         date(2026, 1, 5), date(2026, 1, 8)), 1)

    def test_same_day_windows(self):         # SPEC: "touch on exactly one day share 1 day" (both windows are that day)
        self.assertEqual(
            overlap_days(date(2026, 2, 3), date(2026, 2, 3),
                         date(2026, 2, 3), date(2026, 2, 3)), 1)

    def test_partial_overlap_inclusive(self):  # SPEC: "counting both endpoints" — Jan 5..Jan 10 is 6 days
        self.assertEqual(
            overlap_days(date(2026, 1, 1), date(2026, 1, 10),
                         date(2026, 1, 5), date(2026, 1, 20)), 6)

    def test_contained_window(self):         # SPEC: "start date to its end date inclusive" — Jan 10..12 is 3 days
        self.assertEqual(
            overlap_days(date(2026, 1, 1), date(2026, 1, 31),
                         date(2026, 1, 10), date(2026, 1, 12)), 3)

    def test_disjoint_still_zero(self):      # SPEC: "Windows that do not overlap at all share 0 days."
        self.assertEqual(
            overlap_days(date(2026, 1, 1), date(2026, 1, 5),
                         date(2026, 2, 1), date(2026, 2, 5)), 0)


if __name__ == "__main__":
    unittest.main()
