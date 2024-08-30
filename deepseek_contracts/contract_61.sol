// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DaiBackstopSyndicate {
    address public owner;
    bool public halted;
    uint256 public totalDeposits;

    mapping(address => uint256) public deposits;

    event Deposit(address indexed user, uint256 amount);
    event AuctionEntered(address indexed user, uint256 amount);
    event AuctionFinalized(address indexed user, uint256 amount);
    event Halted(bool status);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier notHalted() {
        require(!halted, "Contract is halted");
        _;
    }

    constructor() {
        owner = msg.sender;
        halted = false;
    }

    function deposit(uint256 amount) external notHalted {
        require(amount > 0, "Amount must be greater than 0");
        deposits[msg.sender] += amount;
        totalDeposits += amount;
        emit Deposit(msg.sender, amount);
    }

    function enterAuction(uint256 amount) external notHalted {
        require(amount > 0, "Amount must be greater than 0");
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        deposits[msg.sender] -= amount;
        emit AuctionEntered(msg.sender, amount);
    }

    function finalizeAuction(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        deposits[msg.sender] += amount;
        emit AuctionFinalized(msg.sender, amount);
    }

    function halt(bool status) external onlyOwner {
        halted = status;
        emit Halted(status);
    }
}