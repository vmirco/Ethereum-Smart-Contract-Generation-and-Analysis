// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LiquidityPoolManager {
    mapping(address => uint256) public poolBalances;
    uint256 public totalSupply;
    mapping(address => bool) public administrators;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event AdministratorSet(address indexed admin, bool isAdmin);

    modifier onlyAdmin() {
        require(administrators[msg.sender], "Not an administrator");
        _;
    }

    constructor() {
        administrators[msg.sender] = true;
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        poolBalances[msg.sender] += amount;
        totalSupply += amount;
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(poolBalances[msg.sender] >= amount, "Insufficient balance");
        poolBalances[msg.sender] -= amount;
        totalSupply -= amount;
        emit Withdrawal(msg.sender, amount);
    }

    function setAdministrator(address admin, bool isAdmin) external onlyAdmin {
        administrators[admin] = isAdmin;
        emit AdministratorSet(admin, isAdmin);
    }
}