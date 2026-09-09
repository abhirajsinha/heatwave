import unittest
from docstore import DocStore
from docs import get_document


class TestVisible(unittest.TestCase):
    def test_owner_reads_own_document(self):
        store = DocStore([
            {"id": "d1", "owner_id": "alice", "shared_with": [], "body": "hi"},
        ])
        doc = get_document(store, "alice", "d1")
        self.assertEqual(doc["body"], "hi")


if __name__ == "__main__":
    unittest.main()
