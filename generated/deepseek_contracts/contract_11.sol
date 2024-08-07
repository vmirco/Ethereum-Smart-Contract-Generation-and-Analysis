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

interface ISynthetixAdapter {
    function getPrice(address asset) external view returns (uint256);
}

interface IOptionMarket {
    function settleOption(address optionToken, uint256 optionId) external returns (uint256);
}

interface IOptionToken {
    function exercise(uint256 optionId) external;
}

contract OptionsMarketManager {
    IERC20 public baseCollateralToken;
    IERC20 public quoteCollateralToken;
    ISynthetixAdapter public synthetixAdapter;
    IOptionMarket public optionMarket;

    mapping(address => uint256) public collateralBalances;

    event CollateralDeposited(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);
    event PositionLiquidated(address indexed user, uint256 amount);

    constructor(
        address _baseCollateralToken,
        address _quoteCollateralToken,
        address _synthetixAdapter,
        address _optionMarket
    ) {
        baseCollateralToken = IERC20(_baseCollateralToken);
        quoteCollateralToken = IERC20(_quoteCollateralToken);
        synthetixAdapter = ISynthetixAdapter(_synthetixAdapter);
        optionMarket = IOptionMarket(_optionMarket);
    }

    function depositCollateral(address token, uint256 amount) external {
        require(token == address(baseCollateralToken) || token == address(quoteCollateralToken), "Invalid token");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        collateralBalances[msg.sender] += amount;
        emit CollateralDeposited(msg.sender, amount);
    }

    function withdrawCollateral(address token, uint256 amount) external {
        require(token == address(baseCollateralToken) || token == address(quoteCollateralToken), "Invalid token");
        require(collateralBalances[msg.sender] >= amount, "Insufficient balance");
        collateralBalances[msg.sender] -= amount;
        IERC20(token).transfer(msg.sender, amount);
        emit CollateralWithdrawn(msg.sender, amount);
    }

    function liquidatePosition(address user, address optionToken, uint256 optionId) external {
        uint256 collateralAmount = collateralBalances[user];
        require(collateralAmount > 0, "No collateral to liquidate");

        uint256 optionPrice = synthetixAdapter.getPrice(optionToken);
        require(optionPrice > collateralAmount, "Position is not undercollateralized");

        collateralBalances[user] = 0;
        IOptionToken(optionToken).exercise(optionId);
        emit PositionLiquidated(user, collateralAmount);
    }

    function settleOption(address optionToken, uint256 optionId) external {
        optionMarket.settleOption(optionToken, optionId);
    }
}