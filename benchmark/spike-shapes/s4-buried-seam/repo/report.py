"""Daily reporting. Sums record amounts (cents) into a daily total."""

from serialize import to_record


def daily_total(txns):
    return sum(to_record(t)["amount"] for t in txns)
