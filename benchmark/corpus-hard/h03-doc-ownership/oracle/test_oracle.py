import unittest
from docstore import DocStore
from docs import get_document


def _store():
    return DocStore([
        {"id": "d1", "owner_id": "alice", "shared_with": ["carol"], "body": "hi"},
    ])


class TestOracle(unittest.TestCase):
    def test_non_owner_forbidden(self):
        # SPEC: If the user is not permitted, raise PermissionError.
        with self.assertRaises(PermissionError):
            get_document(_store(), "bob", "d1")

    def test_shared_user_allowed(self):
        # SPEC: get_document returns the document only if user_id is its owner or is listed in shared_with.
        doc = get_document(_store(), "carol", "d1")
        self.assertEqual(doc["id"], "d1")

    def test_missing_document(self):
        # SPEC: If the document does not exist, raise LookupError.
        with self.assertRaises(LookupError):
            get_document(_store(), "alice", "nope")


if __name__ == "__main__":
    unittest.main()
