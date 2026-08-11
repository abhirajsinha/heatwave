"""Username policy check for signup. See SPEC.md."""


def is_valid_username(name):
    return 3 <= len(name) <= 20
