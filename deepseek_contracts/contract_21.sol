// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LogarithmCalculator {
    // Constants for logarithm calculation
    uint256 private constant LOG_E_2 = 69314718055994530941723212145817656807550013436025525412068000949339362196969; // ln(2) * 2^256 / 10^18
    uint256 private constant LOG_E_10 = 23025850929940456840179914546843642076011014886287729760333279009675726096773; // ln(10) * 2^256 / 10^18

    /**
     * @dev Calculates the natural logarithm of a given unsigned integer.
     * @param x The unsigned integer input value.
     * @return The natural logarithm of the input value.
     */
    function ln(uint256 x) public pure returns (int256) {
        require(x > 0, "Input must be greater than zero");

        if (x == 1) {
            return 0;
        }

        int256 res = 0;
        uint256 y = x;

        while (y > 1) {
            res += int256(LOG_E_2);
            y >>= 1;
        }

        return res / 10**18;
    }

    /**
     * @dev Calculates the base 10 logarithm of a given unsigned integer.
     * @param x The unsigned integer input value.
     * @return The base 10 logarithm of the input value.
     */
    function log10(uint256 x) public pure returns (int256) {
        require(x > 0, "Input must be greater than zero");

        if (x == 1) {
            return 0;
        }

        int256 res = 0;
        uint256 y = x;

        while (y > 1) {
            res += int256(LOG_E_10);
            y /= 10;
        }

        return res / 10**18;
    }
}

/*
Example usage:

1. Deploy the LogarithmCalculator contract.
2. Call the ln function with an unsigned integer input to get the natural logarithm.
3. Call the log10 function with an unsigned integer input to get the base 10 logarithm.

Note: The results are scaled by 10^18 to maintain precision. Divide by 10^18 to get the actual logarithm value.
*/