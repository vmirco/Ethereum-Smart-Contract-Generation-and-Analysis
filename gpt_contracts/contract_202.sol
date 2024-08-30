// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IERC20 {
    function totalSupply() public view virtual returns (uint256);
    function balanceOf(address account) public view virtual returns (uint256);
    function transfer(address recipient, uint256 amount) public virtual returns (bool);
    function allowance(address owner, address spender) public view virtual returns (uint256);
    function approve(address spender, uint256 amount) public virtual returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }
}

contract ERC20Basic is IERC20 {
    using SafeMath for uint256;
    string public constant name = "ERC20Basic";
    string public constant symbol = "BSC";
    uint8 public constant decimals = 18; // standard decimal adjustment
    uint public _totalSupply = 100 * 10**6 * 10**18; // total supply is 100 million tokens
    address public _owner;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;

    constructor() {
        _owner = msg.sender;
        balances[msg.sender] = _totalSupply;
    }

    function totalSupply() public view override returns (uint256) {
       return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
       return allowed[owner][spender];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
       require(amount <= balances[msg.sender]);
       balances[msg.sender] = balances[msg.sender].sub(amount);
       balances[recipient] = balances[recipient].add(amount);
       emit Transfer(msg.sender, recipient, amount);
       return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(amount <= balances[sender]);
        require(amount <= allowed[sender][msg.sender]);
        balances[sender] = balances[sender].sub(amount);
        balances[recipient] = balances[recipient].add(amount);
        allowed[sender][msg.sender] = allowed[sender][msg.sender].sub(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function mint(address account, uint256 amount) public returns (bool) {
        require(msg.sender == _owner, "Only owner can mint");
        require(_totalSupply.add(amount) <= 100000000 * 10**18, "Can't exceed total supply");
        _totalSupply = _totalSupply.add(amount);
        balances[account] = balances[account].add(amount);
        emit Transfer(address(0), account, amount);
        return true;
    }

    function burn(uint256 amount) public returns (bool) {
        require(msg.sender == _owner, "Only owner can burn");
        require(balances[msg.sender] >= amount, "Not enough balance to burn");
        _totalSupply = _totalSupply.sub(amount);
        balances[msg.sender] = balances[msg.sender].sub(amount);
        emit Transfer(msg.sender, address(0), amount);
        return true;
    }

    function transferOwnership(address newOwner) public returns (bool) {
        require(msg.sender == _owner, "Only owner can transfer ownership");
        _owner = newOwner;
        return true;
    }
}