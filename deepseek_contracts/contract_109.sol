// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CoverPool {
    address public owner;
    uint256 public currentEpoch;
    uint256 public epochPrice;
    uint256 public cumulativeProfit;
    uint256 public totalShare;
    uint256 public unwithdrawnCoverTokens;

    struct Epoch {
        uint256 epochId;
        uint256 startBlock;
        uint256 endBlock;
        uint256 totalTokens;
        uint256 totalShares;
        mapping(address => uint256) shares;
        mapping(address => uint256) claimedProfit;
    }

    mapping(uint256 => Epoch) public epochs;
    mapping(address => uint256) public userBalances;

    event EpochStarted(uint256 epochId, uint256 startBlock, uint256 endBlock);
    event TokensAdded(address indexed user, uint256 amount);
    event TokensWithdrawn(address indexed user, uint256 amount);
    event ProfitClaimed(address indexed user, uint256 amount);
    event EpochWithdrawn(address indexed user, uint256 epochId, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        currentEpoch = 1;
        epochPrice = 1 ether; // Example price
    }

    function startNewEpoch(uint256 _endBlock) external onlyOwner {
        Epoch storage epoch = epochs[currentEpoch];
        epoch.epochId = currentEpoch;
        epoch.startBlock = block.number;
        epoch.endBlock = _endBlock;
        emit EpochStarted(currentEpoch, block.number, _endBlock);
        currentEpoch++;
    }

    function setEpochPrice(uint256 _newPrice) external onlyOwner {
        epochPrice = _newPrice;
    }

    function addTokens(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");
        userBalances[msg.sender] += _amount;
        totalShare += _amount;
        epochs[currentEpoch].totalTokens += _amount;
        epochs[currentEpoch].shares[msg.sender] += _amount;
        emit TokensAdded(msg.sender, _amount);
    }

    function withdrawTokens(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");
        require(userBalances[msg.sender] >= _amount, "Insufficient balance");
        userBalances[msg.sender] -= _amount;
        totalShare -= _amount;
        epochs[currentEpoch].totalTokens -= _amount;
        epochs[currentEpoch].shares[msg.sender] -= _amount;
        emit TokensWithdrawn(msg.sender, _amount);
    }

    function claimProfit() external {
        uint256 profit = calculateProfit(msg.sender);
        require(profit > 0, "No profit to claim");
        epochs[currentEpoch].claimedProfit[msg.sender] += profit;
        cumulativeProfit -= profit;
        emit ProfitClaimed(msg.sender, profit);
    }

    function withdrawFromEpoch(uint256 _epochId) external {
        require(_epochId < currentEpoch, "Epoch not yet ended");
        Epoch storage epoch = epochs[_epochId];
        uint256 shares = epoch.shares[msg.sender];
        require(shares > 0, "No shares in this epoch");
        uint256 amount = (shares * epoch.totalTokens) / epoch.totalShares;
        epoch.shares[msg.sender] = 0;
        unwithdrawnCoverTokens += amount;
        emit EpochWithdrawn(msg.sender, _epochId, amount);
    }

    function calculateProfit(address _user) internal view returns (uint256) {
        uint256 userShares = epochs[currentEpoch].shares[_user];
        if (userShares == 0) return 0;
        uint256 totalProfit = cumulativeProfit;
        return (userShares * totalProfit) / totalShare;
    }
}