def list_documents(library, owner_id):
    return [d for d in library.all_docs() if d["owner_id"] == owner_id]


def search_documents(library, owner_id, query):
    return [d for d in library.all_docs()
            if d["owner_id"] == owner_id and query in d["title"]]
