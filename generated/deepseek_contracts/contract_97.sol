// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RewardsDistribution {
    bool public isRewardsDistributor;
    bool public isFlywheel;

    struct Market {
        bool isActive;
        uint256 rewardsRate;
    }

    mapping(address => uint256) public accruedRewards;
    mapping(address => Market) public markets;

    event RewardsAccrued(address indexed account, uint256 amount);
    event MarketAdded(address indexed market, uint256 rewardsRate);

    constructor(bool _isRewardsDistributor, bool _isFlywheel) {
        isRewardsDistributor = _isRewardsDistributor;
        isFlywheel = _isFlywheel;
    }

    function preSupplierAction(address supplier, uint256 amount) external {
        require(markets[msg.sender].isActive, "Market not active");
        accrueRewards(supplier, amount);
    }

    function preBorrowerAction(address borrower, uint256 amount) external {
        require(markets[msg.sender].isActive, "Market not active");
        accrueRewards(borrower, amount);
    }

    function preTransferAction(address from, address to, uint256 amount) external {
        require(markets[msg.sender].isActive, "Market not active");
        accrueRewards(from, amount);
        accrueRewards(to, amount);
    }

    function accrueRewards(address account, uint256 amount) internal {
        uint256 rewards = (amount * markets[msg.sender].rewardsRate) / 1e18;
        accruedRewards[account] += rewards;
        emit RewardsAccrued(account, rewards);
    }

    function getAccruedRewards(address account) external view returns (uint256) {
        return accruedRewards[account];
    }

    function addMarket(address market, uint256 rewardsRate) external {
        markets[market] = Market({
            isActive: true,
            rewardsRate: rewardsRate
        });
        emit MarketAdded(market, rewardsRate);
    }

    function getMarketState(address market) external view returns (bool, uint256) {
        Market memory marketInfo = markets[market];
        return (marketInfo.isActive, marketInfo.rewardsRate);
    }
}