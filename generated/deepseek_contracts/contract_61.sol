// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract DaiBackstopSyndicate {
    IERC20 public dai;
    address public owner;
    bool public halted;

    struct Auction {
        uint256 amount;
        address bidder;
        bool finalized;
    }

    Auction[] public auctions;
    mapping(address => uint256) public deposits;

    event Deposited(address indexed user, uint256 amount);
    event AuctionEntered(uint256 indexed auctionId, address indexed bidder, uint256 amount);
    event AuctionFinalized(uint256 indexed auctionId, address indexed bidder, uint256 amount);
    event Halted(bool status);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier notHalted() {
        require(!halted, "Contract is halted");
        _;
    }

    constructor(address _dai) {
        dai = IERC20(_dai);
        owner = msg.sender;
    }

    function deposit(uint256 amount) external notHalted {
        require(dai.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        deposits[msg.sender] += amount;
        emit Deposited(msg.sender, amount);
    }

    function enterAuction(uint256 amount) external notHalted {
        require(deposits[msg.sender] >= amount, "Insufficient deposit");
        deposits[msg.sender] -= amount;
        auctions.push(Auction({amount: amount, bidder: msg.sender, finalized: false}));
        emit AuctionEntered(auctions.length - 1, msg.sender, amount);
    }

    function finalizeAuction(uint256 auctionId) external onlyOwner {
        Auction storage auction = auctions[auctionId];
        require(!auction.finalized, "Auction already finalized");
        auction.finalized = true;
        require(dai.transfer(auction.bidder, auction.amount), "Transfer failed");
        emit AuctionFinalized(auctionId, auction.bidder, auction.amount);
    }

    function halt(bool status) external onlyOwner {
        halted = status;
        emit Halted(status);
    }
}