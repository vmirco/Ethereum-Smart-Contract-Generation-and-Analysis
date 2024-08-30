// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Router02 {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract NodeStaking {
    struct Node {
        uint256 stakeAmount;
        uint256 rewardRate;
        bool isActive;
    }

    struct User {
        uint256 stakedAmount;
        uint256 lastClaimTimestamp;
    }

    address public owner;
    Node public node;
    mapping(address => User) public users;
    IUniswapV2Router02 public uniswapRouter;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(address _uniswapRouter) {
        owner = msg.sender;
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
    }

    function initializeNode(uint256 _stakeAmount, uint256 _rewardRate) external onlyOwner {
        node = Node({
            stakeAmount: _stakeAmount,
            rewardRate: _rewardRate,
            isActive: true
        });
    }

    function stake() external payable {
        require(node.isActive, "Node is not active");
        require(msg.value >= node.stakeAmount, "Insufficient stake amount");

        User storage user = users[msg.sender];
        user.stakedAmount += msg.value;
        user.lastClaimTimestamp = block.timestamp;
    }

    function claimRewards() external {
        User storage user = users[msg.sender];
        require(user.stakedAmount > 0, "No stake to claim rewards");

        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No rewards to claim");

        user.lastClaimTimestamp = block.timestamp;
        payable(msg.sender).transfer(reward);
    }

    function calculateReward(address _user) public view returns (uint256) {
        User storage user = users[_user];
        if (user.stakedAmount == 0) return 0;

        uint256 timeSinceLastClaim = block.timestamp - user.lastClaimTimestamp;
        return (user.stakedAmount * node.rewardRate * timeSinceLastClaim) / 100;
    }

    function swapRewards(uint amountIn, uint amountOutMin, address[] calldata path, uint deadline) external {
        require(path[0] == address(this), "Invalid path");

        uint[] memory amounts = uniswapRouter.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            deadline
        );

        // Handle the amounts if necessary
    }
}