import unittest
from library import Library
from search import list_documents, search_documents


class TestVisible(unittest.TestCase):
    def test_owner_sees_own_docs(self):
        lib = Library([
            {"id": "1", "owner_id": "alice", "title": "quarterly report"},
            {"id": "2", "owner_id": "alice", "title": "grocery list"},
        ])
        self.assertEqual([d["id"] for d in list_documents(lib, "alice")], ["1", "2"])
        self.assertEqual([d["id"] for d in search_documents(lib, "alice", "report")], ["1"])


if __name__ == "__main__":
    unittest.main()
