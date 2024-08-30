// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InvestmentContract {
    struct Investor {
        uint256 deposit;
        uint256 lastDepositTime;
        uint256 referralEarnings;
        address referrer;
    }

    mapping(address => Investor) public investors;
    uint256 public totalInvestments;
    uint256 public dailyLimit;
    uint256 public interestRate;
    uint256 public referralBonusRate;

    event Invested(address indexed investor, uint256 amount);
    event Withdrawn(address indexed investor, uint256 amount);
    event ReferralEarned(address indexed referrer, address indexed investor, uint256 amount);

    constructor(uint256 _dailyLimit, uint256 _interestRate, uint256 _referralBonusRate) {
        dailyLimit = _dailyLimit;
        interestRate = _interestRate;
        referralBonusRate = _referralBonusRate;
    }

    function invest(address _referrer) public payable {
        require(msg.value > 0, "Investment amount must be greater than zero");
        require(investors[msg.sender].lastDepositTime + 24 hours <= block.timestamp, "Daily investment limit reached");

        Investor storage investor = investors[msg.sender];
        investor.deposit += msg.value;
        investor.lastDepositTime = block.timestamp;
        totalInvestments += msg.value;

        if (_referrer != address(0) && _referrer != msg.sender) {
            investors[_referrer].referralEarnings += (msg.value * referralBonusRate) / 100;
            emit ReferralEarned(_referrer, msg.sender, (msg.value * referralBonusRate) / 100);
        }

        emit Invested(msg.sender, msg.value);
    }

    function withdraw() public {
        Investor storage investor = investors[msg.sender];
        uint256 totalEarnings = calculateEarnings(msg.sender);
        require(totalEarnings > 0, "No earnings to withdraw");

        investor.deposit = 0;
        investor.lastDepositTime = block.timestamp;
        investor.referralEarnings = 0;

        payable(msg.sender).transfer(totalEarnings);
        emit Withdrawn(msg.sender, totalEarnings);
    }

    function calculateEarnings(address _investor) public view returns (uint256) {
        Investor storage investor = investors[_investor];
        uint256 depositTime = block.timestamp - investor.lastDepositTime;
        uint256 interestEarnings = (investor.deposit * interestRate * depositTime) / (100 * 365 days);
        return interestEarnings + investor.referralEarnings;
    }
}