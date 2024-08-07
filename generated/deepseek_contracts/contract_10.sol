// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReentrancyGuard {
    bool private _reentrancyGuard;

    modifier nonReentrant() {
        require(!_reentrancyGuard, "ReentrancyGuard: reentrant call");
        _reentrancyGuard = true;
        _;
        _reentrancyGuard = false;
    }
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenManager is ReentrancyGuard, Ownable {
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _lockTimes;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    function deposit() public payable {
        _balances[msg.sender] += msg.value;
        _lockTimes[msg.sender] = block.timestamp + 3600; // Lock for 1 hour
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public nonReentrant {
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        require(block.timestamp >= _lockTimes[msg.sender], "Tokens are locked");
        _balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function balanceOf(address user) public view returns (uint256) {
        return _balances[user];
    }

    function lockTimeOf(address user) public view returns (uint256) {
        return _lockTimes[user];
    }
}