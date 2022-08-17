//SPDX-License-Identifier: MIT
pragma solidity >=0.6.6 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NftToken is ERC721{
    constructor () ERC721("NFTMint", "NTM"){
        
    }
}