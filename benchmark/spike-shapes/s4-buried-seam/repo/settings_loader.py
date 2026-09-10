import config


def flag(name):
    return config.FEATURE_FLAGS.get(name, False)
