// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InvestmentPortfolio {
    address public owner;
    uint256 public totalInvestment;
    uint256 public totalReturns;
    uint256 public startTime;
    uint256 public constant RETURN_RATE = 1; // 1% return rate per block

    struct Investor {
        uint256 investment;
        uint256 lastWithdrawBlock;
    }

    mapping(address => Investor) public investors;

    event Deposited(address indexed investor, uint256 amount);
    event Withdrawn(address indexed investor, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        startTime = block.number;
    }

    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        Investor storage investor = investors[msg.sender];
        investor.investment += msg.value;
        totalInvestment += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function calculateReturns(address investorAddress) public view returns (uint256) {
        Investor storage investor = investors[investorAddress];
        uint256 blocksPassed = block.number - investor.lastWithdrawBlock;
        return (investor.investment * RETURN_RATE / 100) * blocksPassed;
    }

    function withdraw(uint256 amount) public {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        Investor storage investor = investors[msg.sender];
        uint256 availableReturns = calculateReturns(msg.sender);
        require(availableReturns >= amount, "Insufficient returns");

        investor.lastWithdrawBlock = block.number;
        totalReturns += amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function withdrawInvestment(uint256 amount) public {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        Investor storage investor = investors[msg.sender];
        require(investor.investment >= amount, "Insufficient investment");

        investor.investment -= amount;
        totalInvestment -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function emergencyWithdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}