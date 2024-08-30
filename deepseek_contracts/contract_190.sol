// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MinerEngineerGame {
    struct Miner {
        uint256 id;
        uint256 miningPower;
        uint256 price;
    }

    struct Booster {
        uint256 id;
        uint256 boostPercentage;
        uint256 price;
    }

    struct Player {
        uint256 balance;
        uint256[] minerIds;
        uint256[] boosterIds;
    }

    mapping(uint256 => Miner) public miners;
    mapping(uint256 => Booster) public boosters;
    mapping(address => Player) public players;

    uint256 public minerIdCounter;
    uint256 public boosterIdCounter;

    event MinerBought(address indexed player, uint256 minerId);
    event MinerSold(address indexed player, uint256 minerId);
    event BoosterBought(address indexed player, uint256 boosterId);
    event VirusTypeChanged(uint256 newVirusType);

    function buyMiner(uint256 _minerId) external {
        Miner storage miner = miners[_minerId];
        require(miner.price > 0, "Miner does not exist");
        Player storage player = players[msg.sender];
        require(player.balance >= miner.price, "Not enough balance");

        player.balance -= miner.price;
        player.minerIds.push(_minerId);
        emit MinerBought(msg.sender, _minerId);
    }

    function sellMiner(uint256 _minerId) external {
        Player storage player = players[msg.sender];
        uint256 minerIndex = findMinerIndex(player.minerIds, _minerId);
        require(minerIndex < player.minerIds.length, "Miner not owned by player");

        Miner storage miner = miners[_minerId];
        player.balance += miner.price;
        removeMiner(player.minerIds, minerIndex);
        emit MinerSold(msg.sender, _minerId);
    }

    function buyBooster(uint256 _boosterId) external {
        Booster storage booster = boosters[_boosterId];
        require(booster.price > 0, "Booster does not exist");
        Player storage player = players[msg.sender];
        require(player.balance >= booster.price, "Not enough balance");

        player.balance -= booster.price;
        player.boosterIds.push(_boosterId);
        emit BoosterBought(msg.sender, _boosterId);
    }

    function changeVirusType(uint256 _newVirusType) external {
        // Assuming this function changes some game state related to virus types
        // Implementation details would depend on the specific game mechanics
        emit VirusTypeChanged(_newVirusType);
    }

    function findMinerIndex(uint256[] storage _minerIds, uint256 _minerId) private view returns (uint256) {
        for (uint256 i = 0; i < _minerIds.length; i++) {
            if (_minerIds[i] == _minerId) {
                return i;
            }
        }
        return _minerIds.length; // Return an invalid index if not found
    }

    function removeMiner(uint256[] storage _minerIds, uint256 _index) private {
        _minerIds[_index] = _minerIds[_minerIds.length - 1];
        _minerIds.pop();
    }
}