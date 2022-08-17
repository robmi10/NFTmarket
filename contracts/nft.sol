//SPDX-License-Identifier: MIT
pragma solidity >=0.6.6 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NftMarketPlace is Ownable, ERC721URIStorage{

    //En funktion som minear erc271 token och ger dess token uri till en viss address;
    //En funktion som överför erc271 standarden till en annan address;
    //En funktion returnerar alla nfts i marknaden
    constructor() ERC721("RIBOL", "RBL") { }

    mapping(address => Nft) public NftMap;
    uint256 tokenId;

    struct Nft{
        uint256 id;
        address userNftAddress;
        string tokenURI;
    }
    uint256 fee;
    Nft [] public NftList;
  
    Nft nftmap;
    function MintNft(string memory _tokenURI) public{
        _mint(msg.sender, tokenId);
        nftmap = Nft(tokenId ,msg.sender, _tokenURI);
        NftList.push(nftmap);
        tokenId += 1;
    }

    function TransferNft(address _to, uint256 _tokenId) public{
        NftList[tokenId] = _to;
        
    }

}