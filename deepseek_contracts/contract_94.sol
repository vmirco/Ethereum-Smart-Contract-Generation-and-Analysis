// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GoldToken {
    string public name = "GoldToken";
    string public symbol = "GLD";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require(value <= balanceOf[from], "Insufficient balance");
        require(value <= allowance[from][msg.sender], "Allowance too low");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }
}

contract GoldLock {
    GoldToken public goldToken;

    struct Lock {
        uint256 amount;
        uint256 unlockTime;
        bool claimed;
    }

    mapping(address => Lock[]) public locks;

    event GoldLocked(address indexed owner, uint256 amount, uint256 unlockTime);
    event GoldUnlocked(address indexed owner, uint256 amount);

    constructor(address _goldToken) {
        goldToken = GoldToken(_goldToken);
    }

    function lockGold(uint256 amount, uint256 unlockTime) public {
        require(goldToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        locks[msg.sender].push(Lock({amount: amount, unlockTime: unlockTime, claimed: false}));
        emit GoldLocked(msg.sender, amount, unlockTime);
    }

    function unlockGold(uint256 lockIndex) public {
        Lock storage lock = locks[msg.sender][lockIndex];
        require(!lock.claimed, "Already claimed");
        require(block.timestamp >= lock.unlockTime, "Unlock time not reached");
        lock.claimed = true;
        require(goldToken.transfer(msg.sender, lock.amount), "Transfer failed");
        emit GoldUnlocked(msg.sender, lock.amount);
    }
}