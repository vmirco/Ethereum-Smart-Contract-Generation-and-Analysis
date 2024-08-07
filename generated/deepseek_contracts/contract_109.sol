// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CoverPool {
    address public owner;
    uint256 public totalShares;
    uint256 public cumulativeProfit;
    uint256 public totalUnwithdrawnCoverTokens;
    uint256 public currentEpoch;
    uint256 public epochPrice;

    struct Epoch {
        uint256 startBlock;
        uint256 endBlock;
        uint256 totalTokens;
        uint256 totalShares;
        uint256 price;
        bool isActive;
    }

    mapping(uint256 => Epoch) public epochs;
    mapping(address => uint256) public userShares;
    mapping(address => uint256) public userUnclaimedProfit;
    mapping(address => uint256) public userUnwithdrawnCoverTokens;

    event EpochStarted(uint256 epoch, uint256 startBlock, uint256 endBlock, uint256 price);
    event TokensAdded(address indexed user, uint256 amount);
    event TokensWithdrawn(address indexed user, uint256 amount);
    event ProfitClaimed(address indexed user, uint256 amount);
    event EpochTokensWithdrawn(address indexed user, uint256 epoch, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        currentEpoch = 1;
    }

    function startNewEpoch(uint256 _endBlock, uint256 _price) external onlyOwner {
        require(_endBlock > block.number, "End block must be in the future");
        epochs[currentEpoch] = Epoch({
            startBlock: block.number,
            endBlock: _endBlock,
            totalTokens: 0,
            totalShares: 0,
            price: _price,
            isActive: true
        });
        epochPrice = _price;
        emit EpochStarted(currentEpoch, block.number, _endBlock, _price);
        currentEpoch++;
    }

    function addTokens(uint256 _amount) external {
        require(epochs[currentEpoch - 1].isActive, "Current epoch is not active");
        userShares[msg.sender] += _amount;
        totalShares += _amount;
        epochs[currentEpoch - 1].totalTokens += _amount;
        epochs[currentEpoch - 1].totalShares += _amount;
        emit TokensAdded(msg.sender, _amount);
    }

    function withdrawTokens(uint256 _amount) external {
        require(userShares[msg.sender] >= _amount, "Insufficient shares");
        userShares[msg.sender] -= _amount;
        totalShares -= _amount;
        userUnwithdrawnCoverTokens[msg.sender] += _amount;
        totalUnwithdrawnCoverTokens += _amount;
        emit TokensWithdrawn(msg.sender, _amount);
    }

    function claimProfit() external {
        uint256 profit = userUnclaimedProfit[msg.sender];
        require(profit > 0, "No profit to claim");
        userUnclaimedProfit[msg.sender] = 0;
        cumulativeProfit -= profit;
        payable(msg.sender).transfer(profit);
        emit ProfitClaimed(msg.sender, profit);
    }

    function withdrawEpochTokens(uint256 _epoch) external {
        require(_epoch < currentEpoch, "Epoch not yet ended");
        uint256 tokens = userUnwithdrawnCoverTokens[msg.sender];
        require(tokens > 0, "No tokens to withdraw");
        userUnwithdrawnCoverTokens[msg.sender] = 0;
        totalUnwithdrawnCoverTokens -= tokens;
        payable(msg.sender).transfer(tokens);
        emit EpochTokensWithdrawn(msg.sender, _epoch, tokens);
    }

    receive() external payable {
        cumulativeProfit += msg.value;
        distributeProfit();
    }

    function distributeProfit() internal {
        uint256 profitPerShare = cumulativeProfit / totalShares;
        for (uint256 i = 0; i < currentEpoch; i++) {
            if (epochs[i].isActive) {
                for (uint256 j = 0; j < epochs[i].totalShares; j++) {
                    address user = address(j);
                    userUnclaimedProfit[user] += profitPerShare * userShares[user];
                }
            }
        }
    }
}