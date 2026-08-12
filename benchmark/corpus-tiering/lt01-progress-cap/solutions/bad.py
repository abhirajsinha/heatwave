"""Progress-indicator helper. See SPEC.md for the contract."""


def percent_complete(done, total):
    if total <= 0:
        raise ValueError("total must be positive")
    if done < 0 or done > total:
        raise ValueError("done must be in [0, total]")
    pct = (done * 100) // total
    return min(pct, 99)
