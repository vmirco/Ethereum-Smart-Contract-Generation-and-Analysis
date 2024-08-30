// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IUniswapV2Router {
    function addLiquidity(address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline)
    external
    returns (uint amountA, uint amountB, uint liquidity);
}

interface IMasterChef {
    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
    function userInfo(uint256, address) external view returns (uint256, uint256);
}

contract MyDeFiProtocol {
    address private rewardToken;
    address private lpToken;
    address private masterchef;
    IUniswapV2Router public unirouter;

    constructor(address _rewardToken, address _lpToken, address _unirouter, address _masterchef) {
        rewardToken = _rewardToken;
        lpToken = _lpToken;
        unirouter = IUniswapV2Router(_unirouter);
        masterchef = _masterchef;
    }

    function deposit(uint256 _pid, uint256 _amount) public {
        IERC20(lpToken).transferFrom(msg.sender, address(this), _amount);
        IMasterChef(masterchef).deposit(_pid, _amount);
    }

    // Function to harvest the earned rewards from the MasterChef contract
    function harvest(uint256 _pid) public {
        IMasterChef(masterchef).withdraw(_pid, 0);
    }

    function previewDeposit(uint256 _pid) public view returns (uint256, uint256) {
        (uint256 amount, ) = IMasterChef(masterchef).userInfo(_pid, address(this));
        return (IERC20(lpToken).balanceOf(address(this)), amount);
    }

    function totalAssets() public view returns (uint256) {
        return IERC20(lpToken).balanceOf(address(this));
    }
}