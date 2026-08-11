import unittest
from dedupe import dedupe_contacts


class TestVisible(unittest.TestCase):
    def test_exact_duplicate_removed(self):
        contacts = [
            {"email": "ada@example.com", "name": "Ada"},
            {"email": "bob@example.com", "name": "Bob"},
            {"email": "ada@example.com", "name": "Ada"},
        ]
        self.assertEqual(dedupe_contacts(contacts), [
            {"email": "ada@example.com", "name": "Ada"},
            {"email": "bob@example.com", "name": "Bob"},
        ])


if __name__ == "__main__":
    unittest.main()
