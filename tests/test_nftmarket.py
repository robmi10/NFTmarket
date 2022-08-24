from scripts.deploy import deployNftMarket
from web3 import Web3
fee = Web3.toWei(0.00060, "ether")
price = Web3.toWei(2, "ether")

def testCreateNft():
    #create NFT
    nftmarket, account, player, buyer = deployNftMarket()
    createNFT = nftmarket.createNft("tokenURIJordan", 10, price, {'value': fee, 'from': player}, )
    deployedAddress = nftmarket.getNft(0)

    #put nft to NFT market
    nftmarket.nftToMarket(0, {'from': player})
    nftOnSale = nftmarket.getNftOnSale(0, {'from': player})

    assert player == deployedAddress
    assert nftOnSale == True
    return nftmarket, buyer, player

def testBuyNft():
    nftmarket, buyer, player = testCreateNft() 
    #test buying nft
    nftmarket.getNftOnSeller(0)
    nftmarket.buyNft(0, buyer, player, {'value': price, 'from': buyer })
    getNewSeller = nftmarket.getNftOnSeller(0)
    
    print("buyNft events ->", getNewSeller.events)
    assert 1 == 3

