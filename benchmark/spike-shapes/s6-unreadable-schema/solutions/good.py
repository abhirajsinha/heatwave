from rates import RATES, DEFAULT_TIER


def usage_cost(account_id, num_events, accounts):
    acct = accounts.get(account_id)
    tier = acct.get("tier", DEFAULT_TIER)
    rate = RATES.get(tier, RATES[DEFAULT_TIER])
    return rate * num_events
