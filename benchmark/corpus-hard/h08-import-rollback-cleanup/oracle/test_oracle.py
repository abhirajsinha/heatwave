import unittest
from resource import Resource
from importer import run_import


def _boom(row):
    if row == "bad":
        raise RuntimeError("row failed")
    return row


class TestOracle(unittest.TestCase):
    def test_failure_rolls_back(self):
        # SPEC: If applying transform or writing raises, run_import rolls back and lets the error propagate.
        res = Resource()
        with self.assertRaises(RuntimeError):
            run_import(res, ["ok", "bad", "ok2"], _boom)
        self.assertTrue(res.rolled_back)
        self.assertFalse(res.committed)

    def test_failure_still_releases(self):
        # SPEC: Whether it succeeds or fails, run_import must release the resource.
        res = Resource()
        try:
            run_import(res, ["ok", "bad"], _boom)
        except RuntimeError:
            pass
        self.assertTrue(res.released)


if __name__ == "__main__":
    unittest.main()
