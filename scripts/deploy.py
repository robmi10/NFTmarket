from brownie import accounts, config, NftMarketPlace, Auction
import yaml
import json
import os
import shutil

def deployNftMarket():
    # account = accounts[0]
    # player = accounts[1]
    # buyer = accounts[2]
    # secondBuyer = accounts[3]
    # auctionSeller = accounts[4]
    # auctionBuyer = accounts[5]
    # auctionHigherBid = accounts[6]

    account = accounts.add(config['wallets']["from_key"])
    nftmarket = NftMarketPlace.deploy({"from": account})
    auction = Auction.deploy({"from": account})

    return nftmarket, auction
    #return nftmarket, account, player, buyer, secondBuyer, auction, auctionSeller, auctionBuyer, auctionHigherBid

def update_front_end():
    copy_folder_to_frontend("./build", "../GameDapp/game-dapp/src/chain-info")
    with open("brownie-config.yaml", "r") as brownie_config:
        config_dict = yaml.load(brownie_config, Loader=yaml.FullLoader)
        with open("../NFTMARKET/nftmarket/brownie-config.json", "w") as brownie_config_json:
            json.dump(config_dict, brownie_config_json)
        print("Front end updated")

def copy_folder_to_frontend(src, dest):
    if os.path.exists(dest):
        shutil.rmtree(dest)
    shutil.copytree(src, dest)

def main():
    deployNftMarket()