// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FundTracker {
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

    function deposit() public payable {
        deposits[msg.sender] = deposits[msg.sender].add(msg.value);
        totalDeposits = totalDeposits.add(msg.value);
    }

    function addF1Deposit(address _user, uint256 _amount) public onlyOwner {
        deposits[_user] = deposits[_user].add(_amount);
        totalDeposits = totalDeposits.add(_amount);
    }

    function addNetworkDeposit(address _user, uint256 _amount) public onlyOwner {
        deposits[_user] = deposits[_user].add(_amount);
        totalDeposits = totalDeposits.add(_amount);
    }

    function getDeposit(address _user) public view returns (uint256) {
        return deposits[_user];
    }

    function getTotalDeposits() public view returns (uint256) {
        return totalDeposits;
    }

    function updateProfit(address _user, uint256 _profit) public onlyOwner {
        profits[_user] = profits[_user].add(_profit);
    }

    function getProfit(address _user) public view returns (uint256) {
        return profits[_user];
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