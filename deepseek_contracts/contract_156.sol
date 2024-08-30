// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ScheduledOperations {
    struct Task {
        address proposer;
        uint256 delayPeriod;
        uint256 submissionTime;
        bool executed;
    }

    mapping(uint256 => Task) public tasks;
    mapping(address => bool) public authorizedProposers;
    uint256 public taskCounter;

    event TaskSubmitted(uint256 taskId, address proposer, uint256 delayPeriod);
    event TaskExecuted(uint256 taskId);

    modifier onlyAuthorized() {
        require(authorizedProposers[msg.sender], "Not authorized");
        _;
    }

    constructor(address[] memory initialProposers) {
        for (uint256 i = 0; i < initialProposers.length; i++) {
            authorizedProposers[initialProposers[i]] = true;
        }
        taskCounter = 0;
    }

    function submitTask(uint256 delayPeriod) external onlyAuthorized {
        require(delayPeriod > 0, "Delay period must be greater than 0");
        tasks[taskCounter] = Task({
            proposer: msg.sender,
            delayPeriod: delayPeriod,
            submissionTime: block.timestamp,
            executed: false
        });
        emit TaskSubmitted(taskCounter, msg.sender, delayPeriod);
        taskCounter++;
    }

    function executeTask(uint256 taskId) external {
        Task storage task = tasks[taskId];
        require(!task.executed, "Task already executed");
        require(block.timestamp >= task.submissionTime + task.delayPeriod, "Delay period not yet passed");
        // Perform the task operation here
        // For example, task.proposer.call{value: 0}("");
        task.executed = true;
        emit TaskExecuted(taskId);
    }

    function authorizeProposer(address proposer) external {
        require(msg.sender == address(this), "Only contract can authorize");
        authorizedProposers[proposer] = true;
    }

    function deauthorizeProposer(address proposer) external {
        require(msg.sender == address(this), "Only contract can deauthorize");
        authorizedProposers[proposer] = false;
    }
}