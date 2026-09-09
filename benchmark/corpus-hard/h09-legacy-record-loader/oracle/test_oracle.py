import unittest
from loader import load_record


class TestOracle(unittest.TestCase):
    def test_legacy_record_defaults_tags(self):
        # SPEC: When tags is absent, load_record returns tags as an empty list.
        rec = load_record({"id": 2, "name": "b"})
        self.assertEqual(rec, {"id": 2, "name": "b", "tags": []})

    def test_current_record_preserved(self):
        # SPEC: load_record returns a normalized dict {"id", "name", "tags"}.
        rec = load_record({"id": 1, "name": "a", "tags": ["x"]})
        self.assertEqual(rec, {"id": 1, "name": "a", "tags": ["x"]})


if __name__ == "__main__":
    unittest.main()
