import unittest
from feed import Feed
from pager import next_page


def _feed():
    return Feed([{"id": i} for i in (5, 4, 3, 2, 1)])


class TestVisible(unittest.TestCase):
    def test_two_pages_no_mutation(self):
        feed = _feed()
        p1 = next_page(feed, None, 2)
        self.assertEqual([r["id"] for r in p1["rows"]], [5, 4])
        p2 = next_page(feed, p1["cursor"], 2)
        self.assertEqual([r["id"] for r in p2["rows"]], [3, 2])


if __name__ == "__main__":
    unittest.main()
