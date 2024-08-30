// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
}

contract TaxOffice {
    using SafeMath for uint256;

    address public pumpkin;
    address public wftm;
    address public uniRouter;
    mapping(address => bool) public taxExclusions;
    mapping(address => uint256) public taxTiers;

    address private owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor(address _pumpkin, address _wftm, address _uniRouter) {
        owner = msg.sender;
        pumpkin = _pumpkin;
        wftm = _wftm;
        uniRouter = _uniRouter;
    }

    function setTaxExclusion(address account, bool state) external onlyOwner {
        taxExclusions[account] = state;
    }

    function setTaxTier(address account, uint256 tier) external onlyOwner {
        taxTiers[account] = tier;
    }

}