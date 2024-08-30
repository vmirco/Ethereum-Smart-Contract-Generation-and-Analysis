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
    uint256 public inflationRate = 5; // 5% inflation per year

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    function deposit(uint256 amount) external {
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
        uint256 fee = (amount * FEE_RATE) / 100;
        uint256 withdrawAmount = amount - fee;
        emit Withdraw(msg.sender, withdrawAmount);
        // Transfer funds to user
        (bool success, ) = msg.sender.call{value: withdrawAmount}("");
        require(success, "Transfer failed.");
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
        uint256 newDividend = calculateDividend(user);
        user.lastDividendPoint = dividendPerToken;
        if (newDividend > 0) {
            user.balance += newDividend;
        }
    }

    function calculateDividend(User storage user) internal view returns (uint256) {
        uint256 totalDividend = (user.balance * (dividendPerToken - user.lastDividendPoint)) / 1e18;
        return totalDividend;
    }

    function distributeDividends() external {
        uint256 newDividends = (totalSupply * inflationRate) / 100;
        dividendPerToken += (newDividends * 1e18) / totalSupply;
    }
}