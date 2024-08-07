// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MaltArbitration {
    struct Auction {
        uint256 id;
        uint256 startTime;
        uint256 endTime;
        uint256 commitment;
        address highestBidder;
        uint256 highestBid;
        bool ended;
    }

    Auction[] public auctions;
    mapping(uint256 => mapping(address => uint256)) public bids;
    mapping(address => uint256) public pendingReturns;
    uint256 public auctionCount;

    event AuctionCreated(uint256 auctionId, uint256 startTime, uint256 endTime, uint256 commitment);
    event BidPlaced(uint256 auctionId, address bidder, uint256 amount);
    event AuctionEnded(uint256 auctionId, address winner, uint256 amount);
    event Withdrawal(address bidder, uint256 amount);

    function createAuction(uint256 _commitment, uint256 _duration) public {
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + _duration;
        uint256 auctionId = auctionCount++;
        auctions.push(Auction({
            id: auctionId,
            startTime: startTime,
            endTime: endTime,
            commitment: _commitment,
            highestBidder: address(0),
            highestBid: 0,
            ended: false
        }));
        emit AuctionCreated(auctionId, startTime, endTime, _commitment);
    }

    function bid(uint256 _auctionId) public payable {
        Auction storage auction = auctions[_auctionId];
        require(block.timestamp >= auction.startTime && block.timestamp <= auction.endTime, "Auction not active");
        require(msg.value > auction.highestBid, "Bid must be higher than current highest bid");

        if (auction.highestBid != 0) {
            pendingReturns[auction.highestBidder] += auction.highestBid;
        }

        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;
        bids[_auctionId][msg.sender] = msg.value;
        emit BidPlaced(_auctionId, msg.sender, msg.value);
    }

    function endAuction(uint256 _auctionId) public {
        Auction storage auction = auctions[_auctionId];
        require(block.timestamp >= auction.endTime, "Auction not yet ended");
        require(!auction.ended, "Auction end has already been called");

        auction.ended = true;
        emit AuctionEnded(_auctionId, auction.highestBidder, auction.highestBid);
    }

    function withdraw() public returns (bool) {
        uint256 amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            (bool success, ) = msg.sender.call{value: amount}("");
            require(success, "Transfer failed");
            emit Withdrawal(msg.sender, amount);
        }
        return true;
    }

    receive() external payable {}
}