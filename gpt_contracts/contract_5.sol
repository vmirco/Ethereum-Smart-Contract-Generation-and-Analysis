// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ARMOR {
    // Variables
    string public constant name = "ARMOR Token";
    string public constant symbol = "ARMOR";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    address public owner;

    // Mapping will hold the balance of the addresses
    mapping(address => uint256) public balanceOf;
    // Mapping will hold the allowance of spender allowed by token holder
    mapping(address => mapping(address => uint256)) public allowance;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Initializer
    constructor(uint256 total) {
        totalSupply = total;
        owner = msg.sender;
        balanceOf[owner] = totalSupply * 10 / 100;
        balanceOf[address(this)] = totalSupply * 90 / 100;
    }

    // Function to transfer tokens
    function transfer(address _to, uint256 _value) external returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // Function to approve spender by token holder
    function approve(address _spender, uint256 _value) external returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Function that is called when spender transfers tokens on token holder's behalf
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Not allowed to transfer this much amount");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    // Function to accept Ether
    receive() external payable {
        require(msg.sender != address(0), "Invalid sender address");
        uint256 tokenAmount = msg.value;
        require(balanceOf[address(this)] >= tokenAmount, "Insufficient token supply");
        balanceOf[address(this)] -= tokenAmount;
        balanceOf[msg.sender] += tokenAmount;
        emit Transfer(address(this), msg.sender, tokenAmount);
    }

    // Function to withdraw funds to owner's account
    function withdrawFunds() external {
        require(msg.sender == owner, "Only owner can withdraw");

        uint256 balance = address(this).balance;
        require(balance > 0, "No funds available");

        address payable payableOwner = payable(owner);
        payableOwner.transfer(balance);
    }

    // Function to kill contract
    function killContract() external {
        require(msg.sender == owner, "Only owner can kill the contract");
        selfdestruct(payable(owner));
    }
}