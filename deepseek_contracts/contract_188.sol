// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InvestmentPlatform {
    using SafeMath for uint256;

    struct User {
        uint256 deposit;
        uint256 lastDepositTime;
        uint256 marketingRate;
        uint256 commissionRate;
    }

    mapping(address => User) public users;
    uint256 public totalDeposits;
    uint256 public contractBalanceRate;
    uint256 public leaderBonusRate;
    uint256 public communityBonusRate;

    event DepositCreated(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event BonusPaid(address indexed user, uint256 amount, string bonusType);

    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        User storage user = users[msg.sender];
        user.deposit = user.deposit.add(msg.value);
        user.lastDepositTime = block.timestamp;
        totalDeposits = totalDeposits.add(msg.value);
        emit DepositCreated(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public {
        User storage user = users[msg.sender];
        require(amount > 0 && amount <= user.deposit, "Invalid withdrawal amount");
        user.deposit = user.deposit.sub(amount);
        totalDeposits = totalDeposits.sub(amount);
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    function calculateBonus(address userAddress) internal view returns (uint256) {
        User storage user = users[userAddress];
        uint256 timeSinceLastDeposit = block.timestamp.sub(user.lastDepositTime);
        uint256 bonus = user.deposit.mul(contractBalanceRate.add(leaderBonusRate).add(communityBonusRate)).mul(timeSinceLastDeposit).div(365 days);
        return bonus;
    }

    function payBonus(address userAddress) public {
        uint256 bonus = calculateBonus(userAddress);
        require(bonus > 0, "No bonus available");
        payable(userAddress).transfer(bonus);
        emit BonusPaid(userAddress, bonus, "General");
    }

    function setRates(uint256 _contractBalanceRate, uint256 _leaderBonusRate, uint256 _communityBonusRate) public {
        contractBalanceRate = _contractBalanceRate;
        leaderBonusRate = _leaderBonusRate;
        communityBonusRate = _communityBonusRate;
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
}