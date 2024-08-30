// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DepositTracker {
    using SafeMath for uint256;

    address public owner;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public profits;
    uint256 public totalDeposits;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function depositFunds() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        deposits[msg.sender] = deposits[msg.sender].add(msg.value);
        totalDeposits = totalDeposits.add(msg.value);
    }

    function addF1Deposit(address f1Address, uint256 amount) public onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        deposits[f1Address] = deposits[f1Address].add(amount);
        totalDeposits = totalDeposits.add(amount);
    }

    function addNetworkDeposit(address networkAddress, uint256 amount) public onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        deposits[networkAddress] = deposits[networkAddress].add(amount);
        totalDeposits = totalDeposits.add(amount);
    }

    function getDepositedAmount(address user) public view returns (uint256) {
        return deposits[user];
    }

    function getTotalDeposits() public view returns (uint256) {
        return totalDeposits;
    }

    function updateProfit(address user, uint256 profitAmount) public onlyOwner {
        require(profitAmount > 0, "Profit amount must be greater than 0");
        profits[user] = profits[user].add(profitAmount);
    }

    function getProfit(address user) public view returns (uint256) {
        return profits[user];
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}