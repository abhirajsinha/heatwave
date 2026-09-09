def migrate(records):
    return [{**r, "version": 2, "status": "active"} for r in records]
