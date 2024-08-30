// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyToken {
    mapping(address => uint256) private _balances;
    mapping(address => mapping (address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    address public owner;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
        owner = msg.sender;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(
            _balances[msg.sender] >= amount,
            "Not enough balance to transfer."
        );
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        return true;
    }

    function allow(address spender, uint256 amount) public returns (bool) {
        _allowances[msg.sender][spender] = amount;
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function burn(uint256 amount) public {
        require(
            _balances[msg.sender] >= amount,
            "Not enough balance to burn."
        );
        _balances[msg.sender] -= amount;
        _totalSupply -= amount;
    }

    function mint(address account, uint256 amount) public {
        require(
            msg.sender == owner,
            "Only owner can mint tokens."
        );
        _balances[account] += amount;
        _totalSupply += amount;
    }
}