// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LendingPoolParameters {

    struct Parameters {
        uint256 optimalUtilizationRate;
        uint256 baseVariableBorrowRate;
        uint256 variableRateSlope1;
        uint256 variableRateSlope2;
    }

    address public owner;

    Parameters public liveParameters;
    Parameters public stagedParameters;

    uint256 public stageTimestamp;
    uint256 public delayDuration = 24 hours;
    
    constructor(uint256 _optimalUtilizationRate,
                uint256 _baseVariableBorrowRate,
                uint256 _variableRateSlope1,
                uint256 _variableRateSlope2) {
        owner = msg.sender;
        
        liveParameters = Parameters({
            optimalUtilizationRate: _optimalUtilizationRate,
            baseVariableBorrowRate: _baseVariableBorrowRate,
            variableRateSlope1: _variableRateSlope1,
            variableRateSlope2: _variableRateSlope2
        });
    }
    
    function stageParameters(uint256 _optimalUtilizationRate,
                             uint256 _baseVariableBorrowRate,
                             uint256 _variableRateSlope1,
                             uint256 _variableRateSlope2) public {
        require(msg.sender == owner, "Caller is not the owner");
        
        stagedParameters = Parameters({
            optimalUtilizationRate: _optimalUtilizationRate,
            baseVariableBorrowRate: _baseVariableBorrowRate,
            variableRateSlope1: _variableRateSlope1,
            variableRateSlope2: _variableRateSlope2
        });

        stageTimestamp = block.timestamp;
    }

    function commitParameters() public {
        require(msg.sender == owner, "Caller is not the owner");
        require(block.timestamp >= stageTimestamp + delayDuration, "Not eligible to commit changes yet");

        liveParameters = stagedParameters;
    }
}