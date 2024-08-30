// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
}

contract ERC20 is Context {

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal {
        _name = name_;
        _symbol = symbol_;
    }
    
    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }
}

contract LendingContract is ERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;
    uint256 public totalSupply;
    uint256 public totalBorrowed;
    uint256 public interestRate;

    function deposit(uint256 amount) public {
        _balanceOf[msg.sender] = _balanceOf[msg.sender].add(amount);
        totalSupply = totalSupply.add(amount);
    }

    function withdraw(uint256 amount) public {
        require(_balanceOf[msg.sender] >= amount, "Not enough balance");
        _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(amount);
        totalSupply = totalSupply.sub(amount);
    }
    
    function borrow(uint256 amount) public {
        require(totalSupply.sub(totalBorrowed) >= amount, "Not enough tokens in the pool");
        borrows[msg.sender] = borrows[msg.sender].add(amount);
        totalBorrowed = totalBorrowed.add(amount);
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
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
        uint256 c = a / b;

        return c;
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");

        return a % b;
    }
}