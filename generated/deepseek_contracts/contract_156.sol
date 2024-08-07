// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ScheduledOperations {
    struct Task {
        uint256 id;
        uint256 delay;
        uint256 timestamp;
        bool executed;
    }

    mapping(uint256 => Task) public tasks;
    mapping(address => bool) public proposers;
    uint256 public taskCount;

    modifier onlyProposer() {
        require(proposers[msg.sender], "Not a proposer");
        _;
    }

    modifier taskExists(uint256 _id) {
        require(tasks[_id].id != 0, "Task does not exist");
        _;
    }

    constructor(address[] memory _proposers) {
        for (uint256 i = 0; i < _proposers.length; i++) {
            proposers[_proposers[i]] = true;
        }
    }

    function submitTask(uint256 _delay) public onlyProposer returns (uint256) {
        taskCount++;
        tasks[taskCount] = Task({
            id: taskCount,
            delay: _delay,
            timestamp: block.timestamp,
            executed: false
        });
        return taskCount;
    }

    function executeTask(uint256 _id) public taskExists(_id) {
        Task storage task = tasks[_id];
        require(!task.executed, "Task already executed");
        require(block.timestamp >= task.timestamp + task.delay, "Task not ready");
        task.executed = true;
        // Perform task execution logic here
    }

    function getTask(uint256 _id) public view returns (uint256, uint256, uint256, bool) {
        Task storage task = tasks[_id];
        return (task.id, task.delay, task.timestamp, task.executed);
    }
}