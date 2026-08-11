"""Shared-day counter for service windows. See SPEC.md."""


def overlap_days(a_start, a_end, b_start, b_end):
    start = max(a_start, b_start)
    end = min(a_end, b_end)
    return max(0, (end - start).days)
