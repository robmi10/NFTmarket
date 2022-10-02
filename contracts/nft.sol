//SPDX-License-Identifier: MIT
pragma solidity >=0.6.6 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./auction.sol";

contract NftMarketPlace is Ownable, ERC721URIStorage, Auction{
    //En funktion som minear erc271 token och ger dess token uri till en viss address;
    //En funktion som överför erc271 standarden till en annan address;
    //En funktion returnerar alla nfts i marknaden

    constructor() ERC721("RIBOL", "RBL") { }
  
    mapping(uint256 => Nft) public NftMap;
    
    uint256 tokenIdCounter;
    uint256 fee = 0.00060 ether;
    event TransferToken (address to, address from, uint256 amount, uint256 royalty, uint256 id);
    event AuctionTransferWinner (address to, address from, uint256 amount, uint256 id);
    event NftToMarketEvent (uint256 tokenId, address owner, address seller, string tokenURI, uint256 royalties, uint256 price, bool sale);
    event NftCreatedMarket (uint256 tokenId, address owner, address seller, string tokenURI, uint256 royalties, bool sale);

    struct Nft{
        uint256 tokenId;
        address payable owner;
        address payable seller;
        string tokenURI;
        uint256 royalties;
        uint256 price;
        bool sale;
    }

    function createNft(string memory _tokenURI, uint256 _royalites) payable public{
        require(msg.value == fee, "To low amount, higher fee.");
        _mint(msg.sender, tokenIdCounter);
        NftMap[tokenIdCounter] = Nft(tokenIdCounter ,payable(msg.sender), payable(msg.sender), _tokenURI, _royalites, 0, false);
        emit NftCreatedMarket(tokenIdCounter, payable(msg.sender), payable(msg.sender), _tokenURI, _royalites, false);
        tokenIdCounter += 1;
    }

    function nftToMarket(uint256 _tokenId, uint256 _price) public{
        require(NftMap[_tokenId].seller == msg.sender, "Only the current owner of the token can put it on sell.");
        uint256 _userTokenId = NftMap[_tokenId].tokenId;
        address _seller = NftMap[_tokenId].seller;
        string memory _tokenURI = NftMap[_tokenId].tokenURI;
        uint256 _royalties = NftMap[_tokenId].royalties;
        uint256 _userPrice = NftMap[_tokenId].price = _price;
        bool _sale = NftMap[_tokenId].sale = true;
        emit NftToMarketEvent(_userTokenId ,msg.sender, _seller, _tokenURI, _royalties, _userPrice, _sale);
    }

      function nftToMarketAuction(uint256 _tokenId, uint256 _price) public{
        require(NftMap[_tokenId].seller == msg.sender, "Only the current owner of the token can put it on sell.");
        uint256 _userTokenId = NftMap[_tokenId].tokenId;
        address _seller = NftMap[_tokenId].seller;
        string memory _tokenURI = NftMap[_tokenId].tokenURI;
        uint256 _royalties = NftMap[_tokenId].royalties;
        uint256 _userPrice = NftMap[_tokenId].price = _price;
        bool _sale = NftMap[_tokenId].sale = true;
        emit NftToMarketEvent(_userTokenId ,msg.sender, _seller, _tokenURI, _royalties, _userPrice, _sale);
    }
    
    function buyNft(uint256 _tokenId, address payable _seller, address payable _currentOwner) payable public{
        require(msg.value == NftMap[_tokenId].price, "To low amount, for the NFT.");
        require(NftMap[_tokenId].sale, "Its not for sale.");
        uint256 royaltyAmount;

        NftMap[_tokenId].seller = _seller;
        if(NftMap[_tokenId].royalties > 0){
        royaltyAmount = msg.value / 100 * NftMap[_tokenId].royalties;
        payable(NftMap[_tokenId].owner).transfer(royaltyAmount); 
        }

        payable(_currentOwner).transfer(msg.value - royaltyAmount);
        NftMap[_tokenId].sale = false;
        emit TransferToken(NftMap[_tokenId].owner, _seller, msg.value, royaltyAmount, _tokenId);
    }

    function getAuctionTime (uint256 _id) public view returns(uint256){
        super.getDurationTime(_id);
    }

    function getAuctionWinner (uint256 _id) public view returns(address){
        super.getAuctionBidder(_id);
    }

    function getAuctionNftId (uint256 _id) public view returns(uint256){
        super.getNftTokenId(_id);
    }

    function getAuctionNftBid(uint256 _id) public view returns(uint256){
        super.getNftTokenBid(_id);
    }

    function auctionWinner (uint256 _id) payable public{
        uint256 _time = getAuctionTime(_id);
        address _auctionBidder = getAuctionWinner(_id);
        uint256 nftTokenId = getAuctionNftId(_id);
        uint256 amount = getAuctionNftBid(_id);
        require(block.timestamp > _time);
        NftMap[nftTokenId].seller = payable(_auctionBidder);
        emit AuctionTransferWinner(NftMap[nftTokenId].owner,msg.sender, amount, _id);
    }

    //return all nfts on sale
    function getAllNfts() public view returns(Nft[] memory ){
            //fetch all nfts!
            uint256 thisIndex = 0;
            Nft[] memory items = new Nft[](tokenIdCounter);
            for(uint256 i = 0; i < tokenIdCounter; i++){  
                if(NftMap[i].sale){
                    Nft storage thisItem = NftMap[i];
                    items[thisIndex] = thisItem;
                    thisIndex += 1;
                }
            }
            return items;
    }

    //return only my portfolio nfts
    function getMyNfts () public view returns(Nft[] memory){
        //only fetch my nfts!
        uint256 itemCount = 0;
        for(uint256 i = 0; i <= tokenIdCounter; i++){
            if(NftMap[i].owner == msg.sender){
                itemCount += 1;
            }
        }
        uint256 thisIndex = 0;
        Nft[] memory items = new Nft[](itemCount);
        for(uint256 i = 0; i <= tokenIdCounter; i++){
            if(NftMap[i].owner == msg.sender){
                Nft storage thisItems = NftMap[i];
                items[thisIndex] = thisItems; 
                thisIndex += 1;
            }
        }
        return items;

    }

    //returns my listed Nfts
    function getMyNftsOnSale () public view returns(Nft[] memory){
        //only fetch my nfts!
        uint256 itemCount = 0;
        uint256 thisIndex = 0;

        for(uint256 i = 0; i <= tokenIdCounter; i++){
            if(NftMap[i].seller == msg.sender){
                itemCount += 1;
            }
        }
        Nft[] memory items = new Nft[](itemCount);
        for(uint256 i = 0; i <= tokenIdCounter; i++){
            if(NftMap[i].seller == msg.sender && NftMap[i].sale){
                Nft storage thisItems = NftMap[i];
                items[thisIndex] = thisItems; 
                thisIndex += 1;
            }
        }
        return items;
        }


    function getNft (uint256 _id) public view returns(address){
        return NftMap[_id].owner;
    }

    function getNftOnSale (uint256 _id) public view returns(bool){
        return NftMap[_id].sale;
    }

     function getNftOnSeller (uint256 _id) public view returns(address){
        return NftMap[_id].seller;
    }

    function getNftOnOwner (uint256 _id) public view returns(address){
        return NftMap[_id].owner;
    }
}