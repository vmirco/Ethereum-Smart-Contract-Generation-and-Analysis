// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OperatorRole {
    address public operator;

    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);
    event ActionNotification(string message);

    modifier onlyOperator() {
        require(msg.sender == operator, "Caller is not the operator");
        _;
    }

    constructor() {
        operator = msg.sender;
        emit OperatorTransferred(address(0), operator);
    }

    function getOperator() public view returns (address) {
        return operator;
    }

    function transferOperator(address newOperator) public onlyOperator {
        require(newOperator != address(0), "New operator is the zero address");
        emit OperatorTransferred(operator, newOperator);
        operator = newOperator;
    }

    function isOperator(address account) public view returns (bool) {
        return account == operator;
    }

    function notifyAction(string memory message) public onlyOperator {
        emit ActionNotification(message);
    }
}