//SPDX-License-Identifier: MIT
pragma solidity >=0.6.6 <0.9.0;
//Create a smart contract that keeps an eye of a created auction!

interface IERC721 {
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) external;

    function transferFrom(
        address,
        address,
        uint
    ) external;
}

contract Auction{

    IERC721 public nft;
    uint256 public auctionCounter;
    uint256 public nftId;

    event auctionStartedEvent(address _bidder, uint256 _amount, uint256 _id);
    event bidEvent(address _bidder, uint256 _amount, uint256 _id);
    event widthdrawEvent(address _bidder, uint256 _amount, uint256 _id);
    event EndEvent(address _bidder, uint256 _amount, uint256 _id);
  
    mapping(address => uint256) public bidMap;

    address payable seller;
    bool public auctionStarted;
    uint256 auctionId;
    uint256 duration;
    uint256 bid;
    bool ended;
    address public bidder;

    constructor(address _nft, uint256 _nftId, uint256 _startingBid, uint256 _duration){
        nft = IERC721(_nft);
        nftId = _nftId;
        seller = payable (msg.sender);
        bid = _startingBid;
        duration = _duration;
    }

    //func start auction;
    function startAuction () public  {
        require(!auctionStarted, "auction started");
        require(msg.sender != seller, "not the seller");

        nft.transferFrom(msg.sender, address(this), nftId);
        auctionStarted = true;
        duration = block.timestamp + duration;
        emit auctionStartedEvent(msg.sender, bid, nftId);
    }
    //func put bid on auction
    function putBid() external payable {
        require(auctionStarted, "Not started.");
        require(block.timestamp < duration, "already ended.");
        require(msg.value > bid, "To low start bid.");
        bidder = msg.sender;
        bid = msg.value;
        if(bidder != address(0)){
            bidMap[bidder] += bid;
        }
        emit bidEvent(bidder, bid, nftId);
    }    
    //func check highest big on auction and if its already ended

    function widthdraw() external{
        uint256 balance = bidMap[bidder];
        bidMap[bidder] = 0;
        payable(msg.sender).transfer(balance);        
        emit widthdrawEvent(msg.sender, balance, nftId);
    }

    function end() external{
        require(auctionStarted, "not started");
        require(block.timestamp >= duration, "duration is over");
        require(!ended, "it's not ended");

        ended = true;
        if(bidder != address(0)){
            nft.transferFrom(address(this), bidder, nftId);
            seller.transfer(bid);
        }else{
            nft.transferFrom(address(this), seller, nftId);
        }
        emit EndEvent(msg.sender, bid, nftId);
    }
}