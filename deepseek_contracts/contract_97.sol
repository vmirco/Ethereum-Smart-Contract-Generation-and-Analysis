// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RewardsDistribution {
    bool public isRewardsDistributor;
    bool public isFlywheel;

    struct Market {
        bool isActive;
        uint256 rewardsAccrued;
    }

    mapping(address => Market) public markets;
    mapping(address => uint256) public supplierRewards;
    mapping(address => uint256) public borrowerRewards;
    mapping(address => uint256) public transactorRewards;

    event MarketAdded(address market);
    event RewardsAccrued(address indexed user, uint256 amount);

    constructor(bool _isRewardsDistributor, bool _isFlywheel) {
        isRewardsDistributor = _isRewardsDistributor;
        isFlywheel = _isFlywheel;
    }

    function addMarket(address market) external {
        require(!markets[market].isActive, "Market already added");
        markets[market] = Market({isActive: true, rewardsAccrued: 0});
        emit MarketAdded(market);
    }

    function preSupplierAction(address supplier, uint256 amount) external {
        require(markets[msg.sender].isActive, "Market not active");
        supplierRewards[supplier] += amount;
        markets[msg.sender].rewardsAccrued += amount;
        emit RewardsAccrued(supplier, amount);
    }

    function preBorrowerAction(address borrower, uint256 amount) external {
        require(markets[msg.sender].isActive, "Market not active");
        borrowerRewards[borrower] += amount;
        markets[msg.sender].rewardsAccrued += amount;
        emit RewardsAccrued(borrower, amount);
    }

    function preTransferAction(address transactor, uint256 amount) external {
        require(markets[msg.sender].isActive, "Market not active");
        transactorRewards[transactor] += amount;
        markets[msg.sender].rewardsAccrued += amount;
        emit RewardsAccrued(transactor, amount);
    }

    function getAccruedRewards(address user) external view returns (uint256) {
        return supplierRewards[user] + borrowerRewards[user] + transactorRewards[user];
    }

    function getMarketState(address market) external view returns (bool, uint256) {
        return (markets[market].isActive, markets[market].rewardsAccrued);
    }
}