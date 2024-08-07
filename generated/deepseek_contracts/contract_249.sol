// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract MarketPositioning is Initializable, PausableUpgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable {
    struct Trader {
        uint256 position;
        uint256 lastFundingTime;
    }

    mapping(address => Trader) public traders;
    address public defaultFeeReceiver;
    uint256 public fundingRate;
    uint256 public indexPrice;

    event FundingSettled(address indexed trader, uint256 amount);
    event DefaultFeeReceiverUpdated(address indexed newReceiver);
    event IndexPriceUpdated(uint256 newPrice);

    function initialize(address _defaultFeeReceiver, uint256 _fundingRate, uint256 _indexPrice) public initializer {
        __Pausable_init();
        __ReentrancyGuard_init();
        __Ownable_init();
        defaultFeeReceiver = _defaultFeeReceiver;
        fundingRate = _fundingRate;
        indexPrice = _indexPrice;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function settleFunding(address trader) public whenNotPaused nonReentrant {
        Trader storage traderInfo = traders[trader];
        uint256 timeSinceLastFunding = block.timestamp - traderInfo.lastFundingTime;
        uint256 fundingAmount = traderInfo.position * fundingRate * timeSinceLastFunding;
        traderInfo.lastFundingTime = block.timestamp;
        emit FundingSettled(trader, fundingAmount);
    }

    function setDefaultFeeReceiver(address newReceiver) public onlyOwner {
        defaultFeeReceiver = newReceiver;
        emit DefaultFeeReceiverUpdated(newReceiver);
    }

    function updateIndexPrice(uint256 newPrice) public onlyOwner {
        indexPrice = newPrice;
        emit IndexPriceUpdated(newPrice);
    }

    function updateFundingRate(uint256 newRate) public onlyOwner {
        fundingRate = newRate;
    }
}