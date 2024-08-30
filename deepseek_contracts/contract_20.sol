// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenSwap {
    string public name = "TokenSwap";
    address public admin;
    uint256 public totalLiquidity;
    uint256 public adminFee;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event AddLiquidity(address indexed provider, uint256 amount);
    event RemoveLiquidity(address indexed provider, uint256 amount);
    event Swap(address indexed user, uint256 amountIn, uint256 amountOut);

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not the admin");
        _;
    }

    function addLiquidity(uint256 amount) external onlyAdmin {
        require(amount > 0, "Amount must be greater than 0");
        balances[msg.sender] += amount;
        totalLiquidity += amount;
        emit AddLiquidity(msg.sender, amount);
    }

    function removeLiquidity(uint256 amount) external onlyAdmin {
        require(amount > 0, "Amount must be greater than 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        totalLiquidity -= amount;
        emit RemoveLiquidity(msg.sender, amount);
    }

    function swap(uint256 amountIn, uint256 amountOut) external {
        require(amountIn > 0 && amountOut > 0, "Amounts must be greater than 0");
        require(balances[msg.sender] >= amountIn, "Insufficient balance");

        uint256 fee = (amountIn * adminFee) / 10000;
        uint256 amountInAfterFee = amountIn - fee;

        balances[msg.sender] -= amountIn;
        balances[msg.sender] += amountOut;
        adminFee += fee;

        emit Swap(msg.sender, amountIn, amountOut);
    }

    function setAdminFee(uint256 newFee) external onlyAdmin {
        require(newFee >= 0, "Fee must be non-negative");
        adminFee = newFee;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        require(balances[msg.sender] >= value, "Insufficient balance");
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(balances[from] >= value, "Insufficient balance");
        require(allowances[from][msg.sender] >= value, "Allowance too low");
        balances[from] -= value;
        balances[to] += value;
        allowances[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }
}