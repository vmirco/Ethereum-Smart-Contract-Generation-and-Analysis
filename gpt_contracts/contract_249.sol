// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

contract MarketPositioning is Initializable, ReentrancyGuardUpgradeable, OwnableUpgradeable, PausableUpgradeable {
    struct Position {
        uint amount;
        uint price;
    }

    mapping(address => Position) private positions;
    mapping(address => uint) private fundingRates;
    address public feeReceiver;
    uint public indexPrice;

    function initialize() public initializer {
        __ReentrancyGuard_init();
        __Ownable_init();
        __Pausable_init();
    }

    function updatePosition(address trader, uint amount, uint price) external onlyOwner whenNotPaused {
        positions[trader] = Position(amount, price);
    }

    function settleFunding(address trader) external onlyOwner {
        uint fundingPaid = positions[trader].amount * fundingRates[trader] / 1e18;
        positions[trader].amount -= fundingPaid;
        payable(feeReceiver).transfer(fundingPaid);
    }

    function setDefaultFeeReceiver(address _feeReceiver) external onlyOwner {
        feeReceiver = _feeReceiver;
    }

    function updateIndexPrice(uint _indexPrice) external onlyOwner whenNotPaused {
        indexPrice = _indexPrice;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}