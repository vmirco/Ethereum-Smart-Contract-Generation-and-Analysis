// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GameContract {
    struct Player {
        uint id;
        string name;
        uint stage;
    }

    struct Stage {
        uint id;
        string name;
        uint reward;
    }

    mapping(address => Player) private players;
    mapping(uint => Stage) private stages;
    uint private stageCounter = 0;
    uint private playerCount = 0;

    event PlayerAdvancedStage(address indexed playerAddress, uint currentStage, uint reward);

    constructor() {
        _addNewStage("Stage 1", 50);
        _addNewStage("Stage 2", 100);
        _addNewStage("Stage 3", 200);
    }

    function joinGame(string memory _name) public {
        require(players[msg.sender].id == 0, "You have already joined");
        playerCount++;
        players[msg.sender] = Player(playerCount, _name, 0);
    }

    function advanceStage() public {
        require(players[msg.sender].id != 0, "You haven't joined the game");
        require(players[msg.sender].stage < stageCounter, "You have already completed all stages");
        
        uint randomNum = _getRandomNumber();
        if(randomNum > 50) {
            players[msg.sender].stage++;
            uint reward = stages[players[msg.sender].stage].reward;
            payable(msg.sender).transfer(reward);
            emit PlayerAdvancedStage(msg.sender, players[msg.sender].stage, reward);
        }
    }

    function getCurrentPlayerStage() public view returns (uint) {
        return players[msg.sender].stage;
    }

    function _addNewStage(string memory _name, uint _reward) private {
        stageCounter++;
        stages[stageCounter] = Stage(stageCounter, _name, _reward);
    }

    function _getRandomNumber() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 100;
    }

    receive() external payable {}
}