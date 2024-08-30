// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ManagedContract is Ownable {
    mapping(address => bool) private _isWhitelisted;
    mapping(address => bool) private _isFundingOperator;
    mapping(address => bool) private _isFundsUnlocker;

    event Whitelisted(address indexed account);
    event FundingOperatorUpdated(address indexed account, bool status);
    event FundsUnlockerUpdated(address indexed account, bool status);

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender), "ManagedContract: caller is not whitelisted");
        _;
    }

    modifier onlyFundsUnlocker() {
        require(isFundsUnlocker(msg.sender), "ManagedContract: caller is not Funds Unlocker");
        _;
    }

    modifier onlyFundingOperator() {
        require(isFundingOperator(msg.sender), "ManagedContract: caller is not Funding Operator");
        _;
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _isWhitelisted[account];
    }

    function isFundingOperator(address account) public view returns (bool) {
        return _isFundingOperator[account];
    }

    function isFundsUnlocker(address account) public view returns (bool) {
        return _isFundsUnlocker[account];
    }

    function addWhitelist(address account) public onlyOwner {
        _isWhitelisted[account] = true;
        emit Whitelisted(account);
    }

    function removeWhitelist(address account) public onlyOwner {
        _isWhitelisted[account] = false;
    }

    function setFundingOperator(address account, bool status) public onlyOwner {
        _isFundingOperator[account] = status;
        emit FundingOperatorUpdated(account, status);
    }

    function setFundsUnlocker(address account, bool status) public onlyOwner {
        _isFundsUnlocker[account] = status;
        emit FundsUnlockerUpdated(account, status);
    }
}