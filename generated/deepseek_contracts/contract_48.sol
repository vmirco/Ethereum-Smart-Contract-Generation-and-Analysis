// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StakingRewards {
    IERC20 public rewardToken;
    mapping(address => mapping(address => uint256)) public stakedBalances;
    mapping(address => mapping(address => uint256)) public rewards;
    mapping(address => uint256) public lastRewardUpdate;
    uint256 public rewardRate;
    uint256 public constant REWARD_INTERVAL = 1 days;

    constructor(address _rewardToken, uint256 _rewardRate) {
        rewardToken = IERC20(_rewardToken);
        rewardRate = _rewardRate;
    }

    function stake(address token, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        stakedBalances[msg.sender][token] += amount;
        updateReward(msg.sender, token);
    }

    function withdraw(address token, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(stakedBalances[msg.sender][token] >= amount, "Insufficient staked balance");
        stakedBalances[msg.sender][token] -= amount;
        IERC20(token).transfer(msg.sender, amount);
        updateReward(msg.sender, token);
    }

    function claimReward(address token) external {
        updateReward(msg.sender, token);
        uint256 reward = rewards[msg.sender][token];
        if (reward > 0) {
            rewards[msg.sender][token] = 0;
            rewardToken.transfer(msg.sender, reward);
        }
    }

    function updateReward(address user, address token) internal {
        if (lastRewardUpdate[token] == 0) {
            lastRewardUpdate[token] = block.timestamp;
        }
        if (stakedBalances[user][token] > 0) {
            uint256 timeSinceLastUpdate = block.timestamp - lastRewardUpdate[token];
            uint256 reward = (stakedBalances[user][token] * rewardRate * timeSinceLastUpdate) / REWARD_INTERVAL;
            rewards[user][token] += reward;
        }
        lastRewardUpdate[token] = block.timestamp;
    }

    function getLastRewardUpdate(address token) external view returns (uint256) {
        return lastRewardUpdate[token];
    }

    function getRewardRate() external view returns (uint256) {
        return rewardRate;
    }

    function getRewardForDuration(address token, uint256 duration) external view returns (uint256) {
        return (stakedBalances[msg.sender][token] * rewardRate * duration) / REWARD_INTERVAL;
    }

    function mintRewardTokens(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        rewardToken.transfer(address(this), amount);
    }
}