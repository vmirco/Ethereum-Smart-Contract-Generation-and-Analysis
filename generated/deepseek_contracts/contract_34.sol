// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FeeManager {
    struct Fees {
        uint256 buyFee;
        uint256 sellFee;
        uint256 transferFee;
        uint256 gameFee;
    }

    Fees public currentFees;
    uint256 public revisionCount;

    event FeesUpdated(uint256 indexed revision, uint256 buyFee, uint256 sellFee, uint256 transferFee, uint256 gameFee);

    constructor(uint256 _buyFee, uint256 _sellFee, uint256 _transferFee, uint256 _gameFee) {
        require(_buyFee + _sellFee + _transferFee <= 10000, "Total fees exceed limit");
        currentFees = Fees(_buyFee, _sellFee, _transferFee, _gameFee);
        revisionCount = 1;
        emit FeesUpdated(revisionCount, _buyFee, _sellFee, _transferFee, _gameFee);
    }

    function setFees(uint256 _buyFee, uint256 _sellFee, uint256 _transferFee, uint256 _gameFee) external {
        require(_buyFee + _sellFee + _transferFee <= 10000, "Total fees exceed limit");
        currentFees = Fees(_buyFee, _sellFee, _transferFee, _gameFee);
        revisionCount += 1;
        emit FeesUpdated(revisionCount, _buyFee, _sellFee, _transferFee, _gameFee);
    }

    function getFees() external view returns (uint256, uint256, uint256, uint256) {
        return (currentFees.buyFee, currentFees.sellFee, currentFees.transferFee, currentFees.gameFee);
    }
}