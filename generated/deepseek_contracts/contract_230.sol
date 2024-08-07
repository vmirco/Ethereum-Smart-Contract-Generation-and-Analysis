// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GameManager {
    struct Stage {
        uint256 id;
        string name;
        uint256 reward;
        bool active;
    }

    struct Player {
        uint256 currentStage;
        uint256[] completedStages;
        uint256 totalRewards;
    }

    Stage[] public stages;
    mapping(address => Player) public players;
    uint256 private nonce = 0;

    event StageInitialized(uint256 id, string name, uint256 reward);
    event PlayerProgressed(address player, uint256 stageId);
    event RewardDistributed(address player, uint256 amount);

    function initializeStage(string memory name, uint256 reward) public {
        uint256 stageId = stages.length;
        stages.push(Stage({
            id: stageId,
            name: name,
            reward: reward,
            active: true
        }));
        emit StageInitialized(stageId, name, reward);
    }

    function participate() public {
        if (players[msg.sender].currentStage == 0) {
            players[msg.sender].currentStage = 1;
        }
    }

    function completeStage(uint256 stageId) public {
        require(stageId < stages.length, "Invalid stage ID");
        require(players[msg.sender].currentStage == stageId, "Not eligible for this stage");
        require(stages[stageId].active, "Stage is not active");

        players[msg.sender].completedStages.push(stageId);
        players[msg.sender].totalRewards += stages[stageId].reward;
        players[msg.sender].currentStage++;

        emit PlayerProgressed(msg.sender, stageId);
        emit RewardDistributed(msg.sender, stages[stageId].reward);
    }

    function getRandomNumber() private returns (uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % 100;
        nonce++;
        return random;
    }

    function determineOutcome(uint256 stageId) public view returns (bool) {
        require(stageId < stages.length, "Invalid stage ID");
        uint256 random = getRandomNumber();
        return random < 50; // 50% chance of success
    }

    function getPlayerInfo(address player) public view returns (uint256, uint256[] memory, uint256) {
        return (
            players[player].currentStage,
            players[player].completedStages,
            players[player].totalRewards
        );
    }
}