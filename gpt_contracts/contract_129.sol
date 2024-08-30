// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC20Token {
    // Mapping of address balance
    mapping (address => uint256) private _balances;

    // Mapping of approvals
    mapping (address => mapping (address => uint256)) private _allowances;

    // Token Details
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    address private _owner;

    // Events
    event Transfer(address indexed sender, address indexed recipient, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    constructor(string memory name_, string memory symbol_, uint256 totalSupply_) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = totalSupply_;
        _balances[msg.sender] = _totalSupply;
        _owner = msg.sender;
    }

    // Return name of token
    function name() public view returns (string memory) {
        return _name;
    }

    // Return symbol of token
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    // Return total supply of token
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // Return balance of given address
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    // Transfer token to a specific address
    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(msg.sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[msg.sender] >= amount, "ERC20: transfer amount exceeds balance");
 
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);

        return true;
    }

    // Allow spender to withdraw from your account
    function approve(address spender, uint256 amount) public returns (bool) {
        require(spender != address(0), "ERC20: approval to the zero address");

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // Return allowance of spender
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    // Transfer with approval
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        require(_allowances[sender][msg.sender] >= amount, "ERC20: transfer amount exceeds allowance");

        _balances[sender] -= amount;
        _allowances[sender][msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);

        return true;
    }    
}