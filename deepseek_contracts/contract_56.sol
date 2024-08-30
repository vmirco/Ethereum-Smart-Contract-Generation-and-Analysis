// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BasicAttentionToken {
    string public name = "Basic Attention Token";
    string public symbol = "BAT";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public cap = 1000000000 * 10 ** uint256(decimals); // 1 billion tokens

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        totalSupply = cap;
        balanceOf[msg.sender] = cap;
        emit Transfer(address(0), msg.sender, cap);
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

    function increaseCap(uint256 newCap) public {
        require(newCap > cap, "New cap must be higher than current cap");
        cap = newCap;
    }

    function refundRemaining(address payable recipient) public {
        require(balanceOf[msg.sender] > 0, "No balance to refund");
        uint256 amount = balanceOf[msg.sender];
        balanceOf[msg.sender] = 0;
        recipient.transfer(amount);
    }
}