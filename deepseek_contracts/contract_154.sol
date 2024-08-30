// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract IERC20 {
    function totalSupply() public view virtual returns (uint256);
    function balanceOf(address account) public view virtual returns (uint256);
    function transfer(address recipient, uint256 amount) public virtual returns (bool);
    function allowance(address owner, address spender) public view virtual returns (uint256);
    function approve(address spender, uint256 amount) public virtual returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 is IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
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
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
}

contract NodeRewardsToken is ERC20 {
    address public owner;
    address public uniswapV2Router;
    uint256 public swapTokensAmount;
    mapping(address => bool) public isBlacklisted;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(address _uniswapV2Router) ERC20("NodeRewardsToken", "NRT") {
        owner = msg.sender;
        uniswapV2Router = _uniswapV2Router;
        swapTokensAmount = 1000 * 10**18; // Example amount
    }

    function blacklistAddress(address account, bool value) external onlyOwner {
        isBlacklisted[account] = value;
    }

    function updateUniswapV2Router(address newAddress) external onlyOwner {
        uniswapV2Router = newAddress;
    }

    function updateSwapTokensAmount(uint256 newAmount) external onlyOwner {
        swapTokensAmount = newAmount;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(!isBlacklisted[sender] && !isBlacklisted[recipient], "Blacklisted address");
        super._transfer(sender, recipient, amount);
    }
}