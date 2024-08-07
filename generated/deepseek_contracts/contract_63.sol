// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Gamble {
    address public owner;
    uint256 public maxBetAmount;
    uint256 public percentageFee;
    uint256 public bankRoll;

    struct Bet {
        address better;
        uint256 amount;
        uint256 prediction;
        bool resolved;
    }

    Bet[] public bets;
    uint256 public nextBetId;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(uint256 _maxBetAmount, uint256 _percentageFee) {
        owner = msg.sender;
        maxBetAmount = _maxBetAmount;
        percentageFee = _percentageFee;
        bankRoll = 0;
        nextBetId = 0;
    }

    function updateSettings(uint256 _maxBetAmount, uint256 _percentageFee) public onlyOwner {
        maxBetAmount = _maxBetAmount;
        percentageFee = _percentageFee;
    }

    function initializeBankRoll(uint256 amount) public onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        bankRoll += amount;
    }

    function placeBet(uint256 prediction) public payable {
        require(msg.value <= maxBetAmount, "Bet exceeds max bet amount");
        require(msg.value > 0, "Bet amount must be greater than 0");
        uint256 fee = (msg.value * percentageFee) / 100;
        uint256 netAmount = msg.value - fee;
        bankRoll += netAmount;
        bets.push(Bet({
            better: msg.sender,
            amount: msg.value,
            prediction: prediction,
            resolved: false
        }));
        nextBetId++;
    }

    function resolveBet(uint256 betId, uint256 outcome) public onlyOwner {
        require(betId < nextBetId, "Invalid bet ID");
        Bet storage bet = bets[betId];
        require(!bet.resolved, "Bet already resolved");
        if (bet.prediction == outcome) {
            uint256 winnings = bet.amount * 2;
            require(bankRoll >= winnings, "Insufficient bank roll to pay winnings");
            payable(bet.better).transfer(winnings);
            bankRoll -= winnings;
        }
        bet.resolved = true;
    }

    function withdrawFunds(uint256 amount) public onlyOwner {
        require(amount <= bankRoll, "Insufficient funds in bank roll");
        payable(owner).transfer(amount);
        bankRoll -= amount;
    }
}