// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InterestRateModel {
    function getBorrowRate(uint256 cash, uint256 borrows, uint256 reserves) external virtual returns (bool, uint256) {
        return (false, 0);
    }

    function isInterestRateModel() public virtual returns (bool) {
        return false;
    }
}

contract CustomInterestRateModel is InterestRateModel {
    function getBorrowRate(uint256 cash, uint256 borrows, uint256 reserves) external override returns (bool, uint256) {
        if (borrows == 0) {
            return (true, 0); // No borrows, no interest rate
        }

        uint256 utilizationRate = (borrows * 1e18) / (cash + borrows - reserves);
        uint256 borrowRate = (utilizationRate * 3) / 100; // Example formula, 3% base rate

        return (true, borrowRate);
    }

    function isInterestRateModel() public override returns (bool) {
        return true;
    }
}