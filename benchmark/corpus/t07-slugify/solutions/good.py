import re


def slugify(title):
    slug = title.lower()
    slug = re.sub(r"[ _-]+", "-", slug)
    slug = re.sub(r"[^a-z0-9-]", "", slug)
    slug = re.sub(r"-+", "-", slug)
    return slug.strip("-")
