import unittest
from migrate import migrate


class TestVisible(unittest.TestCase):
    def test_v1_records_upgraded(self):
        out = migrate([{"id": 1, "name": "a"}, {"id": 2, "name": "b"}])
        self.assertEqual(out, [
            {"id": 1, "name": "a", "version": 2, "status": "active"},
            {"id": 2, "name": "b", "version": 2, "status": "active"},
        ])


if __name__ == "__main__":
    unittest.main()
