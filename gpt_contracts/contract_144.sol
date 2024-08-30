// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract InterestRateModel {

    function isInterestRateModel() external virtual pure returns (bool) {
        return false;
    }

    function getBorrowRate(uint cash, uint borrows, uint reserves) external virtual pure returns (bool, uint);
}

contract ExtendedInterestRateModel is InterestRateModel {
    uint public baseRatePerYear;
    uint public multiplierPerYear;

    constructor(uint baseRatePerYear_, uint multiplierPerYear_) {
        baseRatePerYear = baseRatePerYear_;
        multiplierPerYear = multiplierPerYear_;
    }

    function isInterestRateModel() external pure override returns (bool) {
        return true;
    }

    function getBorrowRate(uint cash, uint borrows, uint reserves) external pure override returns (bool, uint) {
        uint utilizationRate = (borrows * 1e18) / (cash + borrows - reserves);

        if (utilizationRate > 0.9 ether)
            return (false, 0);

        uint normalRate = (baseRatePerYear + utilizationRate * multiplierPerYear) / 1e18;

        return (true, normalRate);
    }
}