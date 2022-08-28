from brownie import accounts, config, NftMarketPlace, Auction

def deployNftMarket():
    account = accounts[0]
    player = accounts[1]
    buyer = accounts[2]
    secondBuyer = accounts[3]
    auctionSeller = accounts[4]
    auctionBuyer = accounts[5]
    auctionHigherBid = accounts[6]

    nftmarket = NftMarketPlace.deploy({"from": account})
    auction = Auction.deploy({"from": account})
    return nftmarket, account, player, buyer, secondBuyer, auction, auctionSeller, auctionBuyer, auctionHigherBid

def main():
    deployNftMarket()