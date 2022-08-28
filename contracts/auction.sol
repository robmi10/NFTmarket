//SPDX-License-Identifier: MIT
pragma solidity >=0.6.6 <0.9.0;
//Create a smart contract that keeps an eye of a created auction!


contract Auction{
    uint256 public auctionCounter;
    uint256 public nftId;

    event auctionStartedEvent(address _bidder, uint256 _amount, uint256 _id);
    event bidEvent(address _bidder, uint256 _amount, uint256 _id);
    event widthdrawEvent(address _bidder, uint256 _amount, uint256 _id);
    event EndEvent(address _bidder, uint256 _amount, uint256 _id);
  
    mapping(address => uint256) public bidMap;

    mapping(uint256 => Auctions) public AuctionMap;
    
    struct Auctions{
        address payable seller;
        bool auctionStarted;
        uint256 auctionId;
        uint256 nftTokenId;
        uint256 duration;
        uint256 bid;
        bool ended;
        address bidder;
    }

    function startAuction (uint256 _nftTokenId, uint256 _duration) public payable {
        AuctionMap[auctionCounter] = Auctions(payable (msg.sender), true, auctionCounter, _nftTokenId, block.timestamp + _duration, msg.value, false,  msg.sender);
        auctionCounter += 1;
        emit auctionStartedEvent(msg.sender, msg.value, _nftTokenId);
    }
    //func put bid on auction
    function putBid(uint256 _id) external payable {
        require(AuctionMap[_id].auctionStarted, "Not started.");
        require(block.timestamp > AuctionMap[auctionCounter].duration, "already ended.");
        require(msg.value > AuctionMap[auctionCounter].bid, "To low start bid.");
        AuctionMap[_id].bidder = msg.sender;
        AuctionMap[_id].bid = msg.value;
    
        if(msg.sender != address(0)){
            bidMap[msg.sender] += msg.value;
        }
        emit bidEvent(msg.sender, msg.value, nftId);
    }
    //func check highest big on auction and if its already ended
    function widthdraw() external{
        uint256 bid = bidMap[msg.sender];
        bidMap[msg.sender] = 0;
        payable(msg.sender).transfer(bid);        
        emit widthdrawEvent(msg.sender, bid, nftId);
    }

    function end(uint256 _id) external{
        require(AuctionMap[_id].auctionStarted, "not started");
        require(block.timestamp > AuctionMap[_id].duration, "duration is not over");
        require(!AuctionMap[_id].ended, "it's not ended");
        address bidder = AuctionMap[_id].bidder;
        uint256 bid = AuctionMap[_id].bid;
        AuctionMap[_id].ended = true;
        if(bidder != address(0)){
           // nft.transferFrom(address(this), bidder, nftId);
            AuctionMap[_id].seller.transfer(bid);
        }
        emit EndEvent(msg.sender, bid, nftId);
    }

    function getAlltAuctions() public view returns(Auctions [] memory){
        Auctions[] memory allAuctions = new Auctions[](auctionCounter);
        for(uint256 i = 0; i <= auctionCounter; i++){
            Auctions storage auctionItem = AuctionMap[i];
            allAuctions[i] = auctionItem;
        }
        return allAuctions;
    }

    function getDurationTime (uint256 _id) public view returns(uint256){
        return AuctionMap[_id].duration;
    }

    function getAuctionBidder (uint256 _id) public view returns(address){
        return AuctionMap[_id].bidder;
    }

    function getAuctionStatus (uint256 _id) public view returns(bool){
        return AuctionMap[_id].ended;
    }

    function getNftTokenId (uint256 _id) public view returns(uint256){
        return AuctionMap[_id].nftTokenId;
    }

    function getNftTokenBid (uint256 _id) public view returns(uint256){
        return AuctionMap[_id].bid;
    }
    
}