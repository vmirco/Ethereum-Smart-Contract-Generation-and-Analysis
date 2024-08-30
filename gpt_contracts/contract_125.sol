// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapper {
    function swapTokens(address tokenA, address tokenB, uint256 amount) external;
}

contract PucieToken is IERC20 {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFees;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint256 private _taxFee;
    address private _feeRecipient;
    ISwapper private _swapper;

    constructor(address swapper, address feeRecipient, uint256 taxFee) {
        _name = 'PucieToken';
        _symbol = 'PTK';
        _swapper = ISwapper(swapper);
        _feeRecipient = feeRecipient;
        _taxFee = taxFee;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);
        return true; 
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");

        uint256 taxAmount = 0;
        if (!_isExcludedFromFees[sender]) {
            taxAmount = amount * _taxFee / 100;
            _balances[_feeRecipient] += taxAmount;
            emit Transfer(sender, _feeRecipient, taxAmount);
        }

        _balances[sender] -= amount;
        _balances[recipient] += amount - taxAmount;
        emit Transfer(sender, recipient, amount - taxAmount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function swapTokens(address tokenA, address tokenB, uint256 amount) public {
        require(_balances[msg.sender] >= amount, "ERC20: swap amount exceeds balance");
        
        _balances[msg.sender] -= amount;
        _swapper.swapTokens(tokenA, tokenB, amount);
    }

    function excludeFromFees(address account) public {
        _isExcludedFromFees[account] = true;
    }
}