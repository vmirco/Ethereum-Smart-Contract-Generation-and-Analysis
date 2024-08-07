// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReferralSystem {
    address public owner;
    uint256 public totalDeposits;
    uint256 public totalWithdrawals;

    struct User {
        address referrer;
        uint256 balance;
        uint256 totalDeposits;
        uint256 totalWithdrawals;
    }

    mapping(address => User) public users;
    mapping(address => bool) public isRegistered;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event ReferralSet(address indexed user, address indexed referrer);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyRegistered() {
        require(isRegistered[msg.sender], "User not registered");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function register(address referrer) public {
        require(!isRegistered[msg.sender], "Already registered");
        require(referrer != msg.sender, "Cannot refer yourself");

        users[msg.sender] = User({
            referrer: referrer,
            balance: 0,
            totalDeposits: 0,
            totalWithdrawals: 0
        });
        isRegistered[msg.sender] = true;

        emit ReferralSet(msg.sender, referrer);
    }

    function deposit() public payable onlyRegistered {
        require(msg.value > 0, "Deposit amount must be greater than 0");

        users[msg.sender].balance += msg.value;
        users[msg.sender].totalDeposits += msg.value;
        totalDeposits += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public onlyRegistered {
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(users[msg.sender].balance >= amount, "Insufficient balance");

        users[msg.sender].balance -= amount;
        users[msg.sender].totalWithdrawals += amount;
        totalWithdrawals += amount;

        payable(msg.sender).transfer(amount);

        emit Withdrawal(msg.sender, amount);
    }

    function getUserBalance(address user) public view returns (uint256) {
        return users[user].balance;
    }

    function getUserTotalDeposits(address user) public view returns (uint256) {
        return users[user].totalDeposits;
    }

    function getUserTotalWithdrawals(address user) public view returns (uint256) {
        return users[user].totalWithdrawals;
    }

    function getUserReferrer(address user) public view returns (address) {
        return users[user].referrer;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }
}