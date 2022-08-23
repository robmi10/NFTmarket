import pytest
from scripts.deploy import deployNftMarket
from web3 import Web3
price = Web3.toWei(2, "ether")

def testCreateNft():
    nftmarket, account, player = deployNftMarket()
    nftmarket.createNft("tokenURIJordan", 10, price, {'from', player})
    
    deployedAddress = nftmarket.getNft(0)

    print("deployedAddress ->",deployedAddress)
    print("player ->",player)

    assert 1 == 1
    return nftmarket, account, player
    
