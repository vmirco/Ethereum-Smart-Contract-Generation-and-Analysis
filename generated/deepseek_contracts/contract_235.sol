// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PreventDelegateCall {
    address public owner;
    uint256 public tickCumulative;
    uint256 public secondsPerLiquidityCumulative;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function observe() external view returns (uint256, uint256) {
        return (tickCumulative, secondsPerLiquidityCumulative);
    }

    function updateTickCum(uint256 newTickCumulative, uint256 newSecondsPerLiquidityCumulative) external onlyOwner {
        tickCumulative = newTickCumulative;
        secondsPerLiquidityCumulative = newSecondsPerLiquidityCumulative;
    }

    fallback() external payable {
        revert("Delegate call not allowed");
    }

    receive() external payable {
        revert("Delegate call not allowed");
    }
}