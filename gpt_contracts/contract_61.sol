// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DaiBackstopSyndicate {
    address public admin;
    mapping(address => uint256) public daiBalance;
    mapping(uint256 => Auction) public auctions;
    uint256 public nextAuctionId;
    bool public isOpen;
    
    struct Auction {
        uint256 amount;
        bool finalized;
    }

    event DaiDeposited(address indexed user, uint256 amount);
    event AuctionEntered(uint256 indexed auctionId, address indexed user, uint256 amount);
    event AuctionFinalized(uint256 indexed auctionId, address indexed user, uint256 amount);
    event DepositsHalted();

    constructor() {
        admin = msg.sender;
        isOpen = true;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier openForDeposits() {
        require(isOpen, "Not open for deposits");
        _;
    }

    function depositDai() public payable openForDeposits {
        daiBalance[msg.sender] += msg.value;
        emit DaiDeposited(msg.sender, msg.value);
    }

    function enterAuction(uint256 amount) public {
        require(daiBalance[msg.sender] >= amount, "Insufficient Balance");
        auctions[nextAuctionId++] = Auction(amount, false);
        daiBalance[msg.sender] -= amount;
        emit AuctionEntered(nextAuctionId - 1, msg.sender, amount);
    }

    function finalizeAuction(uint256 auctionId) public onlyAdmin {
        Auction storage auction = auctions[auctionId];
        require(!auction.finalized, "Auction already finalized");
        auction.finalized = true;
        emit AuctionFinalized(auctionId, msg.sender, auction.amount);
    }
    
    function haltDeposits() public onlyAdmin {
        isOpen = false;
        emit DepositsHalted();
    }
}