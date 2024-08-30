// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract AuctionArbitration {

    struct Auction {
        uint auctionId;
        address payable seller;
        uint startTime;
        uint endTime;
        uint highestBid;
        address payable highestBidder;
        bool active;
    }

    struct Arbiter {
        address payable addr;
        bool isArbiter;
    }

    uint public auctionCount;
    mapping(uint => Auction) public auctions;
    mapping(address => Arbiter) public arbiters;

    event AuctionInitiated(uint auctionId, address seller, uint startTime, uint endTime);
    event NewBid(uint auctionId, address bidder, uint bidAmount);
    event AuctionEnded(uint auctionId, address winner, uint winningBid);
    event RewardsAllocated(uint auctionId, address winner, uint winningBid, address arbiter, uint arbiterReward);

    modifier onlyArbiter() {
        require(arbiters[msg.sender].isArbiter == true, "Must be an arbiter to invoke this function");
        _;
    }

    modifier auctionExists(uint _auctionId) {
        require(auctions[_auctionId].active == true, "Auction does not exist");
        _;
    }

    function initiateAuction(uint _endTime) public returns(uint) {
        auctionCount++;
        auctions[auctionCount] = Auction(auctionCount, payable(msg.sender), block.timestamp, _endTime, 0, payable(address(0)), true);
        emit AuctionInitiated(auctionCount, msg.sender, block.timestamp, _endTime);
        return auctionCount;
    }

    function bid(uint _auctionId) public payable auctionExists(_auctionId){
        require(block.timestamp < auctions[_auctionId].endTime, "Auction ended already");
        require(msg.value > auctions[_auctionId].highestBid, "Bid should be higher than current highest bid");

        if(auctions[_auctionId].highestBid != 0){
            auctions[_auctionId].highestBidder.transfer(auctions[_auctionId].highestBid);
        }

        auctions[_auctionId].highestBid = msg.value;
        auctions[_auctionId].highestBidder = payable(msg.sender);
        emit NewBid(_auctionId, msg.sender, msg.value);
    }

    function endAuction(uint _auctionId) public onlyArbiter auctionExists(_auctionId) {
        require(block.timestamp >= auctions[_auctionId].endTime, "Auction is not yet over");
        auctions[_auctionId].active = false;
        emit AuctionEnded(_auctionId, auctions[_auctionId].highestBidder, auctions[_auctionId].highestBid);
    }

    function allocateRewards(uint _auctionId, uint _arbiterRewardPercentage) public onlyArbiter auctionExists(_auctionId) {
        require(_arbiterRewardPercentage >= 0 && _arbiterRewardPercentage <= 100, "Invalid arbiter reward percentage");
        require(auctions[_auctionId].active == false, "Auction is still active, cannot calculate rewards");

        uint arbiterReward = (auctions[_auctionId].highestBid * _arbiterRewardPercentage) / 100;
        uint sellerRevenue = auctions[_auctionId].highestBid - arbiterReward;

        auctions[_auctionId].seller.transfer(sellerRevenue);
        arbiters[msg.sender].addr.transfer(arbiterReward);

        emit RewardsAllocated(_auctionId, auctions[_auctionId].highestBidder, auctions[_auctionId].highestBid, msg.sender, arbiterReward);
    }

    function addArbiter(address _arbiterAddress) public {
        require(arbiters[_arbiterAddress].isArbiter == false, "Address is already an arbiter");
        arbiters[_arbiterAddress] = Arbiter(payable(_arbiterAddress), true);
    }
}