import unittest
from pagination import paginate


class TestOracle(unittest.TestCase):
    def test_last_partial_page(self):        # SPEC: "The last page may be partial."
        self.assertEqual(paginate(list(range(10)), 4, 3), [9])

    def test_page_past_end_empty(self):      # SPEC: "A page past the last page returns []."
        self.assertEqual(paginate(list(range(10)), 5, 3), [])

    def test_exact_boundary(self):           # SPEC: 1-indexed + past-end contract at len % size == 0
        self.assertEqual(paginate(list(range(9)), 3, 3), [6, 7, 8])
        self.assertEqual(paginate(list(range(9)), 4, 3), [])

    def test_empty_items(self):              # SPEC: past-end contract; page 1 of [] is past the end
        self.assertEqual(paginate([], 1, 3), [])

    def test_page_zero_rejected(self):       # SPEC: "page and page_size must be integers >= 1 ... ValueError"
        with self.assertRaises(ValueError):
            paginate(list(range(10)), 0, 3)

    def test_negative_page_size_rejected(self):  # SPEC: "page and page_size must be integers >= 1 ... ValueError"
        with self.assertRaises(ValueError):
            paginate(list(range(10)), 1, -1)

    def test_non_integer_rejected(self):     # SPEC: "must be integers >= 1 ... ValueError"
        with self.assertRaises(ValueError):
            paginate(list(range(10)), "1", 3)


if __name__ == "__main__":
    unittest.main()
