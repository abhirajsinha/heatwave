import unittest
from retry_errors import TransientError
from retry import call_with_retry


class TestVisible(unittest.TestCase):
    def test_succeeds_after_transient(self):
        state = {"calls": 0}

        def fn():
            state["calls"] += 1
            if state["calls"] < 3:
                raise TransientError()
            return "ok"

        sleeps = []
        self.assertEqual(call_with_retry(fn, 3, sleeps.append), "ok")
        self.assertEqual(state["calls"], 3)


if __name__ == "__main__":
    unittest.main()
