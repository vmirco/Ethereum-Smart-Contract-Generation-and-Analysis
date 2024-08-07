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

interface ILendingPool {
    function deposit(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
    function withdraw(address asset, uint256 amount, address to) external returns (uint256);
    function getReserveData(address asset) external view returns (ReserveData memory);
    struct ReserveData {
        uint256 configuration;
        uint128 liquidityIndex;
        uint128 variableBorrowIndex;
        uint128 currentLiquidityRate;
        uint128 currentVariableBorrowRate;
        uint128 currentStableBorrowRate;
        uint40 lastUpdateTimestamp;
        address aTokenAddress;
        address stableDebtTokenAddress;
        address variableDebtTokenAddress;
        uint8 id;
    }
}

contract DelayedProtocolParameters {
    address public admin;
    ILendingPool public lendingPool;
    uint256 public constant DELAY_PERIOD = 86400; // 24 hours
    uint256 public lastUpdateTimestamp;
    uint256 public proposedParameter;
    uint256 public committedParameter;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    constructor(address _lendingPoolAddress) {
        admin = msg.sender;
        lendingPool = ILendingPool(_lendingPoolAddress);
    }

    function proposeParameter(uint256 newParameter) external onlyAdmin {
        proposedParameter = newParameter;
        lastUpdateTimestamp = block.timestamp;
    }

    function commitParameter() external onlyAdmin {
        require(block.timestamp >= lastUpdateTimestamp + DELAY_PERIOD, "Delay period not yet passed");
        committedParameter = proposedParameter;
        proposedParameter = 0;
    }

    function getCurrentParameter() external view returns (uint256) {
        return committedParameter;
    }

    function getProposedParameter() external view returns (uint256) {
        return proposedParameter;
    }

    function getRemainingDelayTime() external view returns (uint256) {
        if (block.timestamp >= lastUpdateTimestamp + DELAY_PERIOD) {
            return 0;
        }
        return (lastUpdateTimestamp + DELAY_PERIOD) - block.timestamp;
    }
}