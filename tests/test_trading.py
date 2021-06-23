import pytest


def test_setup_exchange(exchange, token, accounts):

    exchange.setup(token, {"from": accounts[0]})
    assert exchange.tokenAddress() == token

def test_add_initialLiquidity(exchange,token, accounts):

    token.approve(exchange, 10000e18, {"from":accounts[0]})
    exchange.addLiquidity(100e18, 1000e18, {"from":accounts[0], "value":10e18})

    assert exchange.balanceOf(accounts[0]) == 10e18
    assert exchange.totalSupply() == 10e18
    assert exchange.balance() == 10e18
    assert token.balanceOf(exchange) == 1000e18
    assert token.balanceOf(accounts[0]) == 9000e18

def test_first_buy_of_token(exchange,token,accounts):

    exchange.ethToTokenSwapInput(909e17, {"from": accounts[1], "value":1e18})

    assert exchange.balance() == 11e18
    assert 909e18 < token.balanceOf(exchange) < 910e18
    assert token.balanceOf(accounts[1]) >= 909e17

def test_second_buy_of_token(exchange, token, accounts):

    exchange.ethToTokenSwapInput(1398e17, {"from": accounts[0], "value":2e18})

    assert exchange.balance() == 13e18
    assert 769e18 < token.balanceOf(exchange) < 770e18
    assert token.balanceOf(accounts[1]) >= 909e17
    assert 9139e18 < token.balanceOf(accounts[0]) < 9140e18

def test_add_liquidity(exchange, token, accounts):

    token.approve(exchange, 10000e18, {"from":accounts[1]})
    exchange.addLiquidity(76e16, 5960e16, {"from":accounts[1], "value":1e18})

    assert exchange.balanceOf(accounts[1]) >= 76e16
    assert exchange.totalSupply() >= 1076e16
    assert exchange.balance() == 14e18
    assert 828e18 < token.balanceOf(exchange) < 829e18
    assert 3154 < token.balanceOf(accounts[1]) >= 3155e16

def test_remove_liquidity(exchange, token, accounts):

    exchange.removeLiquidity(5e18,649e16,384e18, {"from":accounts[0]})
    assert exchange.balanceOf(accounts[0]) == 5e18
    assert 9524e18 < token.balanceOf(accounts[0]) < 9525e18
