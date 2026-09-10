"""Pagination helpers."""


def page(items, size, n):
    return items[n * size:(n + 1) * size]
