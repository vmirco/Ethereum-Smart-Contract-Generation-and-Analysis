// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StakingRewards {
    struct User {
        uint256 balance;
        uint256 reward;
        uint256 lastUpdateTime;
    }

    struct Token {
        uint256 totalStaked;
        uint256 rewardRate;
        uint256 lastRewardTime;
    }

    mapping(address => User) public users;
    mapping(address => Token) public tokens;
    address[] public tokenList;

    function stake(address token, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        User storage user = users[msg.sender];
        Token storage tokenInfo = tokens[token];

        updateReward(msg.sender, token);
        user.balance += amount;
        tokenInfo.totalStaked += amount;
    }

    function withdraw(address token, uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        User storage user = users[msg.sender];
        Token storage tokenInfo = tokens[token];

        require(user.balance >= amount, "Insufficient balance");
        updateReward(msg.sender, token);
        user.balance -= amount;
        tokenInfo.totalStaked -= amount;
    }

    function claimReward(address token) external {
        User storage user = users[msg.sender];
        Token storage tokenInfo = tokens[token];

        updateReward(msg.sender, token);
        uint256 reward = user.reward;
        user.reward = 0;
        // Transfer reward to user (assuming internal minting or transfer mechanism)
    }

    function updateReward(address userAddress, address token) internal {
        User storage user = users[userAddress];
        Token storage tokenInfo = tokens[token];

        if (user.balance > 0) {
            uint256 timeSinceLastUpdate = block.timestamp - user.lastUpdateTime;
            uint256 reward = (user.balance * tokenInfo.rewardRate * timeSinceLastUpdate) / 1e18;
            user.reward += reward;
        }
        user.lastUpdateTime = block.timestamp;
        tokenInfo.lastRewardTime = block.timestamp;
    }

    function getLastRewardTime(address token) external view returns (uint256) {
        return tokens[token].lastRewardTime;
    }

    function getRewardRate(address token) external view returns (uint256) {
        return tokens[token].rewardRate;
    }

    function getRewardForDuration(address token, uint256 duration) external view returns (uint256) {
        Token storage tokenInfo = tokens[token];
        return (tokenInfo.totalStaked * tokenInfo.rewardRate * duration) / 1e18;
    }

    function addToken(address token, uint256 rewardRate) external {
        Token storage tokenInfo = tokens[token];
        require(tokenInfo.rewardRate == 0, "Token already added");

        tokenInfo.rewardRate = rewardRate;
        tokenList.push(token);
    }

    function mint(address to, uint256 amount) external {
        // Mint new tokens (assuming internal minting mechanism)
    }
}