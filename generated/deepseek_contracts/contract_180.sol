// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ModularLong {
    struct Player {
        address playerAddress;
        uint256 balance;
        bool isRegistered;
    }

    struct Game {
        uint256 startTime;
        uint256 endTime;
        bool isActive;
    }

    address public owner;
    mapping(address => Player) public players;
    Game public currentGame;
    uint256 public totalPlayers;
    uint256 public totalAffiliatePayouts;

    event PlayerRegistered(address indexed player);
    event GameTimerStarted(uint256 startTime, uint256 endTime);
    event AffiliatePayout(address indexed affiliate, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerPlayer() external {
        require(!players[msg.sender].isRegistered, "Player already registered");
        players[msg.sender] = Player({
            playerAddress: msg.sender,
            balance: 0,
            isRegistered: true
        });
        totalPlayers++;
        emit PlayerRegistered(msg.sender);
    }

    function startGameTimer(uint256 duration) external onlyOwner {
        require(!currentGame.isActive, "Game already active");
        currentGame = Game({
            startTime: block.timestamp,
            endTime: block.timestamp + duration,
            isActive: true
        });
        emit GameTimerStarted(currentGame.startTime, currentGame.endTime);
    }

    function calculateGameMetrics() public view returns (uint256, uint256) {
        return (totalPlayers, totalAffiliatePayouts);
    }

    function managePlayerData(address playerAddress, uint256 newBalance) external onlyOwner {
        require(players[playerAddress].isRegistered, "Player not registered");
        players[playerAddress].balance = newBalance;
    }

    function payoutAffiliate(address affiliate, uint256 amount) external onlyOwner {
        require(players[affiliate].isRegistered, "Affiliate not registered");
        players[affiliate].balance += amount;
        totalAffiliatePayouts += amount;
        emit AffiliatePayout(affiliate, amount);
    }
}