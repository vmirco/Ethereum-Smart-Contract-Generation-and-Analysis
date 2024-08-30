pragma solidity ^0.8.0;

contract Gamble {

    address public owner;
    uint public maxBet; // Maximum Bet Amount
    uint public feePercent; // Percentage Fee
    uint public bankRoll; // Bank Roll

    struct Bet {
        uint amount;
        uint prediction;
        address player;
    }

    mapping(address => Bet) public bets;

    constructor(uint _maxBet, uint _feePercent) {
        require(_maxBet > 0, "Max Bet should be positive");
        require(_feePercent > 0 && _feePercent < 100, "Fee should be between 0 and 100");

        owner = msg.sender;
        maxBet = _maxBet;
        feePercent = _feePercent;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    function changeSettings(uint _maxBet, uint _feePercent) public onlyOwner {
        maxBet = _maxBet;
        feePercent = _feePercent;
    }

    function addToBankRoll() public payable onlyOwner {
        bankRoll += msg.value;
    }

    function placeBet(uint _prediction) public payable {
        require(msg.value <= maxBet, "Exceeds maximum bet");
        require(bankRoll >= msg.value, "Bankroll is not sufficient for this bet");

        Bet storage bet = bets[msg.sender];
        bet.amount = msg.value;
        bet.prediction = _prediction;
        bet.player = msg.sender;

        bankRoll -= msg.value;
    }

    function resolveBet(address _player) public onlyOwner {
        Bet storage bet = bets[_player];

        require(bet.amount > 0, "No active bet for this player");

        uint outcome = uint(keccak256(abi.encodePacked(block.timestamp, block.number))) % 10;
        if(bet.prediction == outcome) {
            // Player Wins
            uint winnings = bet.amount + (bet.amount * (100 - feePercent) / 100);
            payable(_player).transfer(winnings);
            bankRoll -= winnings;
        } else {
            // House Wins
            bankRoll += bet.amount;
        }

        // Clear the bet
        bets[_player].amount = 0;
        bets[_player].prediction = 0;
    }
}