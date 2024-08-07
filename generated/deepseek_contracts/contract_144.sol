// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InterestRateModel {
    function isInterestRateModel() external pure returns (bool) {
        return true;
    }
}

contract CustomInterestRateModel is InterestRateModel {
    function calculateInterestRate(uint256 cash, uint256 borrows, uint256 reserves) external view returns (bool, uint256) {
        if (cash == 0 || borrows == 0) {
            return (false, 0);
        }

        uint256 utilizationRate = (borrows * 1e18) / (cash + borrows - reserves);
        uint256 baseRate = 2 * 1e16; // 2% base rate
        uint256 multiplier = 4 * 1e16; // 4% multiplier

        uint256 rate = baseRate + (multiplier * utilizationRate) / 1e18;

        return (true, rate);
    }

    function isInterestRateModel() external pure override returns (bool) {
        return true;
    }
}