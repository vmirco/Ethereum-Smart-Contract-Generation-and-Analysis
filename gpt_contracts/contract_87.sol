// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MLM {

    struct Investor {
        bool active;
        uint totalInvested;
        uint totalWithdrawn; 
        uint totalIncome;
        uint depositTime;
        uint investmentsCount;
        mapping(uint => Investment) investments;
    }

    struct Investment {
        uint amount;
        uint at;
    }

    uint public totalInvestors;
    uint public totalInvested;
    uint public totalWithdrew;
    mapping(address => Investor) public investors;

    event NewDeposit(address indexed investor, uint amount);
    event NewWithdrawal(address indexed investor, uint amount);

    function deposit() public payable {
        require(msg.value > 0, "Investment can't be zero");

        Investor storage investor = investors[msg.sender];
        if (!investor.active) {
            investor.active = true;
            totalInvestors++;
        }

        investor.depositTime = block.timestamp;
        investor.totalInvested += msg.value;
        investor.investments[investor.investmentsCount++] = Investment(msg.value, block.timestamp);
        totalInvested += msg.value;

        emit NewDeposit(msg.sender, msg.value);
    }

    function withdraw(uint amount) public {
        require(amount > 0, "Withdrawal can't be zero");

        Investor storage investor = investors[msg.sender];
        require(investor.totalIncome + amount <= investor.totalInvested * 1.5, "Can't withdraw more than 150%");

        _payout(msg.sender);
        require(amount <= investor.totalIncome, "Insufficient funds");

        investor.totalIncome -= amount;
        investor.totalWithdrawn += amount;
        totalWithdrew += amount;
        payable(msg.sender).transfer(amount);

        emit NewWithdrawal(msg.sender, amount);
    }

    function _payout(address _addr) internal {
        Investor storage investor = investors[_addr];

        for (uint i = 0; i < investor.investmentsCount; i++) {
            uint timeEnd = investor.investments[i].at + 600;
            uint period = block.timestamp < timeEnd ? block.timestamp : timeEnd;
            uint p = (period - investor.depositTime) / 1 days;
            investor.totalIncome += p * investor.investments[i].amount;
            investor.depositTime += p * 1 days;
        }
    }

    function calculateIncome(address _addr) public view returns(uint) {
        Investor storage investor = investors[_addr];
        uint totalIncome = investor.totalIncome;
        for (uint i = 0; i < investor.investmentsCount; i++) {
            uint timeEnd = investor.investments[i].at + 600;
            uint period = block.timestamp < timeEnd ? block.timestamp : timeEnd;

            if (investor.depositTime < period) {
                uint p = (period - investor.depositTime) / 1 days;
                totalIncome += p * investor.investments[i].amount;
            }
        }

        return totalIncome;
    }
}