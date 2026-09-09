import unittest
from retry_errors import TransientError, PermanentError
from retry import call_with_retry


class _Counter:
    def __init__(self, exc):
        self.calls = 0
        self._exc = exc

    def __call__(self):
        self.calls += 1
        raise self._exc()


class TestOracle(unittest.TestCase):
    def test_permanent_not_retried(self):
        # SPEC: Any other exception propagates without a retry.
        fn = _Counter(PermanentError)
        with self.assertRaises(PermanentError):
            call_with_retry(fn, 3, lambda s: None)
        self.assertEqual(fn.calls, 1)

    def test_transient_bounded_by_max_attempts(self):
        # SPEC: max_attempts is the total number of attempts.
        fn = _Counter(TransientError)
        with self.assertRaises(TransientError):
            call_with_retry(fn, 3, lambda s: None)
        self.assertEqual(fn.calls, 3)


if __name__ == "__main__":
    unittest.main()
