def mean(values):
    if len(values) == 0:
        raise ValueError("mean() of empty input")
    total = 0.0
    for v in values:
        if isinstance(v, bool) or not isinstance(v, (int, float)):
            raise TypeError("non-numeric element: %r" % (v,))
        total += v
    return total / len(values)
