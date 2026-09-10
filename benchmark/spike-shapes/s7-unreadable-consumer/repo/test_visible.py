import unittest
from feed import build_feed


class TestVisible(unittest.TestCase):
    def test_returns_rows(self):
        evs = [{"id": "e1", "v": 1}, {"id": "e2", "v": 2}]
        out = build_feed(evs)
        self.assertEqual([e["id"] for e in out], ["e1", "e2"])


if __name__ == "__main__":
    unittest.main()
