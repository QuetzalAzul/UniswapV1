import pytest



@pytest.fixture(scope='module')
def token(tokenPrueba, accounts):
    contract = tokenPrueba.deploy({'from': accounts[0]})
    return contract



@pytest.fixture(scope='module')
def exchange(Exchange, accounts, token):
    contract = Exchange.deploy({'from': accounts[0]})
    return contract
