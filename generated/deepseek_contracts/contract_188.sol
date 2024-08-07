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

    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        User storage user = users[msg.sender];
        user.deposit = user.deposit.add(msg.value);
        user.lastDepositTime = block.timestamp;
        totalDeposits = totalDeposits.add(msg.value);
        updateRates(msg.sender);
        emit DepositCreated(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        User storage user = users[msg.sender];
        require(amount > 0 && amount <= user.deposit, "Invalid withdrawal amount");
        user.deposit = user.deposit.sub(amount);
        totalDeposits = totalDeposits.sub(amount);
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    function updateRates(address userAddress) internal {
        User storage user = users[userAddress];
        if (user.deposit >= 100 ether) {
            user.marketingRate = 5;
            user.commissionRate = 3;
        } else if (user.deposit >= 50 ether) {
            user.marketingRate = 3;
            user.commissionRate = 2;
        } else {
            user.marketingRate = 1;
            user.commissionRate = 1;
        }
    }

    function calculateContractBalanceRate() public view returns (uint256) {
        return address(this).balance.mul(100).div(totalDeposits);
    }

    function calculateLeaderBonusRate() public view returns (uint256) {
        return calculateContractBalanceRate().mul(2);
    }

    function calculateCommunityBonusRate() public view returns (uint256) {
        return calculateContractBalanceRate().mul(1);
    }

    function payBonus(address userAddress, string memory bonusType) internal {
        User storage user = users[userAddress];
        uint256 bonusAmount;
        if (keccak256(abi.encodePacked(bonusType)) == keccak256(abi.encodePacked("leader"))) {
            bonusAmount = user.deposit.mul(leaderBonusRate).div(100);
        } else if (keccak256(abi.encodePacked(bonusType)) == keccak256(abi.encodePacked("community"))) {
            bonusAmount = user.deposit.mul(communityBonusRate).div(100);
        }
        payable(userAddress).transfer(bonusAmount);
        emit BonusPaid(userAddress, bonusAmount, bonusType);
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