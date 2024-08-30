// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ERC20 contract interface
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

// SafeMath library
library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
}

contract LendingBorrowingContract {
    using SafeMath for uint256;

    IERC20 public token;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrowings;
    uint256 public totalDeposits;
    uint256 public totalBorrowings;
    uint256 public interestRate = 5; // 5% interest rate

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    function deposit(uint256 amount) public {
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        deposits[msg.sender] += amount;
        totalDeposits += amount;
    }

    function withdraw(uint256 amount) public {
        require(deposits[msg.sender] >= amount, "Insufficient deposits");
        require(token.transfer(msg.sender, amount), "Transfer failed");
        deposits[msg.sender] -= amount;
        totalDeposits -= amount;
    }

    function borrow(uint256 amount) public {
        require(totalDeposits >= totalBorrowings + amount, "Not enough liquidity");
        borrowings[msg.sender] += amount;
        totalBorrowings += amount;
        require(token.transfer(msg.sender, amount), "Transfer failed");
    }

    function repay(uint256 amount) public {
        require(borrowings[msg.sender] >= amount, "Repayment exceeds borrowings");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        borrowings[msg.sender] -= amount;
        totalBorrowings -= amount;
    }

    function calculateInterest(address borrower) public view returns (uint256) {
        return borrowings[borrower] * interestRate / 100;
    }
}