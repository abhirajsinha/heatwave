"""Access control."""

ROLES = {"admin": 3, "staff": 2, "viewer": 1}


def can_view(role):
    return ROLES.get(role, 0) >= 1
