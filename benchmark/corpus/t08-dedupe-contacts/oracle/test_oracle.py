import unittest
from dedupe import dedupe_contacts


class TestOracle(unittest.TestCase):
    def test_case_insensitive_duplicate_removed(self):  # SPEC: "emails match case-insensitively"
        contacts = [
            {"email": "Ada@example.com", "name": "Ada L"},
            {"email": "ada@EXAMPLE.com", "name": "Ada Lovelace"},
        ]
        self.assertEqual(dedupe_contacts(contacts),
                         [{"email": "Ada@example.com", "name": "Ada L"}])

    def test_first_occurrence_kept_verbatim(self):      # SPEC: "keep the first occurrence exactly as it appeared"
        contacts = [
            {"email": "BOB@x.com", "name": "Bobby"},
            {"email": "bob@x.com", "name": "Bob"},
        ]
        self.assertEqual(dedupe_contacts(contacts),
                         [{"email": "BOB@x.com", "name": "Bobby"}])

    def test_order_of_first_appearance(self):           # SPEC: "order ... is the order of their first appearance"
        contacts = [
            {"email": "c@x.com", "name": "C"},
            {"email": "a@x.com", "name": "A"},
            {"email": "C@x.com", "name": "C2"},
            {"email": "b@x.com", "name": "B"},
        ]
        self.assertEqual([c["email"] for c in dedupe_contacts(contacts)],
                         ["c@x.com", "a@x.com", "b@x.com"])

    def test_input_not_modified(self):                  # SPEC: "The input list is not modified."
        contacts = [
            {"email": "a@x.com", "name": "A"},
            {"email": "A@x.com", "name": "A2"},
        ]
        snapshot = [dict(c) for c in contacts]
        dedupe_contacts(contacts)
        self.assertEqual(contacts, snapshot)

    def test_no_duplicates_untouched(self):             # SPEC: "Returns a new list with duplicate contacts removed."
        contacts = [
            {"email": "a@x.com", "name": "A"},
            {"email": "b@x.com", "name": "B"},
        ]
        self.assertEqual(dedupe_contacts(contacts), contacts)

    def test_empty_list(self):                          # SPEC: "Returns a new list" (nothing to remove)
        self.assertEqual(dedupe_contacts([]), [])


if __name__ == "__main__":
    unittest.main()
