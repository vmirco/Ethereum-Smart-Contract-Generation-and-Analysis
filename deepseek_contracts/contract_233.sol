// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TronReferral {
    address public owner;
    mapping(address => address) public referrals;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public referralEarnings;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event ReferralSet(address indexed user, address indexed referral);
    event ReferralEarned(address indexed user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setReferral(address _referral) external {
        require(referrals[msg.sender] == address(0), "Referral already set");
        require(_referral != msg.sender, "Cannot refer yourself");
        referrals[msg.sender] = _referral;
        emit ReferralSet(msg.sender, _referral);
    }

    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        balances[msg.sender] += msg.value;
        if (referrals[msg.sender] != address(0)) {
            uint256 referralBonus = msg.value / 10; // 10% bonus
            referralEarnings[referrals[msg.sender]] += referralBonus;
            emit ReferralEarned(referrals[msg.sender], referralBonus);
        }
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        emit Withdrawal(msg.sender, amount);
    }

    function withdrawReferralEarnings() external {
        uint256 earnings = referralEarnings[msg.sender];
        require(earnings > 0, "No referral earnings to withdraw");
        referralEarnings[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: earnings}("");
        require(success, "Transfer failed");
        emit Withdrawal(msg.sender, earnings);
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        owner = newOwner;
    }
}