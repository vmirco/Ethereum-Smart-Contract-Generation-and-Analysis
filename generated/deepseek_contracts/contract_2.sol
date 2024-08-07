// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BlindAuctionMarketplace {
    address public owner;
    bool public paused;
    address public salvorSigner;

    struct Auction {
        address seller;
        uint256 minPrice;
        uint256 maxPrice;
        uint256 terminationPeriod;
        uint256 startTime;
        uint256 endTime;
        bool settled;
    }

    struct Offer {
        address bidder;
        uint256 amount;
        bool filled;
    }

    Auction[] public auctions;
    mapping(uint256 => Offer[]) public auctionOffers;
    mapping(address => uint256) public balances;

    event AuctionCreated(uint256 indexed auctionId, address indexed seller);
    event OfferMade(uint256 indexed auctionId, address indexed bidder, uint256 amount);
    event AuctionFilled(uint256 indexed auctionId, address indexed bidder, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event TransferFailed(address indexed from, address indexed to, uint256 amount);
    event SettingsUpdated(address indexed owner);

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
        paused = false;
        salvorSigner = msg.sender;
    }

    function createAuction(uint256 _minPrice, uint256 _maxPrice, uint256 _terminationPeriod) external whenNotPaused {
        require(_minPrice > 0, "Min price must be greater than 0");
        require(_maxPrice > _minPrice, "Max price must be greater than min price");
        require(_terminationPeriod > 0, "Termination period must be greater than 0");

        Auction memory newAuction = Auction({
            seller: msg.sender,
            minPrice: _minPrice,
            maxPrice: _maxPrice,
            terminationPeriod: _terminationPeriod,
            startTime: block.timestamp,
            endTime: block.timestamp + _terminationPeriod,
            settled: false
        });

        auctions.push(newAuction);
        emit AuctionCreated(auctions.length - 1, msg.sender);
    }

    function makeOffer(uint256 _auctionId, uint256 _amount) external payable whenNotPaused {
        require(_auctionId < auctions.length, "Invalid auction ID");
        Auction storage auction = auctions[_auctionId];
        require(!auction.settled, "Auction already settled");
        require(block.timestamp < auction.endTime, "Auction has ended");
        require(_amount >= auction.minPrice && _amount <= auction.maxPrice, "Offer out of price range");

        Offer memory newOffer = Offer({
            bidder: msg.sender,
            amount: _amount,
            filled: false
        });

        auctionOffers[_auctionId].push(newOffer);
        emit OfferMade(_auctionId, msg.sender, _amount);
    }

    function fillAuction(uint256 _auctionId, uint256 _offerIndex) external whenNotPaused {
        require(_auctionId < auctions.length, "Invalid auction ID");
        Auction storage auction = auctions[_auctionId];
        require(!auction.settled, "Auction already settled");
        require(block.timestamp >= auction.endTime, "Auction has not ended");
        require(_offerIndex < auctionOffers[_auctionId].length, "Invalid offer index");

        Offer storage offer = auctionOffers[_auctionId][_offerIndex];
        require(!offer.filled, "Offer already filled");

        offer.filled = true;
        auction.settled = true;
        balances[auction.seller] += offer.amount;

        emit AuctionFilled(_auctionId, offer.bidder, offer.amount);
    }

    function withdraw(uint256 _amount) external {
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        balances[msg.sender] -= _amount;
        (bool success, ) = msg.sender.call{value: _amount}("");
        if (!success) {
            balances[msg.sender] += _amount;
            emit TransferFailed(address(this), msg.sender, _amount);
        } else {
            emit Withdrawal(msg.sender, _amount);
        }
    }

    function updateSettings(address _newSalvorSigner, bool _newPausedState) external onlyOwner {
        salvorSigner = _newSalvorSigner;
        paused = _newPausedState;
        emit SettingsUpdated(msg.sender);
    }

    receive() external payable {}
}