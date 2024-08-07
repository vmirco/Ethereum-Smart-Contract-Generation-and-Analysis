// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MinerEngineerGame {
    struct Engineer {
        uint256 id;
        uint256 efficiency;
        uint256 price;
    }

    struct Booster {
        uint256 id;
        uint256 boostPercentage;
        uint256 price;
    }

    struct Player {
        uint256 balance;
        uint256[] ownedEngineers;
        uint256[] ownedBoosters;
    }

    uint256 public nextEngineerId;
    uint256 public nextBoosterId;
    mapping(uint256 => Engineer) public engineers;
    mapping(uint256 => Booster) public boosters;
    mapping(address => Player) public players;

    event EngineerBought(address indexed player, uint256 engineerId);
    event EngineerSold(address indexed player, uint256 engineerId);
    event BoosterBought(address indexed player, uint256 boosterId);
    event VirusTypeChanged(uint256 newVirusType);

    function buyEngineer(uint256 engineerId) external {
        require(engineers[engineerId].id != 0, "Engineer does not exist");
        require(players[msg.sender].balance >= engineers[engineerId].price, "Insufficient balance");

        players[msg.sender].balance -= engineers[engineerId].price;
        players[msg.sender].ownedEngineers.push(engineerId);
        emit EngineerBought(msg.sender, engineerId);
    }

    function sellEngineer(uint256 engineerId) external {
        require(engineers[engineerId].id != 0, "Engineer does not exist");
        bool isOwned = false;
        for (uint256 i = 0; i < players[msg.sender].ownedEngineers.length; i++) {
            if (players[msg.sender].ownedEngineers[i] == engineerId) {
                isOwned = true;
                delete players[msg.sender].ownedEngineers[i];
                break;
            }
        }
        require(isOwned, "Engineer not owned by player");

        players[msg.sender].balance += engineers[engineerId].price;
        emit EngineerSold(msg.sender, engineerId);
    }

    function buyBooster(uint256 boosterId) external {
        require(boosters[boosterId].id != 0, "Booster does not exist");
        require(players[msg.sender].balance >= boosters[boosterId].price, "Insufficient balance");

        players[msg.sender].balance -= boosters[boosterId].price;
        players[msg.sender].ownedBoosters.push(boosterId);
        emit BoosterBought(msg.sender, boosterId);
    }

    function changeVirusType(uint256 newVirusType) external {
        emit VirusTypeChanged(newVirusType);
    }

    function addEngineer(uint256 efficiency, uint256 price) external {
        engineers[nextEngineerId] = Engineer(nextEngineerId, efficiency, price);
        nextEngineerId++;
    }

    function addBooster(uint256 boostPercentage, uint256 price) external {
        boosters[nextBoosterId] = Booster(nextBoosterId, boostPercentage, price);
        nextBoosterId++;
    }

    function deposit() external payable {
        players[msg.sender].balance += msg.value;
    }
}