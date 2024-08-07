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
        uint256 lastClaimTime;
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

    function stake(uint256 amount) external {
        require(node.isActive, "Node is not active");
        require(amount >= node.stakeAmount, "Insufficient stake amount");

        User storage user = users[msg.sender];
        user.stakedAmount += amount;
        user.lastClaimTime = block.timestamp;
    }

    function claimRewards() external {
        User storage user = users[msg.sender];
        require(user.stakedAmount > 0, "No staked amount");

        uint256 timeSinceLastClaim = block.timestamp - user.lastClaimTime;
        uint256 rewards = (user.stakedAmount * node.rewardRate * timeSinceLastClaim) / 1 days;

        user.lastClaimTime = block.timestamp;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = msg.sender;

        uniswapRouter.swapExactTokensForTokens(
            rewards,
            0,
            path,
            msg.sender,
            block.timestamp + 15 minutes
        );
    }

    function getNodeData() external view returns (uint256, uint256, bool) {
        return (node.stakeAmount, node.rewardRate, node.isActive);
    }
}