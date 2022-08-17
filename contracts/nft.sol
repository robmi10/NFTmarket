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
        bool sale;
    }


    uint256 fee;
    Nft [] public NftList;
  
    Nft nftmap;
    function createNft(string memory _tokenURI, uint256 _royalites) private{
        _mint(msg.sender, tokenIdCounter);
        nftmap = Nft(tokenIdCounter ,msg.sender, msg.sender, _tokenURI, _royalites);
        NftList.push(nftmap);
        tokenIdCounter += 1;
    }

    function nftToMarket(address _seller) public{
        require(msg.value == uint256, "To low amount, higher fee.");
        bytes10 _nftSale = NftList[address].sale;
        bytes10 _tokenId = NftList[address].id;
        bytes10 _tokenURI = NftList[address].tokenURI;
        bytes10 _royalties = NftList[address].royalties;
        bytes10 _sale = NftList[address].sale;
        _NftSale = true;
        emit NftToMarketEvent(_TokenId ,msg.sender, _seller, _tokenURI, _royalties, _sale);
    }

    function transferNft(address _to, uint256 _tokenId, bytes20 _amount) public{
        //transfer amount to nft token!
        NftList[tokenId] = _to;
        emit TransferToken(_to, msg.sender, _amount);
    }

}