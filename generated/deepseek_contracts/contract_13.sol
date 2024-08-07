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

interface IMasterChef {
    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
    function userInfo(uint256 _pid, address _user) external view returns (uint256 amount, uint256 rewardDebt);
    function pendingReward(uint256 _pid, address _user) external view returns (uint256);
}

interface IUniswapV2Router02 {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}

contract RewardManager {
    address public rewardToken;
    address public unirouter;
    address public masterchef;
    uint256 public pid;

    constructor(address _rewardToken, address _unirouter, address _masterchef, uint256 _pid) {
        rewardToken = _rewardToken;
        unirouter = _unirouter;
        masterchef = _masterchef;
        pid = _pid;
    }

    function harvestRewards() external {
        (uint256 amount,) = IMasterChef(masterchef).userInfo(pid, address(this));
        IMasterChef(masterchef).withdraw(pid, amount);
        uint256 pending = IMasterChef(masterchef).pendingReward(pid, address(this));
        IERC20(rewardToken).transfer(msg.sender, pending);
    }

    function deposit(uint256 amount) external {
        IERC20(rewardToken).transferFrom(msg.sender, address(this), amount);
        IERC20(rewardToken).approve(masterchef, amount);
        IMasterChef(masterchef).deposit(pid, amount);
    }

    function previewDeposit(uint256 amount) external view returns (uint256) {
        (uint256 currentAmount,) = IMasterChef(masterchef).userInfo(pid, address(this));
        return currentAmount + amount;
    }

    function totalAssets() external view returns (uint256) {
        (uint256 amount,) = IMasterChef(masterchef).userInfo(pid, address(this));
        return amount;
    }
}