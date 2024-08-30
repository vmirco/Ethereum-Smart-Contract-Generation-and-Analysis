// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MarketPositioning {
    address public owner;
    bool public paused;
    mapping(address => uint256) public fundingRates;
    address public defaultFeeReceiver;
    mapping(address => uint256) public indexPrices;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    constructor() {
        owner = msg.sender;
        paused = false;
    }

    function pause() external onlyOwner {
        paused = true;
    }

    function unpause() external onlyOwner {
        paused = false;
    }

    function setFundingRate(address trader, uint256 rate) external onlyOwner whenNotPaused {
        fundingRates[trader] = rate;
    }

    function settleFunding(address trader) external whenNotPaused {
        // Implementation for settling funding
    }

    function setDefaultFeeReceiver(address receiver) external onlyOwner whenNotPaused {
        defaultFeeReceiver = receiver;
    }

    function updateIndexPrice(address oracle, uint256 price) external onlyOwner whenNotPaused {
        indexPrices[oracle] = price;
    }

    function liquidatePosition(address trader) external whenNotPaused {
        // Implementation for liquidating a position
    }

    // Reentrancy guard
    bool internal locked;

    modifier nonReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    function safeTransfer(address token, address to, uint256 value) internal nonReentrant {
        // Safe transfer implementation
    }
}