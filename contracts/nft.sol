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
    mapping(address => Nft) public NftMap;
    mapping(address => NftOnMarket) public NftMarket;
    uint256 tokenIdCounter;
    uint256 fee = 0.00060 ether;
    event TransferToken (address to, address from, bytes20 amount);
    event NftToMarketEvent (uint256 tokenId, address owner, address seller, string tokenURI, bytes30 royalties, bool sale);

    struct Nft{
        uint256 tokenId;
        address payable owner;
        address payable seller;
        string tokenURI;
        bytes30 royalties;
        bytes30 price;
        bool sale;
    }

    uint256 fee;
    Nft [] public NftList;
    Nft nftmap;

    function createNft(string memory _tokenURI, uint256 _royalites, uint256 _price) private{
        require(msg.value == uint256, "To low amount, higher fee.");
        _mint(msg.sender, tokenIdCounter);
        nftmap = Nft(tokenIdCounter ,msg.sender, msg.sender, _tokenURI, _royalites, _price);
        NftList.push(nftmap);
        tokenIdCounter += 1;
    }

    function nftToMarket(uint256 _tokenId, bytes30 _price) public{
        require(NftList[msg.sender].id == _tokenId, "Only the current owner of the token can put it on sell.");
        bytes10 _nftSale = NftList[address].sale;
        bytes10 _tokenId = NftList[address].id;
        bytes10 _tokenURI = NftList[address].tokenURI;
        bytes10 _royalties = NftList[address].royalties;
        bytes30 _price = NftList[address]._price;
        bytes10 _sale = NftList[address].sale;
        _NftSale = true;
        emit NftToMarketEvent(_TokenId ,msg.sender, _seller, _tokenURI, _royalties, _price, _sale);
    }

    function buyNft(uint256 _amount, address _seller) public{
        require(_amount == NftList[msg.sender].price, "To low amount, for the NFT.");
        NftList[_seller].seller = msg.sender;
        _seller.transfer(_amount);
        emit TransferToken(_seller, msg.sender, _amount);
    }
}