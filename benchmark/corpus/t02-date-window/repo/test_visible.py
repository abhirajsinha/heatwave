import unittest
from datetime import date
from datewindow import overlap_days


class TestVisible(unittest.TestCase):
    def test_disjoint_windows_share_nothing(self):
        self.assertEqual(
            overlap_days(date(2026, 1, 1), date(2026, 1, 5),
                         date(2026, 1, 10), date(2026, 1, 12)), 0)

    def test_disjoint_windows_reversed_order(self):
        self.assertEqual(
            overlap_days(date(2026, 3, 20), date(2026, 3, 25),
                         date(2026, 3, 1), date(2026, 3, 10)), 0)


if __name__ == "__main__":
    unittest.main()
