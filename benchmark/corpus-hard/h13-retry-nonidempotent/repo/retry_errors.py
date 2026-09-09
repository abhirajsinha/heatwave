"""Error types for call_with_retry. See SPEC.md."""


class TransientError(Exception):
    pass


class PermanentError(Exception):
    pass
