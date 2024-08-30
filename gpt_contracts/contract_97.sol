pragma solidity ^0.8.0;

contract RewardMarket {
    struct Market {
        bool isListed;
        uint totalSupply;
        uint totalBorrows;
    }

    mapping(address => Market) public markets;
    mapping(address => uint) public accruedRewards;

    bool public isRewardsDistributor;
    bool public isFlywheel;

    constructor(bool _isRewardsDistributor, bool _isFlywheel) {
        isRewardsDistributor = _isRewardsDistributor;
        isFlywheel = _isFlywheel;
    }

    event MarketCreated(address asset, bool isListed);
    event RewardsAccrued(address user, uint amount);

    function addMarket(address asset) public {
        markets[asset] = Market(true, 0, 0);
        emit MarketCreated(asset, true);
    }

    function preSupplierAction(address asset, address supplier, uint amount) public {
        require(markets[asset].isListed == true, "Market is not listed");
        markets[asset].totalSupply += amount;
        accruedRewards[supplier] += amount;
        emit RewardsAccrued(supplier, amount);
    }

    function preBorrowerAction(address asset, address borrower, uint amount) public {
        require(markets[asset].isListed == true, "Market is not listed");
        markets[asset].totalBorrows += amount;
        accruedRewards[borrower] += amount;
        emit RewardsAccrued(borrower, amount);
    }

    function preTransferAction(address asset, address sender, address recipient, uint amount) public {
        require(markets[asset].isListed == true, "Market is not listed");
        accruedRewards[sender] += amount;
        accruedRewards[recipient] += amount;
        emit RewardsAccrued(sender, amount);
        emit RewardsAccrued(recipient, amount);
    }

    function getAccruedRewards(address user) public view returns (uint) {
        return accruedRewards[user];
    }
}