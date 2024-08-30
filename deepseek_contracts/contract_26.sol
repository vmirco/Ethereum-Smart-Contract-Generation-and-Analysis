// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OperatorRole {
    address private _operator;

    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);
    event ActionNotification(string message);

    modifier onlyOperator() {
        require(isOperator(msg.sender), "Caller is not the operator");
        _;
    }

    constructor() {
        _operator = msg.sender;
        emit OperatorTransferred(address(0), _operator);
    }

    function operator() public view returns (address) {
        return _operator;
    }

    function isOperator(address account) public view returns (bool) {
        return account == _operator;
    }

    function transferOperator(address newOperator) public onlyOperator {
        require(newOperator != address(0), "New operator is the zero address");
        emit OperatorTransferred(_operator, newOperator);
        _operator = newOperator;
    }

    function performAction() public onlyOperator {
        emit ActionNotification("Action performed by operator");
    }
}