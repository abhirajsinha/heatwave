from rates import RATES


def usage_cost(account_id, num_events, accounts):
    acct = accounts.get(account_id)
    return RATES[acct["tier"]] * num_events
