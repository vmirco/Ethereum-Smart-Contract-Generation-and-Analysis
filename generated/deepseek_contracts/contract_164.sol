// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InvestmentPlatform {
    struct Investor {
        uint256 deposit;
        uint256 lastDepositTime;
        uint256 totalEarned;
        address referrer;
    }

    mapping(address => Investor) public investors;
    address[] public investorList;
    uint256 public totalInvested;
    uint256 public constant INTEREST_RATE = 5; // 5% annual interest rate
    uint256 public constant REFERRAL_BONUS = 2; // 2% referral bonus
    uint256 public constant MAX_DAILY_INVESTMENT = 1000 ether;
    uint256 public constant DIVIDEND_RATE = 10; // 10% of total invested

    event Deposit(address indexed investor, uint256 amount);
    event Withdraw(address indexed investor, uint256 amount);
    event ReferralEarned(address indexed referrer, address indexed investor, uint256 amount);
    event DividendPaid(address indexed investor, uint256 amount);

    function deposit(address referrer) public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        require(msg.value <= MAX_DAILY_INVESTMENT, "Exceeds daily investment limit");

        Investor storage investor = investors[msg.sender];
        if (investor.lastDepositTime == 0) {
            investorList.push(msg.sender);
        } else {
            require(block.timestamp > investor.lastDepositTime + 1 days, "Can only deposit once per day");
        }

        investor.deposit += msg.value;
        investor.lastDepositTime = block.timestamp;
        totalInvested += msg.value;

        if (referrer != address(0) && referrer != msg.sender) {
            investors[referrer].totalEarned += (msg.value * REFERRAL_BONUS) / 100;
            emit ReferralEarned(referrer, msg.sender, (msg.value * REFERRAL_BONUS) / 100);
        }

        emit Deposit(msg.sender, msg.value);
    }

    function calculateInterest(address investorAddress) public view returns (uint256) {
        Investor storage investor = investors[investorAddress];
        uint256 timeElapsed = block.timestamp - investor.lastDepositTime;
        uint256 interest = (investor.deposit * INTEREST_RATE * timeElapsed) / (365 days * 100);
        return interest;
    }

    function withdraw() public {
        Investor storage investor = investors[msg.sender];
        uint256 interest = calculateInterest(msg.sender);
        uint256 totalAmount = investor.deposit + interest;

        require(totalAmount > 0, "No funds to withdraw");

        investor.deposit = 0;
        investor.totalEarned += interest;
        payable(msg.sender).transfer(totalAmount);

        emit Withdraw(msg.sender, totalAmount);
    }

    function payDividends() public {
        uint256 totalDividends = (totalInvested * DIVIDEND_RATE) / 100;
        require(totalDividends > 0, "No dividends to pay");

        for (uint256 i = 0; i < investorList.length; i++) {
            address investorAddress = investorList[i];
            Investor storage investor = investors[investorAddress];
            uint256 dividend = (investor.deposit * totalDividends) / totalInvested;
            investor.totalEarned += dividend;
            payable(investorAddress).transfer(dividend);
            emit DividendPaid(investorAddress, dividend);
        }
    }
}