// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FreezableToken {
    mapping (address => uint256) private _balances;
    mapping (address => bool) private _frozenAccounts;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    address private _owner;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event FrozenAccounts(address target, bool frozen);
    event Burn(address indexed from, uint256 value);

    constructor(uint256 initialSupply) {
        _totalSupply = initialSupply;
        _balances[msg.sender] = initialSupply;
        _owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == _owner, "Only owner can call this function.");
        _;
    }

    modifier notFrozen {
        require(!_frozenAccounts[msg.sender], "Account is frozen.");
        _;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public notFrozen returns (bool) {
        require(recipient != address(0), "Transfer to the zero address");
        require(_balances[msg.sender] >= amount, "Insufficient balance.");

        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public notFrozen returns (bool) {
        require(spender != address(0), "Approval to the zero address");

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public notFrozen returns (bool) {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(_balances[sender] >= amount, "Insufficient balance.");
        require(_allowances[sender][msg.sender] >= amount, "Transfer amount exceeds allowance");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        _allowances[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function freezeAccount(address target) public onlyOwner {
        _frozenAccounts[target] = true;
        emit FrozenAccounts(target, true);
    }

    function unfreezeAccount(address target) public onlyOwner {
        _frozenAccounts[target] = false;
        emit FrozenAccounts(target, false);
    }

    function burn(uint256 amount) public onlyOwner returns (bool success) {
        require(_balances[msg.sender] >= amount, "Insufficient balance.");
        _balances[msg.sender] -= amount;
        _totalSupply -= amount;
        emit Burn(msg.sender, amount);
        return true;
    }
}