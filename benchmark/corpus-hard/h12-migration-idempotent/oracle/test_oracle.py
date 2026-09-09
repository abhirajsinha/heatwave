import unittest
from migrate import migrate


class TestOracle(unittest.TestCase):
    def test_existing_v2_unchanged(self):
        # SPEC: A record already at version 2 is returned unchanged.
        records = [
            {"id": 1, "name": "a"},
            {"id": 2, "name": "b", "version": 2, "status": "closed"},
        ]
        out = migrate(records)
        self.assertEqual(out[1], {"id": 2, "name": "b", "version": 2, "status": "closed"})

    def test_no_record_dropped(self):
        # SPEC: migrate must not drop any record.
        records = [{"id": 1, "name": "a"},
                   {"id": 2, "name": "b", "version": 2, "status": "closed"}]
        self.assertEqual(len(migrate(records)), 2)

    def test_rerun_is_stable(self):
        # SPEC: Running migrate again on its own output returns the same list.
        records = [{"id": 1, "name": "a"},
                   {"id": 2, "name": "b", "version": 2, "status": "closed"}]
        once = migrate(records)
        self.assertEqual(migrate(once), once)


if __name__ == "__main__":
    unittest.main()
