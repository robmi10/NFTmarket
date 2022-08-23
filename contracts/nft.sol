//SPDX-License-Identifier: MIT
pragma solidity >=0.6.6 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NftMarketPlace is Ownable, ERC721URIStorage{
    //En funktion som minear erc271 token och ger dess token uri till en viss address;
    //En funktion som överför erc271 standarden till en annan address;
    //En funktion returnerar alla nfts i marknaden

    constructor() ERC721("RIBOL", "RBL") { }
    mapping(uint256 => Nft) public NftMap;
    
    uint256 tokenIdCounter;
    uint256 itemSoldCounter;
    uint256 fee = 0.00060 ether;
    event TransferToken (address to, address from, uint256 amount);
    event NftToMarketEvent (uint256 tokenId, address owner, address seller, string tokenURI, uint256 royalties, uint256 price, bool sale);
    

    struct Nft{
        uint256 tokenId;
        address payable owner;
        address payable seller;
        string tokenURI;
        uint256 royalties;
        uint256 price;
        bool sale;
    }


    function createNft(string memory _tokenURI, uint256 _royalites, uint256 _price) payable public{
        require(msg.value == _price, "To low amount, higher fee.");
        _mint(msg.sender, tokenIdCounter);
        NftMap[tokenIdCounter] = Nft(tokenIdCounter ,payable(msg.sender), payable(msg.sender), _tokenURI, _royalites, _price, false);
        tokenIdCounter += 1;
        itemSoldCounter += 1;
    }

    function nftToMarket(uint256 _tokenId) public{
        require(NftMap[_tokenId].owner == msg.sender, "Only the current owner of the token can put it on sell.");
        uint256 _userTokenId = NftMap[_tokenId].tokenId;
        address _seller = NftMap[_tokenId].seller;
        string memory _tokenURI = NftMap[_tokenId].tokenURI;
        uint256 _royalties = NftMap[_tokenId].royalties;
        uint256 _userPrice = NftMap[_tokenId].price;
        bool _sale = NftMap[_tokenId].sale;
        _sale = true;
        itemSoldCounter -= 1;
        emit NftToMarketEvent(_userTokenId ,msg.sender, _seller, _tokenURI, _royalties, _userPrice, _sale);
    }

    function buyNft(uint256 _tokenId, uint256 _amount, address payable _seller) public{
        require(_amount == NftMap[_tokenId].price, "To low amount, for the NFT.");
        NftMap[_tokenId].seller = _seller;
        _seller.transfer(_amount);
        emit TransferToken(_seller, msg.sender, _amount);
    }

   
    //return all nfts on sale
    function getAllNfts() public view returns(Nft[] memory ){
            //fetch all nfts!
            uint256 tokenOnSaleCounter = tokenIdCounter - itemSoldCounter;
            uint256 thisIndex = 0;
            Nft[] memory items = new Nft[](tokenOnSaleCounter);
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

    function getNft (uint256 _id) public view returns(address){
        return NftMap[_id].owner;
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
}