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
    uint256 public revisionCounter;

    event FeesUpdated(uint256 buyFee, uint256 sellFee, uint256 transferFee, uint256 gameFee, uint256 revision);

    constructor(uint256 _buyFee, uint256 _sellFee, uint256 _transferFee, uint256 _gameFee) {
        require(_buyFee + _sellFee + _transferFee + _gameFee <= 10000, "Total fees exceed 100%");
        currentFees = Fees(_buyFee, _sellFee, _transferFee, _gameFee);
        revisionCounter = 1;
        emit FeesUpdated(_buyFee, _sellFee, _transferFee, _gameFee, revisionCounter);
    }

    function setFees(uint256 _buyFee, uint256 _sellFee, uint256 _transferFee, uint256 _gameFee) external {
        require(_buyFee + _sellFee + _transferFee + _gameFee <= 10000, "Total fees exceed 100%");
        currentFees = Fees(_buyFee, _sellFee, _transferFee, _gameFee);
        revisionCounter++;
        emit FeesUpdated(_buyFee, _sellFee, _transferFee, _gameFee, revisionCounter);
    }

    function getFees() external view returns (uint256, uint256, uint256, uint256) {
        return (currentFees.buyFee, currentFees.sellFee, currentFees.transferFee, currentFees.gameFee);
    }
}