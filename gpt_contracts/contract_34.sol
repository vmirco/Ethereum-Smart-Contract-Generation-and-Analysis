// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FeesManager {
    struct Fees {
        uint256 buyFee;
        uint256 sellFee;
        uint256 transferFee;
        uint256 gameFee;
    }

    uint256 public constant  maxTotalFee = 100; 
    Fees public fees;
    uint256 public revision = 0;

    event FeesChanged(uint256 revision, uint256 buyFee, uint256 sellFee, uint256 transferFee, uint256 gameFee);

    constructor(uint256 _buyFee, uint256 _sellFee, uint256 _transferFee, uint256 _gameFee) {
        require(_buyFee + _sellFee + _transferFee <= maxTotalFee, "Total fees should not exceed 100");
        fees = Fees({buyFee: _buyFee, sellFee: _sellFee, transferFee: _transferFee, gameFee: _gameFee});
    }

    function setFees(uint256 _buyFee, uint256 _sellFee, uint256 _transferFee, uint256 _gameFee) external {
        require(_buyFee + _sellFee + _transferFee <= maxTotalFee, "Total fees should not exceed 100");
        fees.buyFee = _buyFee;
        fees.sellFee = _sellFee;
        fees.transferFee = _transferFee;
        fees.gameFee = _gameFee;
        revision += 1;
        emit FeesChanged(revision, _buyFee, _sellFee, _transferFee, _gameFee);
    }

    function getFees() external view returns(uint256, uint256, uint256, uint256) {
        return (fees.buyFee, fees.sellFee, fees.transferFee, fees.gameFee);
    }
}