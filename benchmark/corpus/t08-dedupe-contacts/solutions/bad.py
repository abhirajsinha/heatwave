def dedupe_contacts(contacts):
    seen = set()
    result = []
    for contact in contacts:
        if contact["email"] not in seen:
            seen.add(contact["email"])
            result.append(contact)
    return result
