import unittest
from library import Library
from search import list_documents, search_documents


def _lib():
    return Library([
        {"id": "1", "owner_id": "alice", "title": "quarterly report"},
        {"id": "2", "owner_id": "bob", "title": "annual report"},
    ])


class TestOracle(unittest.TestCase):
    def test_search_does_not_leak_other_owner(self):
        # SPEC: search_documents returns only documents owned by owner_id whose title contains query.
        got = [d["id"] for d in search_documents(_lib(), "alice", "report")]
        self.assertEqual(got, ["1"])

    def test_list_does_not_leak_other_owner(self):
        # SPEC: list_documents returns only documents whose owner_id equals owner_id.
        got = [d["id"] for d in list_documents(_lib(), "alice")]
        self.assertEqual(got, ["1"])


if __name__ == "__main__":
    unittest.main()
