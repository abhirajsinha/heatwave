def run_import(resource, rows, transform):
    try:
        for row in rows:
            resource.write(transform(row))
        resource.commit()
    except Exception:
        resource.rollback()
        raise
    finally:
        resource.release()
