// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Gamble {
    address public owner;
    uint256 public maxBetAmount;
    uint256 public percentageFee;
    uint256 public bankRoll;
    bool public bettingActive;

    struct Bet {
        address better;
        uint256 amount;
        uint256 prediction;
        bool resolved;
    }

    Bet[] public bets;

    event BetPlaced(address indexed better, uint256 amount, uint256 prediction);
    event BetResolved(address indexed better, uint256 amount, bool won);
    event SettingsUpdated(uint256 maxBetAmount, uint256 percentageFee);
    event BankRollInitialized(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        maxBetAmount = 1 ether; // Example value
        percentageFee = 5; // 5% fee
        bettingActive = false;
    }

    function updateSettings(uint256 _maxBetAmount, uint256 _percentageFee) external onlyOwner {
        maxBetAmount = _maxBetAmount;
        percentageFee = _percentageFee;
        emit SettingsUpdated(maxBetAmount, percentageFee);
    }

    function initializeBankRoll(uint256 _amount) external onlyOwner {
        require(bankRoll == 0, "Bank roll already initialized");
        bankRoll = _amount;
        emit BankRollInitialized(_amount);
    }

    function placeBet(uint256 _prediction) external payable {
        require(bettingActive, "Betting is not active");
        require(msg.value <= maxBetAmount, "Bet amount exceeds maximum");
        require(msg.value > 0, "Bet amount must be greater than 0");

        bets.push(Bet({
            better: msg.sender,
            amount: msg.value,
            prediction: _prediction,
            resolved: false
        }));

        emit BetPlaced(msg.sender, msg.value, _prediction);
    }

    function resolveBet(uint256 betIndex, uint256 outcome) external onlyOwner {
        require(betIndex < bets.length, "Invalid bet index");
        Bet storage bet = bets[betIndex];
        require(!bet.resolved, "Bet already resolved");

        bool won = bet.prediction == outcome;
        if (won) {
            uint256 winnings = bet.amount + (bet.amount * (100 - percentageFee)) / 100;
            require(winnings <= bankRoll, "Insufficient bank roll to pay winnings");
            payable(bet.better).transfer(winnings);
            bankRoll -= winnings;
        }

        bet.resolved = true;
        emit BetResolved(bet.better, bet.amount, won);
    }

    function toggleBettingActive() external onlyOwner {
        bettingActive = !bettingActive;
    }

    function withdrawBankRoll(uint256 amount) external onlyOwner {
        require(amount <= bankRoll, "Insufficient bank roll");
        bankRoll -= amount;
        payable(owner).transfer(amount);
    }
}