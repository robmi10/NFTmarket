from brownie import accounts, config, NftMarketPlace, Auction

def deployNftMarket():
    account = accounts[0]
    player = accounts[1]
    buyer = accounts[2]
    nftmarket = NftMarketPlace.deploy({"from": account})
    return nftmarket, account, player, buyer

def main():
    deployNftMarket()