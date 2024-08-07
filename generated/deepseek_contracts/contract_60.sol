// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BettingSystem {
    struct User {
        uint256 balance;
        uint256[] betIds;
    }

    struct Bet {
        address user;
        uint256 amount;
        bool won;
    }

    mapping(address => User) public users;
    Bet[] public bets;
    uint256 public totalBets;
    uint256 public constant MAX_BET_AMOUNT = 100 ether;
    uint256 public constant MAX_WITHDRAWAL_AMOUNT = 500 ether;

    event Deposit(address indexed user, uint256 amount);
    event BetPlaced(address indexed user, uint256 betId, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        users[msg.sender].balance += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function placeBet(uint256 amount) external {
        require(amount > 0 && amount <= MAX_BET_AMOUNT, "Invalid bet amount");
        require(users[msg.sender].balance >= amount, "Insufficient balance");

        users[msg.sender].balance -= amount;
        uint256 betId = bets.length;
        bets.push(Bet({user: msg.sender, amount: amount, won: false}));
        users[msg.sender].betIds.push(betId);
        totalBets++;

        emit BetPlaced(msg.sender, betId, amount);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0 && amount <= MAX_WITHDRAWAL_AMOUNT, "Invalid withdrawal amount");
        require(users[msg.sender].balance >= amount, "Insufficient balance");

        users[msg.sender].balance -= amount;
        payable(msg.sender).transfer(amount);

        emit Withdrawal(msg.sender, amount);
    }

    function getUserBets(address user) external view returns (uint256[] memory) {
        return users[user].betIds;
    }

    function getBetDetails(uint256 betId) external view returns (address, uint256, bool) {
        Bet storage bet = bets[betId];
        return (bet.user, bet.amount, bet.won);
    }
}