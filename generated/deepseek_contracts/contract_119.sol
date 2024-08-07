// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LiquidityPool {
    mapping(address => uint256) public balances;
    uint256 public totalSupply;
    address public owner;
    mapping(address => bool) public administrators;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event AdministratorSet(address indexed admin, bool isSet);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier onlyAdmin() {
        require(administrators[msg.sender], "Not an administrator");
        _;
    }

    constructor() {
        owner = msg.sender;
        administrators[msg.sender] = true;
    }

    function setAdministrator(address admin, bool isSet) external onlyOwner {
        administrators[admin] = isSet;
        emit AdministratorSet(admin, isSet);
    }

    function deposit(uint256 amount) external onlyAdmin {
        balances[msg.sender] += amount;
        totalSupply += amount;
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external onlyAdmin {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        totalSupply -= amount;
        emit Withdrawal(msg.sender, amount);
    }
}