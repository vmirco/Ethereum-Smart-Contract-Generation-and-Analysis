// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract TaxOffice {
    using SafeMath for uint256;

    address public pumpkin;
    address public wftm;
    address public uniRouter;
    address public operator;

    struct TaxTier {
        uint256 lowerLimit;
        uint256 upperLimit;
        uint256 taxRate;
    }

    TaxTier[] public taxTiers;
    mapping(address => bool) public taxExclusions;

    modifier onlyOperator() {
        require(msg.sender == operator, "Not the operator");
        _;
    }

    constructor(address _pumpkin, address _wftm, address _uniRouter) {
        pumpkin = _pumpkin;
        wftm = _wftm;
        uniRouter = _uniRouter;
        operator = msg.sender;
    }

    function setTaxTiers(uint256[] memory lowerLimits, uint256[] memory upperLimits, uint256[] memory taxRates) external onlyOperator {
        require(lowerLimits.length == upperLimits.length && lowerLimits.length == taxRates.length, "Array lengths mismatch");
        for (uint256 i = 0; i < taxTiers.length; i++) {
            taxTiers.pop();
        }
        for (uint256 i = 0; i < lowerLimits.length; i++) {
            taxTiers.push(TaxTier({
                lowerLimit: lowerLimits[i],
                upperLimit: upperLimits[i],
                taxRate: taxRates[i]
            }));
        }
    }

    function enableTaxExclusion(address excludedAddress) external onlyOperator {
        taxExclusions[excludedAddress] = true;
    }

    function disableTaxExclusion(address excludedAddress) external onlyOperator {
        taxExclusions[excludedAddress] = false;
    }

    function setOperator(address newOperator) external onlyOperator {
        operator = newOperator;
    }

    function getTaxRate(uint256 amount) public view returns (uint256) {
        for (uint256 i = 0; i < taxTiers.length; i++) {
            if (amount >= taxTiers[i].lowerLimit && amount <= taxTiers[i].upperLimit) {
                return taxTiers[i].taxRate;
            }
        }
        return 0; // Default tax rate if no tier matches
    }
}