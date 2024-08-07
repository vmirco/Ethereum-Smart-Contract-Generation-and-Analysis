// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InvestmentPortfolio {
    address public owner;
    uint256 public totalInvestment;
    uint256 public startTime;
    uint256 public constant INTEREST_RATE_PER_BLOCK = 1e14; // 0.0001% per block

    mapping(address => uint256) public investments;
    mapping(address => uint256) public lastUpdateBlock;
    mapping(address => uint256) public accumulatedRewards;

    event Deposit(address indexed investor, uint256 amount);
    event Withdraw(address indexed investor, uint256 amount);
    event EarningsWithdrawn(address indexed investor, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        startTime = block.number;
    }

    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        if (investments[msg.sender] == 0) {
            lastUpdateBlock[msg.sender] = block.number;
        }
        updateRewards(msg.sender);
        investments[msg.sender] += msg.value;
        totalInvestment += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(investments[msg.sender] >= amount, "Insufficient balance");
        updateRewards(msg.sender);
        investments[msg.sender] -= amount;
        totalInvestment -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    function withdrawEarnings() external {
        updateRewards(msg.sender);
        uint256 earnings = accumulatedRewards[msg.sender];
        require(earnings > 0, "No earnings to withdraw");
        accumulatedRewards[msg.sender] = 0;
        payable(msg.sender).transfer(earnings);
        emit EarningsWithdrawn(msg.sender, earnings);
    }

    function updateRewards(address investor) internal {
        if (investments[investor] > 0) {
            uint256 blocksSinceLastUpdate = block.number - lastUpdateBlock[investor];
            uint256 newRewards = (investments[investor] * INTEREST_RATE_PER_BLOCK * blocksSinceLastUpdate) / 1e18;
            accumulatedRewards[investor] += newRewards;
        }
        lastUpdateBlock[investor] = block.number;
    }

    function getInvestorInfo(address investor) external view returns (uint256 investment, uint256 rewards) {
        return (investments[investor], accumulatedRewards[investor]);
    }
}