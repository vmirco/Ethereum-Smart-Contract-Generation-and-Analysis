// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BettingSystem {
    struct User {
        uint balance;
        uint[] betHistory;
    }

    struct Bet {
        address user;
        uint amount;
        bool resolved;
        bool won;
    }

    mapping(address => User) public users;
    Bet[] public bets;
    uint public totalPool;
    uint public withdrawalLimit = 1000; // Example limit
    uint public betLimit = 100; // Example limit

    event Deposit(address indexed user, uint amount);
    event BetPlaced(address indexed user, uint betId, uint amount);
    event Withdrawal(address indexed user, uint amount);

    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        users[msg.sender].balance += msg.value;
        totalPool += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function placeBet(uint amount) public {
        require(amount > 0 && amount <= betLimit, "Invalid bet amount");
        require(users[msg.sender].balance >= amount, "Insufficient balance");
        users[msg.sender].balance -= amount;
        totalPool += amount;
        Bet memory newBet = Bet({user: msg.sender, amount: amount, resolved: false, won: false});
        uint betId = bets.length;
        bets.push(newBet);
        users[msg.sender].betHistory.push(betId);
        emit BetPlaced(msg.sender, betId, amount);
    }

    function withdraw(uint amount) public {
        require(amount > 0 && amount <= withdrawalLimit, "Invalid withdrawal amount");
        require(users[msg.sender].balance >= amount, "Insufficient balance");
        users[msg.sender].balance -= amount;
        totalPool -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    function resolveBet(uint betId, bool won) public {
        require(betId < bets.length, "Invalid bet ID");
        Bet storage bet = bets[betId];
        require(!bet.resolved, "Bet already resolved");
        bet.resolved = true;
        bet.won = won;
        if (won) {
            users[bet.user].balance += bet.amount * 2; // Example payout
        }
    }

    function getUserBalance(address user) public view returns (uint) {
        return users[user].balance;
    }

    function getUserBetHistory(address user) public view returns (uint[] memory) {
        return users[user].betHistory;
    }
}