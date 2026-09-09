import unittest
from loader import load_record


class TestVisible(unittest.TestCase):
    def test_current_record(self):
        rec = load_record({"id": 1, "name": "a", "tags": ["x", "y"]})
        self.assertEqual(rec, {"id": 1, "name": "a", "tags": ["x", "y"]})


if __name__ == "__main__":
    unittest.main()
