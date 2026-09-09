import unittest
from resource import Resource
from importer import run_import


class TestVisible(unittest.TestCase):
    def test_success_commits_and_releases(self):
        res = Resource()
        run_import(res, ["a", "b"], lambda r: r.upper())
        self.assertEqual(res.written, ["A", "B"])
        self.assertTrue(res.committed)
        self.assertTrue(res.released)


if __name__ == "__main__":
    unittest.main()
