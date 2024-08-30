// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FinancialPlatform {
    struct User {
        uint balance;
        bool isRegistered;
    }

    mapping(address => User) public users;
    address public owner;
    uint public constant MIN_DEPOSIT = 100; // Minimum deposit amount
    uint public constant RETURN_RATE = 5; // 5% return rate

    event UserRegistered(address indexed user);
    event DepositMade(address indexed user, uint amount);
    event InvestmentReturn(address indexed user, uint amount);
    event WithdrawalMade(address indexed user, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyRegistered() {
        require(users[msg.sender].isRegistered, "User not registered");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function register() external {
        require(!users[msg.sender].isRegistered, "Already registered");
        users[msg.sender] = User({balance: 0, isRegistered: true});
        emit UserRegistered(msg.sender);
    }

    function deposit() external payable onlyRegistered {
        require(msg.value >= MIN_DEPOSIT, "Deposit amount too low");
        users[msg.sender].balance += msg.value;
        emit DepositMade(msg.sender, msg.value);
    }

    function invest() external onlyRegistered {
        uint investmentAmount = users[msg.sender].balance * RETURN_RATE / 100;
        users[msg.sender].balance += investmentAmount;
        emit InvestmentReturn(msg.sender, investmentAmount);
    }

    function withdraw(uint amount) external onlyRegistered {
        require(amount <= users[msg.sender].balance, "Insufficient balance");
        users[msg.sender].balance -= amount;
        payable(msg.sender).transfer(amount);
        emit WithdrawalMade(msg.sender, amount);
    }

    function getBalance() external view onlyRegistered returns (uint) {
        return users[msg.sender].balance;
    }
}