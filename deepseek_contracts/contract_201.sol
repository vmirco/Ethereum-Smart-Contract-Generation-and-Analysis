// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TriggerOrderManager {
    address public router;
    address public owner;

    event RouterSet(address indexed router);
    event PositionTriggered(uint256 indexed orderId);
    event TriggerOrderCanceled(uint256 indexed orderId);
    event TriggerOrderExecuted(uint256 indexed orderId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyRouter() {
        require(msg.sender == router, "Not the router");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setRouter(address _router) external onlyOwner {
        router = _router;
        emit RouterSet(_router);
    }

    function triggerPosition(uint256 orderId) external onlyRouter {
        // Logic to trigger a position
        emit PositionTriggered(orderId);
    }

    function cancelTriggerOrder(uint256 orderId) external onlyRouter {
        // Logic to cancel a trigger order
        emit TriggerOrderCanceled(orderId);
    }

    function executeTriggerOrder(uint256 orderId) external onlyRouter {
        // Logic to execute a trigger order
        emit TriggerOrderExecuted(orderId);
    }
}