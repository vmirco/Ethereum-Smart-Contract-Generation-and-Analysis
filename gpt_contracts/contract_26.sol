// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RestrictedAccess {

    address private _operator;
    mapping(address => uint8) private _operators;

    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);
    event Action(string details, address indexed operator);

    modifier onlyOperator() {
        require(_operators[msg.sender] > 0, "RestrictedAccess: caller is not the operator");
        _;
    }

    constructor(address initialOperator) {
        require(initialOperator != address(0), "RestrictedAccess: invalid address");
        _operator = initialOperator;
        _operators[initialOperator] = 1;

        emit OperatorTransferred(address(0), initialOperator);
    }

    function operator() public view returns (address) {
        return _operator;
    }

    function isOperator(address operatorAddress) public view returns (bool) {
        return _operators[operatorAddress] > 0;
    }

    function transferOperator(address newOperator) public onlyOperator {
        require(newOperator != address(0), "RestrictedAccess: invalid address");
        _operators[_operator] = 0;
        _operator = newOperator;
        _operators[newOperator] = 1;

        emit OperatorTransferred(_operator, newOperator);
    }

    function action(string memory details) public onlyOperator {
        emit Action(details, msg.sender);
    }
}