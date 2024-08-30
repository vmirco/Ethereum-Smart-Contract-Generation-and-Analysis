// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract IERC20 {
    function totalSupply() public virtual view returns (uint256);
    function balanceOf(address account) public virtual view returns (uint256);
    function transfer(address recipient, uint256 amount) public virtual returns (bool);
    function allowance(address owner, address spender) public virtual view returns (uint256);
    function approve(address spender, uint256 amount) public virtual returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Token is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address public owner;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    
    uint256 private _totalSupply;
    uint256 public feePercent;
    
    modifier onlyOwner() {
        require(owner == msg.sender, "You are not the owner");
        _;
    }
    
    constructor (string memory name_, string memory symbol_, uint8 decimals_, uint256 totalSupply_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_;
        _balances[msg.sender] = _totalSupply;
        
        owner = msg.sender;
        feePercent = 3;
    }
    
    function name() public view virtual returns (string memory) {
        return _name;
    }
    
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
    
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "Transfer amount exceeds allowance");
        _transfer(sender, recipient, amount);
        
        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "Transfer from the zero address is not allowed");
        require(recipient != address(0), "Transfer to the zero address is not allowed");
        require(_balances[sender] >= amount, "Transfer amount exceeds balance");
        
        uint256 fee = 0;
        if(_isExcludedFromFee[sender] == false) {
            fee = amount * feePercent / 100;
            _balances[owner] += fee;
        }
        
        _balances[sender] -= amount;
        _balances[recipient] += amount - fee;
        
        emit Transfer(sender, recipient, amount - fee);
    }
    
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function setFeePercent(uint256 feePercent_) public onlyOwner returns (bool) {
        feePercent = feePercent_;
        return true;
    }
    
    function excludeFromFee(address account, bool excluded) public onlyOwner returns (bool) {
        _isExcludedFromFee[account] = excluded;
        return true;
    }
}