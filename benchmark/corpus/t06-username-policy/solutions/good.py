"""Username policy check for signup. See SPEC.md."""
import re

_POLICY = re.compile(r"[a-z][a-z0-9_]{2,19}\Z")


def is_valid_username(name):
    return bool(_POLICY.fullmatch(name))
