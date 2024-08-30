// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MinerEngineerGame {
    event EngineerBought(address indexed buyer, uint256 engineerId);
    event EngineerSold(address indexed seller, uint256 engineerId);
    event BoosterBought(address indexed buyer, uint256 boostId);
    event VirusTypeChanged(address indexed changer, uint256[] types);

    struct Miner {
        uint256 id;
        uint256 miningPower;
    }

    struct Boost {
        uint256 id;
        uint256 powerIncrement;
        uint256 duration;
    }

    mapping(address => Miner) public miners;
    mapping(address => Boost) public boosters;

    uint256 private engineerPrice = 1 ether;
    uint256 private boosterPrice = 0.1 ether;
    uint256[] public virusTypes = [1, 2, 3, 4, 5];
    
    function buyEngineer() public payable {
        require(msg.value >= engineerPrice, "Insufficient funds to buy engineer.");

        uint256 newId = createMinerId();
        miners[msg.sender] = Miner(newId, 1000);

        emit EngineerBought(msg.sender, newId);
    }

    function sellEngineer() public {
        require(miners[msg.sender].id != 0, "No engineer to sell.");

        uint256 sellId = miners[msg.sender].id;
        delete miners[msg.sender];

        payable(msg.sender).transfer(engineerPrice);
        emit EngineerSold(msg.sender, sellId);
    }

    function buyBoost() public payable {
        require(msg.value >= boosterPrice, "Insufficient funds to buy booster.");

        uint256 newId = createBoostId();
        boosters[msg.sender] = Boost(newId, 200, 30 minutes);

        emit BoosterBought(msg.sender, newId);
    }

    // Change allowed virus types
    function changeVirusTypes(uint256[] memory types) public {
        virusTypes = types;
        emit VirusTypeChanged(msg.sender, types);
    }

    function createMinerId() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)));
    }

    function createBoostId() private view returns (uint256) {
          return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));
    }
}