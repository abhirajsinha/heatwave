import unittest
from feed import Feed
from pager import next_page


def _feed():
    return Feed([{"id": i} for i in (5, 4, 3, 2, 1)])


class TestOracle(unittest.TestCase):
    def test_no_repeat_after_insert(self):
        # SPEC: An item returned on an earlier page must never appear again on a later page.
        feed = _feed()
        p1 = next_page(feed, None, 2)
        page1_ids = {r["id"] for r in p1["rows"]}
        feed.insert_newest({"id": 6})
        p2 = next_page(feed, p1["cursor"], 2)
        page2_ids = {r["id"] for r in p2["rows"]}
        self.assertEqual(page1_ids & page2_ids, set())

    def test_first_page_is_newest(self):
        # SPEC: Items are ordered newest-first: a higher id is newer.
        p1 = next_page(_feed(), None, 2)
        self.assertEqual([r["id"] for r in p1["rows"]], [5, 4])


if __name__ == "__main__":
    unittest.main()
