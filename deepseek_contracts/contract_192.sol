// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MaltArbitration {
    struct Auction {
        address seller;
        uint256 startingPrice;
        uint256 currentBid;
        address currentBidder;
        uint256 endTime;
        bool isActive;
    }

    Auction[] public auctions;
    mapping(address => uint256) public commitments;
    mapping(address => uint256) public rewards;

    event AuctionCreated(uint256 auctionId, address seller, uint256 startingPrice, uint256 endTime);
    event BidPlaced(uint256 auctionId, address bidder, uint256 bidAmount);
    event AuctionClosed(uint256 auctionId, address winner, uint256 winningBid);
    event RewardAllocated(address arbitrator, uint256 amount);

    modifier onlyActiveAuction(uint256 _auctionId) {
        require(auctions[_auctionId].isActive, "Auction is not active");
        _;
    }

    function createAuction(uint256 _startingPrice, uint256 _duration) external {
        uint256 endTime = block.timestamp + _duration;
        Auction memory newAuction = Auction({
            seller: msg.sender,
            startingPrice: _startingPrice,
            currentBid: 0,
            currentBidder: address(0),
            endTime: endTime,
            isActive: true
        });
        uint256 auctionId = auctions.length;
        auctions.push(newAuction);
        emit AuctionCreated(auctionId, msg.sender, _startingPrice, endTime);
    }

    function placeBid(uint256 _auctionId) external payable onlyActiveAuction(_auctionId) {
        Auction storage auction = auctions[_auctionId];
        require(block.timestamp < auction.endTime, "Auction has ended");
        require(msg.value > auction.currentBid, "Bid must be higher than current bid");

        if (auction.currentBidder != address(0)) {
            commitments[auction.currentBidder] += auction.currentBid;
        }

        auction.currentBid = msg.value;
        auction.currentBidder = msg.sender;
        emit BidPlaced(_auctionId, msg.sender, msg.value);
    }

    function closeAuction(uint256 _auctionId) external onlyActiveAuction(_auctionId) {
        Auction storage auction = auctions[_auctionId];
        require(block.timestamp >= auction.endTime, "Auction has not ended yet");

        auction.isActive = false;
        if (auction.currentBidder != address(0)) {
            rewards[auction.seller] += auction.currentBid;
            emit AuctionClosed(_auctionId, auction.currentBidder, auction.currentBid);
        } else {
            emit AuctionClosed(_auctionId, address(0), 0);
        }
    }

    function allocateReward(address _arbitrator, uint256 _amount) external {
        require(_amount <= rewards[_arbitrator], "Not enough rewards available");
        rewards[_arbitrator] -= _amount;
        (bool success, ) = _arbitrator.call{value: _amount}("");
        require(success, "Transfer failed");
        emit RewardAllocated(_arbitrator, _amount);
    }

    function withdrawCommitment() external {
        uint256 amount = commitments[msg.sender];
        require(amount > 0, "No commitment to withdraw");
        commitments[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

    receive() external payable {}
}