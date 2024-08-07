// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RevenueSharing {
    struct Investor {
        uint256 totalInvestment;
        uint256 lastWithdrawal;
        uint256 pendingIncome;
        bool isActive;
    }

    mapping(address => Investor) public investors;
    address[] public investorList;
    uint256 public totalInvestments;
    uint256 public totalWithdrawals;
    uint256 public dailyIncomeRate; // in wei per investment unit

    modifier onlyActiveInvestor() {
        require(investors[msg.sender].isActive, "Not an active investor");
        _;
    }

    modifier onlyNonActiveInvestor() {
        require(!investors[msg.sender].isActive, "Already an active investor");
        _;
    }

    constructor(uint256 _dailyIncomeRate) {
        dailyIncomeRate = _dailyIncomeRate;
    }

    function deposit() public payable onlyNonActiveInvestor {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        if (!investors[msg.sender].isActive) {
            investors[msg.sender].isActive = true;
            investorList.push(msg.sender);
        }
        investors[msg.sender].totalInvestment += msg.value;
        totalInvestments += msg.value;
        distributeDailyIncome();
    }

    function withdraw(uint256 amount) public onlyActiveInvestor {
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(amount <= investors[msg.sender].pendingIncome, "Insufficient balance");
        investors[msg.sender].pendingIncome -= amount;
        totalWithdrawals += amount;
        payable(msg.sender).transfer(amount);
        distributeDailyIncome();
    }

    function distributeDailyIncome() internal {
        for (uint256 i = 0; i < investorList.length; i++) {
            address investorAddress = investorList[i];
            if (investors[investorAddress].isActive) {
                uint256 daysSinceLastWithdrawal = (block.timestamp - investors[investorAddress].lastWithdrawal) / 1 days;
                if (daysSinceLastWithdrawal > 0) {
                    uint256 income = daysSinceLastWithdrawal * dailyIncomeRate * investors[investorAddress].totalInvestment;
                    investors[investorAddress].pendingIncome += income;
                    investors[investorAddress].lastWithdrawal = block.timestamp;
                }
            }
        }
    }

    function getInvestorBalance(address investor) public view returns (uint256) {
        return investors[investor].pendingIncome;
    }

    function getTotalInvestments() public view returns (uint256) {
        return totalInvestments;
    }

    function getTotalWithdrawals() public view returns (uint256) {
        return totalWithdrawals;
    }
}