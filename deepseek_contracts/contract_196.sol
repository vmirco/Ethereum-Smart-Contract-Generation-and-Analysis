// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FeeManager {
    uint public constant MAX_FEE_RATE = 10000; // Maximum fee rate (e.g., 10000 for 100%)
    uint public feeMakerRate;
    uint public feeTakerRate;

    event FeeMakerRateSet(uint newRate);
    event FeeTakerRateSet(uint newRate);

    constructor(uint _feeMakerRate, uint _feeTakerRate) {
        require(_feeMakerRate <= MAX_FEE_RATE, "Fee rate exceeds maximum allowed");
        require(_feeTakerRate <= MAX_FEE_RATE, "Fee rate exceeds maximum allowed");
        feeMakerRate = _feeMakerRate;
        feeTakerRate = _feeTakerRate;
    }

    function setFeeMakerRate(uint _newRate) external {
        require(_newRate <= MAX_FEE_RATE, "Fee rate exceeds maximum allowed");
        feeMakerRate = _newRate;
        emit FeeMakerRateSet(_newRate);
    }

    function setFeeTakerRate(uint _newRate) external {
        require(_newRate <= MAX_FEE_RATE, "Fee rate exceeds maximum allowed");
        feeTakerRate = _newRate;
        emit FeeTakerRateSet(_newRate);
    }
}