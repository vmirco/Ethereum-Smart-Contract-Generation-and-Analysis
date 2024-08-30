// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RevenueSharing {
    struct Investor {
        uint256 totalInvestment;
        uint256 lastWithdrawal;
        uint256 pendingIncome;
        address referrer;
    }

    mapping(address => Investor) public investors;
    mapping(address => bool) public isInvestor;
    address public owner;
    uint256 public totalInvestments;
    uint256 public dailyIncomeRate = 1; // 1% daily income rate

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyInvestor() {
        require(isInvestor[msg.sender], "Not an investor");
        _;
    }

    event Deposit(address indexed investor, uint256 amount);
    event Withdrawal(address indexed investor, uint256 amount);
    event Investment(address indexed investor, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        if (!isInvestor[msg.sender]) {
            investors[msg.sender] = Investor({
                totalInvestment: msg.value,
                lastWithdrawal: block.timestamp,
                pendingIncome: 0,
                referrer: address(0)
            });
            isInvestor[msg.sender] = true;
        } else {
            investors[msg.sender].totalInvestment += msg.value;
        }
        totalInvestments += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function invest(address _referrer) external payable onlyInvestor {
        require(msg.value > 0, "Investment amount must be greater than 0");
        investors[msg.sender].totalInvestment += msg.value;
        investors[msg.sender].referrer = _referrer;
        totalInvestments += msg.value;
        emit Investment(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external onlyInvestor {
        require(amount > 0, "Withdrawal amount must be greater than 0");
        updatePendingIncome(msg.sender);
        require(investors[msg.sender].pendingIncome >= amount, "Insufficient balance");
        investors[msg.sender].pendingIncome -= amount;
        investors[msg.sender].lastWithdrawal = block.timestamp;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    function updatePendingIncome(address investor) internal {
        uint256 daysSinceLastWithdrawal = (block.timestamp - investors[investor].lastWithdrawal) / 1 days;
        if (daysSinceLastWithdrawal > 0) {
            uint256 dailyIncome = (investors[investor].totalInvestment * dailyIncomeRate) / 100;
            investors[investor].pendingIncome += dailyIncome * daysSinceLastWithdrawal;
        }
    }

    function setDailyIncomeRate(uint256 rate) external onlyOwner {
        dailyIncomeRate = rate;
    }

    function getPendingIncome(address investor) external view returns (uint256) {
        uint256 daysSinceLastWithdrawal = (block.timestamp - investors[investor].lastWithdrawal) / 1 days;
        uint256 dailyIncome = (investors[investor].totalInvestment * dailyIncomeRate) / 100;
        return investors[investor].pendingIncome + (dailyIncome * daysSinceLastWithdrawal);
    }
}