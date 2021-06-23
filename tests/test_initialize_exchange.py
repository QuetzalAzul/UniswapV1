import pytest

def test_deployeo_tokenPrueba(token, accounts):

    assert token.balanceOf(accounts[0]) == 10000e18
    assert token.name() == "TokenPrueba"
    assert token.symbol() == "TKN"
    assert token.totalSupply() == 10000e18


def test_deployeo_exchange(exchange, accounts):

    assert exchange.balanceOf(accounts[0]) == 0
    assert exchange.name() == "COINSMOS LP"
    assert exchange.symbol() == "CLP"
    assert exchange.totalSupply() == 0
