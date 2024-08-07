// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TaxOffice {
    using SafeMath for uint256;

    address public pumpkin;
    address public wftm;
    address public uniRouter;

    struct TaxTier {
        uint256 lowerBound;
        uint256 upperBound;
        uint256 taxRate;
    }

    TaxTier[] public taxTiers;
    mapping(address => bool) public taxExclusions;
    mapping(address => bool) public authorizedOperators;

    event TaxTierSet(uint256 indexed tierIndex, uint256 lowerBound, uint256 upperBound, uint256 taxRate);
    event TaxExclusionSet(address indexed account, bool excluded);
    event OperatorSet(address indexed operator, bool authorized);

    modifier onlyOperator() {
        require(authorizedOperators[msg.sender], "Not an authorized operator");
        _;
    }

    constructor(address _pumpkin, address _wftm, address _uniRouter) {
        pumpkin = _pumpkin;
        wftm = _wftm;
        uniRouter = _uniRouter;
        authorizedOperators[msg.sender] = true;
    }

    function setTaxTier(uint256 _tierIndex, uint256 _lowerBound, uint256 _upperBound, uint256 _taxRate) external onlyOperator {
        require(_tierIndex < taxTiers.length, "Invalid tier index");
        taxTiers[_tierIndex] = TaxTier(_lowerBound, _upperBound, _taxRate);
        emit TaxTierSet(_tierIndex, _lowerBound, _upperBound, _taxRate);
    }

    function addTaxTier(uint256 _lowerBound, uint256 _upperBound, uint256 _taxRate) external onlyOperator {
        taxTiers.push(TaxTier(_lowerBound, _upperBound, _taxRate));
        emit TaxTierSet(taxTiers.length - 1, _lowerBound, _upperBound, _taxRate);
    }

    function setTaxExclusion(address _account, bool _excluded) external onlyOperator {
        taxExclusions[_account] = _excluded;
        emit TaxExclusionSet(_account, _excluded);
    }

    function setOperator(address _operator, bool _authorized) external onlyOperator {
        authorizedOperators[_operator] = _authorized;
        emit OperatorSet(_operator, _authorized);
    }

    function getTaxRate(uint256 _value) public view returns (uint256) {
        for (uint256 i = 0; i < taxTiers.length; i++) {
            if (_value >= taxTiers[i].lowerBound && _value <= taxTiers[i].upperBound) {
                return taxTiers[i].taxRate;
            }
        }
        return 0;
    }

    function isExcluded(address _account) public view returns (bool) {
        return taxExclusions[_account];
    }
}

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