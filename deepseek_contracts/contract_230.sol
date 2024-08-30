// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GameManager {
    struct Player {
        uint256 progress;
        uint256 rewards;
    }

    struct GameStage {
        uint256 id;
        uint256 rewardPool;
        bool active;
    }

    address public owner;
    uint256 public currentStage;
    mapping(address => Player) public players;
    mapping(uint256 => GameStage) public stages;
    uint256 public stageCount;

    event StageInitialized(uint256 stageId, uint256 rewardPool);
    event PlayerProgressUpdated(address player, uint256 progress);
    event RewardDistributed(address player, uint256 reward);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        currentStage = 0;
        stageCount = 0;
    }

    function initializeStage(uint256 _rewardPool) external onlyOwner {
        stageCount++;
        stages[stageCount] = GameStage({
            id: stageCount,
            rewardPool: _rewardPool,
            active: true
        });
        currentStage = stageCount;
        emit StageInitialized(stageCount, _rewardPool);
    }

    function participate() external {
        require(stages[currentStage].active, "Current stage is not active");
        players[msg.sender].progress = 1;
        emit PlayerProgressUpdated(msg.sender, 1);
    }

    function completeStage() external {
        require(players[msg.sender].progress > 0, "Player has not participated");
        uint256 reward = _generateRandomReward();
        players[msg.sender].rewards += reward;
        stages[currentStage].rewardPool -= reward;
        emit RewardDistributed(msg.sender, reward);
    }

    function _generateRandomReward() internal view returns (uint256) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, msg.sender)));
        return randomNumber % stages[currentStage].rewardPool;
    }

    function withdrawRewards() external {
        uint256 reward = players[msg.sender].rewards;
        require(reward > 0, "No rewards to withdraw");
        players[msg.sender].rewards = 0;
        (bool success, ) = msg.sender.call{value: reward}("");
        require(success, "Transfer failed");
    }

    receive() external payable {
        stages[currentStage].rewardPool += msg.value;
    }
}