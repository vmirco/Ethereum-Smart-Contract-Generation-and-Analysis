// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NotDelegateCall {
    address public owner;
    int public tickCumulative;
    uint256 public secondsPerLiquidityCumulative;
    
    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    modifier noDelegateCall {
        require(msg.sender == tx.origin, "No delegate calls.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function observe() public view returns (int, uint256) {
        return (tickCumulative, secondsPerLiquidityCumulative);
    }

    function updateTickCum(int _tickCumulative, uint256 _secondsPerLiquidityCumulative) public onlyOwner noDelegateCall {
        tickCumulative = _tickCumulative;
        secondsPerLiquidityCumulative = _secondsPerLiquidityCumulative;
    }
}