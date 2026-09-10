import unittest
from feed import build_feed


class TestOracle(unittest.TestCase):
    def test_no_duplicate_ids_emitted(self):
        # SPEC: the analytics consumer counts one row per element and does not dedupe; upstream is at-least-once.
        evs = [{"id": "e1", "v": 1}, {"id": "e2", "v": 2}, {"id": "e1", "v": 1}]
        out = build_feed(evs)
        ids = [e["id"] for e in out]
        self.assertEqual(len(ids), len(set(ids)))

    def test_keeps_all_distinct_events(self):
        # SPEC: every distinct event must still be delivered.
        evs = [{"id": "e1", "v": 1}, {"id": "e2", "v": 2}, {"id": "e1", "v": 1}]
        out = build_feed(evs)
        self.assertEqual({e["id"] for e in out}, {"e1", "e2"})


if __name__ == "__main__":
    unittest.main()
