// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BlindAuctionMarketplace {
    address public owner;
    address public salvorSigner;
    bool public paused;

    struct Auction {
        address seller;
        uint256 minPrice;
        uint256 maxPrice;
        uint256 terminationPeriod;
        bool settled;
        mapping(address => uint256) offers;
    }

    mapping(uint256 => Auction) public auctions;
    uint256 public auctionCount;

    event AuctionCreated(uint256 indexed auctionId, address indexed seller, uint256 minPrice, uint256 maxPrice, uint256 terminationPeriod);
    event OfferMade(uint256 indexed auctionId, address indexed bidder, uint256 amount);
    event AuctionSettled(uint256 indexed auctionId, address indexed winner, uint256 amount);
    event FundsWithdrawn(address indexed user, uint256 amount);
    event TransferFailed(address indexed from, address indexed to, uint256 amount);
    event SettingsUpdated(address indexed newSalvorSigner, bool newPausedState);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    constructor() {
        owner = msg.sender;
        salvorSigner = msg.sender;
        paused = false;
    }

    function createAuction(uint256 _minPrice, uint256 _maxPrice, uint256 _terminationPeriod) external whenNotPaused {
        require(_minPrice < _maxPrice, "Min price must be less than max price");
        require(_terminationPeriod > 0, "Termination period must be greater than 0");

        uint256 auctionId = ++auctionCount;
        Auction storage auction = auctions[auctionId];
        auction.seller = msg.sender;
        auction.minPrice = _minPrice;
        auction.maxPrice = _maxPrice;
        auction.terminationPeriod = _terminationPeriod;
        auction.settled = false;

        emit AuctionCreated(auctionId, msg.sender, _minPrice, _maxPrice, _terminationPeriod);
    }

    function makeOffer(uint256 _auctionId, uint256 _amount) external payable whenNotPaused {
        Auction storage auction = auctions[_auctionId];
        require(!auction.settled, "Auction is settled");
        require(_amount >= auction.minPrice && _amount <= auction.maxPrice, "Offer out of price range");

        auction.offers[msg.sender] = _amount;
        emit OfferMade(_auctionId, msg.sender, _amount);
    }

    function settleAuction(uint256 _auctionId) external {
        Auction storage auction = auctions[_auctionId];
        require(!auction.settled, "Auction is already settled");
        require(block.timestamp >= auction.terminationPeriod, "Auction termination period not reached");

        address winner = address(0);
        uint256 highestOffer = 0;
        for (uint256 i = 0; i < auctionCount; i++) {
            if (auction.offers[address(i)] > highestOffer) {
                highestOffer = auction.offers[address(i)];
                winner = address(i);
            }
        }

        if (winner != address(0)) {
            auction.settled = true;
            (bool success, ) = auction.seller.call{value: highestOffer}("");
            if (!success) {
                emit TransferFailed(winner, auction.seller, highestOffer);
            } else {
                emit AuctionSettled(_auctionId, winner, highestOffer);
            }
        }
    }

    function withdrawFunds(uint256 _amount) external {
        require(_amount <= address(this).balance, "Insufficient contract balance");
        (bool success, ) = msg.sender.call{value: _amount}("");
        if (!success) {
            emit TransferFailed(address(this), msg.sender, _amount);
        } else {
            emit FundsWithdrawn(msg.sender, _amount);
        }
    }

    function updateSettings(address _newSalvorSigner, bool _newPausedState) external onlyOwner {
        salvorSigner = _newSalvorSigner;
        paused = _newPausedState;
        emit SettingsUpdated(_newSalvorSigner, _newPausedState);
    }

    receive() external payable {}
}