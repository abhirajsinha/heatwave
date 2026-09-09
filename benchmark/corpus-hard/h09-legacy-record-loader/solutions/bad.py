def load_record(raw):
    return {"id": raw["id"], "name": raw["name"], "tags": raw["tags"]}
