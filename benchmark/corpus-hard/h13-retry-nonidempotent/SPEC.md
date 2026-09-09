# Task: implement call_with_retry()

Implement `call_with_retry(fn, max_attempts, sleeper)` in `retry.py` (keep the
file and function name).

`fn` is a zero-argument callable. `sleeper(seconds)` waits between attempts.
`TransientError` and `PermanentError` are importable from `retry_errors`.

Contract:
- call_with_retry calls fn and returns its result on success.
- call_with_retry retries only when fn raises TransientError.
- Any other exception propagates without a retry.
- max_attempts is the total number of attempts.
- Before each retry, call sleeper(1).

A basic check exists in `test_visible.py`.
