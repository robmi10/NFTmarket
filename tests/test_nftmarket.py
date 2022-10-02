from scripts.deploy import deployNftMarket
from web3 import Web3
import time

fee = Web3.toWei(0.00060, "ether")
price = Web3.toWei(2, "ether")
secondPrice = Web3.toWei(4, "ether")
thirdPrice = Web3.toWei(20, "ether")
startingBid = Web3.toWei(2, "ether")
playerBid = Web3.toWei(3, "ether")
newplayerBid = Web3.toWei(9, "ether")
duration = 2 #1 week in seconds

def testCreateNft():
    #create NFT
    nftmarket, account, player, buyer, secondBuyer, auction, auctionSeller, auctionBuyer, auctionHigherBid = deployNftMarket()
    nftToMarket = nftmarket.createNft("tokenURIJordan", 10, {'value': fee, 'from': player}, )
    deployedAddress = nftmarket.getNft(0)


    print("nftmarket.events -->",nftToMarket.events)
    #put nft to NFT market
    nftmarket.nftToMarket(0, price, {'from': player})
    nftOnSale = nftmarket.getNftOnSale(0,{'from': player})

    assert player == deployedAddress
    assert nftOnSale == True
    return nftmarket, buyer, player, account, secondBuyer, auction, auctionSeller, auctionBuyer, auctionHigherBid

def testBuyNft():
    #test buying nft
    nftmarket, buyer, player, account, secondBuyer, auction, auctionSeller, auctionBuyer, auctionHigherBid = testCreateNft() 
    #first buy of the nft
    nftmarket.buyNft(0, buyer, player, {'value': price, 'from': buyer })
    #new owner put nft on sale
    nftmarket.nftToMarket(0, secondPrice, {'from': buyer})
    #new buyer sale of the same nft
    preOwnerBalance = player.balance()
    nftmarket.buyNft(0, secondBuyer, buyer, {'value': secondPrice, 'from': secondBuyer })

    postOwnerBalance = player.balance()
    newNftSeller = nftmarket.getNftOnSeller(0)
    #check new seller of nft and royalties to the owner
    assert newNftSeller == secondBuyer
    assert postOwnerBalance == preOwnerBalance + secondPrice / 100 * 10

def testAuctionNft():
    nftmarket, buyer, player, account, secondBuyer, auction, auctionSeller, auctionBuyer, auctionHigherBid = testCreateNft()
    auction.startAuction(0, duration, {'value': startingBid, 'from': auctionSeller})
    firstBidderPreBidBalance = auctionBuyer.balance()
    auction.putBid(0, {'value': playerBid, 'from': auctionBuyer})
    auction.putBid(0, {'value': newplayerBid, 'from': auctionHigherBid})
    currentHigherBid = auction.getAuctionBidder(0)

    nftmarket.createNft("tokenURIEdwards", 30, {'value': fee, 'from': auctionBuyer}, )
    nftmarket.nftToMarket(1, thirdPrice, {'from': auctionBuyer})
    nftmarket.getNftOnSale(1,{'from': auctionBuyer})

    allNftsOnSale = nftmarket.getAllNfts()
    print("allNftsOnSale ->", allNftsOnSale)

    time.sleep(3)
    auction.end(0)
    auction.widthdraw({'from': auctionBuyer})
    firstBidderWidthdraw = auctionBuyer.balance()

    print("get my nfts ->", nftmarket.getMyNfts({'from': auctionBuyer}))

    #test winner, and widthdraw funciton.
    assert currentHigherBid == auctionHigherBid
    assert firstBidderPreBidBalance == firstBidderWidthdraw
    assert 1 == 2



