def paginate(items, page, page_size):
    if not isinstance(page, int) or isinstance(page, bool) or page < 1:
        raise ValueError("page must be an integer >= 1")
    if not isinstance(page_size, int) or isinstance(page_size, bool) or page_size < 1:
        raise ValueError("page_size must be an integer >= 1")
    start = (page - 1) * page_size
    return items[start:start + page_size]
