// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Operable {
    struct Operation {
        address proposer;
        string description;
        bool executed;
        uint256 timestamp;
    }

    mapping(uint256 => Operation) private operations;
    uint256 public operationIndex;
    uint256 public delayPeriod;

    modifier onlyProposer(uint256 _operationId) {
        require(msg.sender == operations[_operationId].proposer, "Not operation's proposer");
        _;
    }

    modifier notExecuted(uint256 _operationId) {
        require(operations[_operationId].executed == false, "Already executed");
        _;
    }

    modifier delayed(uint256 _operationId) {
        require(block.timestamp >= operations[_operationId].timestamp + delayPeriod, "Operation in delay period");
        _;
    }

    event OperationProposed(uint256 operationId, address proposer, string description);
    event OperationExecuted(uint256 operationId);

    constructor(uint256 _delayPeriod) {
        operationIndex = 1;
        delayPeriod = _delayPeriod;
    }

    function proposeOperation(string memory _description) public returns(uint256) {
        operations[operationIndex] = Operation(msg.sender, _description, false, block.timestamp);
        emit OperationProposed(operationIndex, msg.sender, _description);
        operationIndex += 1;
        return operationIndex - 1;
    }

    function executeOperation(uint256 _operationId) public onlyProposer(_operationId) notExecuted(_operationId) delayed(_operationId) {
        operations[_operationId].executed = true;
        emit OperationExecuted(_operationId);
    }

    function getOperationDetails(uint256 _operationId) public view returns(address, string memory, bool, uint256) {
        return (operations[_operationId].proposer, operations[_operationId].description, operations[_operationId].executed, operations[_operationId].timestamp);
    }
}