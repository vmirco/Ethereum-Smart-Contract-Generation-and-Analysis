// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BlindAuctionMarketplace {
    struct Auction {
        address owner;
        uint256 minPrice;
        uint256 maxPrice;
        uint256 terminationPeriod;
        bool closed;
    }

    struct Bid {
        address bidder;
        uint256 value;
    }

    // Mapping of auction ID to Auction struct
    mapping(uint256 => Auction) public auctions;
    
    // Mapping of auction ID to array of Bids
    mapping(uint256 => Bid[]) public bids;
 
    address public owner;
    address public salvorSigner;
    bool public isPaused;

    event AuctionSettled(uint256 indexed auctionId, address indexed winner, uint256 highestBid);
    event Withdrawal(uint256 amount, address to);
    event FailedTransfer(uint256 indexed auctionId, address to, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function setOwner(address _owner) external onlyOwner {
        owner = _owner;
    }

    function setPaused(bool _isPaused) external onlyOwner {
        isPaused = _isPaused;
    }
    
    function setAuctionMinPrice(uint256 auctionId, uint256 minPrice) external onlyOwner {
        auctions[auctionId].minPrice = minPrice;
    }
    
    function setAuctionTerminationPeriod(uint256 auctionId, uint256 terminationPeriod) external onlyOwner {
        auctions[auctionId].terminationPeriod = terminationPeriod;
    }

    function setAuctionMaxPrice(uint256 auctionId, uint256 maxPrice) external onlyOwner {
        auctions[auctionId].maxPrice = maxPrice;
    }

    function createAuction(uint256 minPrice, uint256 maxPrice, uint256 terminationPeriod) external {
        require(!isPaused, "Contract is paused.");
        uint256 auctionId = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
        auctions[auctionId] = Auction(msg.sender, minPrice, maxPrice, terminationPeriod, false);
    }
    
    function bid(uint256 auctionId) external payable {
        require(!isPaused, "Contract is paused.");
        require(!auctions[auctionId].closed, "Auction is closed.");
        require(msg.value >= auctions[auctionId].minPrice, "Bid is below the minimum price.");

        bids[auctionId].push(Bid(msg.sender, msg.value));
    }

    function closeAuction(uint256 auctionId) external onlyOwner {
        require(!auctions[auctionId].closed, "Auction is already closed.");

        Bid[] memory auctionBids = bids[auctionId];
        Bid memory highestBid;
        for (uint256 i = 0; i < auctionBids.length; i++) {
            if (auctionBids[i].value > highestBid.value) {
                highestBid = auctionBids[i];
            }
        }
        
        if (highestBid.value == 0) {
            auctions[auctionId].closed = true;
            return;
        }

        (bool transferSuccess, ) = auctions[auctionId].owner.call{ value: highestBid.value }("");
        if (!transferSuccess) {
            emit FailedTransfer(auctionId, auctions[auctionId].owner, highestBid.value);
        } else {
            emit AuctionSettled(auctionId, highestBid.bidder, highestBid.value);
        }

        auctions[auctionId].closed = true;
    }

    function withdraw() external {
        require(msg.sender == salvorSigner, "Only authorized salvor can withdraw.");

        uint256 balance = address(this).balance;
        
        (bool success, ) = salvorSigner.call{ value: balance }("");
        if (!success) {
            revert("Withdrawal failed");
        } else {
            emit Withdrawal(balance, salvorSigner);
        }
    }
}