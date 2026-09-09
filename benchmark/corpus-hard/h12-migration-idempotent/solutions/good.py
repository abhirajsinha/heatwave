def migrate(records):
    out = []
    for r in records:
        if r.get("version") == 2:
            out.append(dict(r))
        else:
            out.append({**r, "version": 2, "status": "active"})
    return out
