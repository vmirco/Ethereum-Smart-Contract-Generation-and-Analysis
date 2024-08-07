// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DepositManager {
    struct User {
        uint256 balance;
        uint256 lastDividendPoint;
    }

    mapping(address => User) public users;
    uint256 public totalSupply;
    uint256 public dividendPerToken;
    uint256 public constant FEE_RATE = 1; // 1% fee
    uint256 public constant INFLATION_RATE = 2; // 2% inflation per period

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    function deposit(uint256 amount) external payable {
        require(amount > 0, "Amount must be greater than 0");
        User storage user = users[msg.sender];
        updateDividend(user);
        user.balance += amount;
        totalSupply += amount;
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        User storage user = users[msg.sender];
        require(user.balance >= amount, "Insufficient balance");
        updateDividend(user);
        user.balance -= amount;
        totalSupply -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    function transfer(address to, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        User storage sender = users[msg.sender];
        User storage recipient = users[to];
        require(sender.balance >= amount, "Insufficient balance");
        updateDividend(sender);
        updateDividend(recipient);
        sender.balance -= amount;
        recipient.balance += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function updateDividend(User storage user) internal {
        if (totalSupply > 0) {
            dividendPerToken += (block.timestamp - user.lastDividendPoint) * INFLATION_RATE / 100;
        }
        user.lastDividendPoint = block.timestamp;
        uint256 owed = dividendPerToken * user.balance / 1e18 - user.balance;
        user.balance += owed;
    }

    function calculateDividends() external view returns (uint256) {
        User memory user = users[msg.sender];
        uint256 currentDividendPerToken = dividendPerToken + (block.timestamp - user.lastDividendPoint) * INFLATION_RATE / 100;
        return (currentDividendPerToken * user.balance / 1e18) - user.balance;
    }
}