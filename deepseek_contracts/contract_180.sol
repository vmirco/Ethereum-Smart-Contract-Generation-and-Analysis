// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ModularLong {
    struct Player {
        address payable walletAddress;
        uint256 balance;
        bool isRegistered;
    }

    mapping(address => Player) public players;
    address[] public playerList;
    uint256 public gameStartTime;
    uint256 public constant GAME_DURATION = 3600; // 1 hour in seconds

    event PlayerRegistered(address indexed player);
    event GameTimerStarted(uint256 startTime);
    event AffiliatePayout(address indexed affiliate, uint256 amount);

    modifier onlyRegisteredPlayer() {
        require(players[msg.sender].isRegistered, "Player is not registered");
        _;
    }

    function registerPlayer() external {
        require(!players[msg.sender].isRegistered, "Player already registered");
        players[msg.sender] = Player({
            walletAddress: payable(msg.sender),
            balance: 0,
            isRegistered: true
        });
        playerList.push(msg.sender);
        emit PlayerRegistered(msg.sender);
    }

    function startGameTimer() external onlyRegisteredPlayer {
        require(gameStartTime == 0, "Game timer already started");
        gameStartTime = block.timestamp;
        emit GameTimerStarted(gameStartTime);
    }

    function calculateGameMetrics() external view returns (uint256 totalPlayers, uint256 totalBalance) {
        totalPlayers = playerList.length;
        for (uint256 i = 0; i < playerList.length; i++) {
            totalBalance += players[playerList[i]].balance;
        }
    }

    function managePlayerData(address playerAddress, uint256 newBalance) external onlyRegisteredPlayer {
        require(players[playerAddress].isRegistered, "Player not registered");
        players[playerAddress].balance = newBalance;
    }

    function payoutAffiliate(address payable affiliate, uint256 amount) external onlyRegisteredPlayer {
        require(affiliate != address(0), "Invalid affiliate address");
        require(players[msg.sender].balance >= amount, "Insufficient balance");
        players[msg.sender].balance -= amount;
        affiliate.transfer(amount);
        emit AffiliatePayout(affiliate, amount);
    }

    function isGameActive() public view returns (bool) {
        return gameStartTime != 0 && block.timestamp < gameStartTime + GAME_DURATION;
    }

    receive() external payable {
        require(players[msg.sender].isRegistered, "Player not registered");
        players[msg.sender].balance += msg.value;
    }
}