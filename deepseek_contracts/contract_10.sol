// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SafeTokenManager {
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _lockTimestamps;
    address private _owner;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    modifier nonReentrant() {
        require(_lockTimestamps[msg.sender] <= block.timestamp, "ReentrancyGuard: reentrant call");
        _lockTimestamps[msg.sender] = block.timestamp + 1;
        _;
        _lockTimestamps[msg.sender] = block.timestamp;
    }

    constructor() {
        _owner = msg.sender;
    }

    function deposit(uint256 amount) external nonReentrant {
        _balances[msg.sender] += amount;
    }

    function withdraw(uint256 amount) external nonReentrant {
        require(_balances[msg.sender] >= amount, "SafeTokenManager: insufficient balance");
        _balances[msg.sender] -= amount;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
    }

    function owner() external view returns (address) {
        return _owner;
    }
}