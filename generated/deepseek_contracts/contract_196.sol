// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FeeManager {
    uint256 public constant MAX_FEE_RATE = 1000; // Maximum fee rate (1000 = 100%)
    uint256 public feeMakerRate;
    uint256 public feeTakerRate;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier validFeeRate(uint256 _rate) {
        require(_rate <= MAX_FEE_RATE, "Fee rate exceeds maximum allowed");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setFeeMakerRate(uint256 _rate) external onlyOwner validFeeRate(_rate) {
        feeMakerRate = _rate;
    }

    function setFeeTakerRate(uint256 _rate) external onlyOwner validFeeRate(_rate) {
        feeTakerRate = _rate;
    }
}