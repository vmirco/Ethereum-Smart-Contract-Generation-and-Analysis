// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Token {
    string public name = "MyToken";
    string public symbol = "MTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => FrozenBalance[]) public frozenBalances;

    struct FrozenBalance {
        uint256 amount;
        uint256 releaseTime;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Freeze(address indexed owner, uint256 value, uint256 releaseTime);
    event Unfreeze(address indexed owner, uint256 value);

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
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
        require(value <= allowance[from][msg.sender], "Allowance exceeded");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function freeze(uint256 value, uint256 releaseTime) public returns (bool success) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        frozenBalances[msg.sender].push(FrozenBalance(value, releaseTime));
        emit Freeze(msg.sender, value, releaseTime);
        return true;
    }

    function unfreeze(uint256 index) public returns (bool success) {
        require(index < frozenBalances[msg.sender].length, "Invalid index");
        FrozenBalance storage frozenBalance = frozenBalances[msg.sender][index];
        require(block.timestamp >= frozenBalance.releaseTime, "Release time not reached");
        balanceOf[msg.sender] += frozenBalance.amount;
        frozenBalances[msg.sender][index] = frozenBalances[msg.sender][frozenBalances[msg.sender].length - 1];
        frozenBalances[msg.sender].pop();
        emit Unfreeze(msg.sender, frozenBalance.amount);
        return true;
    }
}