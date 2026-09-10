"""Audit trail."""


def log_event(kind, payload):
    return {"kind": kind, "payload": payload}
