from retry_errors import TransientError  # noqa: F401


def call_with_retry(fn, max_attempts, sleeper):
    attempt = 0
    while True:
        attempt += 1
        try:
            return fn()
        except Exception:
            if attempt >= max_attempts:
                raise
            sleeper(1)
