// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenLending {
    using SafeMath for uint256;

    struct Loan {
        uint256 amount;
        uint256 interestRate;
        uint256 dueDate;
        bool repaid;
    }

    IERC20 public token;
    mapping(address => uint256) public balances;
    mapping(address => Loan) public loans;
    uint256 public totalDeposits;
    uint256 public totalLoans;
    uint256 public constant INTEREST_RATE = 5; // 5% interest rate

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    function deposit(uint256 _amount) external {
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        balances[msg.sender] = balances[msg.sender].add(_amount);
        totalDeposits = totalDeposits.add(_amount);
        emit Deposit(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        require(token.transfer(msg.sender, _amount), "Transfer failed");
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        totalDeposits = totalDeposits.sub(_amount);
        emit Withdraw(msg.sender, _amount);
    }

    function borrow(uint256 _amount) external {
        require(totalDeposits >= _amount, "Not enough deposits");
        require(loans[msg.sender].amount == 0, "Already borrowed");
        uint256 interest = _amount.mul(INTEREST_RATE).div(100);
        uint256 totalAmount = _amount.add(interest);
        require(token.transfer(msg.sender, _amount), "Transfer failed");
        loans[msg.sender] = Loan({
            amount: _amount,
            interestRate: INTEREST_RATE,
            dueDate: block.timestamp + 30 days,
            repaid: false
        });
        totalLoans = totalLoans.add(totalAmount);
        emit Borrow(msg.sender, _amount);
    }

    function repay() external {
        Loan storage loan = loans[msg.sender];
        require(loan.amount > 0, "No loan to repay");
        require(!loan.repaid, "Loan already repaid");
        uint256 totalAmount = loan.amount.add(loan.amount.mul(loan.interestRate).div(100));
        require(token.transferFrom(msg.sender, address(this), totalAmount), "Transfer failed");
        loan.repaid = true;
        totalLoans = totalLoans.sub(totalAmount);
        emit Repay(msg.sender, totalAmount);
    }
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
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