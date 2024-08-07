// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TriggerOrderManager {
    address public router;
    address public owner;

    enum OrderStatus { Pending, Executed, Canceled }

    struct TriggerOrder {
        uint256 id;
        address trader;
        bytes orderData;
        OrderStatus status;
    }

    TriggerOrder[] public triggerOrders;
    mapping(uint256 => bool) public orderExists;

    event RouterSet(address indexed router);
    event TriggerOrderExecuted(uint256 indexed orderId, address indexed trader);
    event TriggerOrderCanceled(uint256 indexed orderId, address indexed trader);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
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

    function createTriggerOrder(bytes memory _orderData) external {
        uint256 orderId = triggerOrders.length;
        triggerOrders.push(TriggerOrder({
            id: orderId,
            trader: msg.sender,
            orderData: _orderData,
            status: OrderStatus.Pending
        }));
        orderExists[orderId] = true;
    }

    function executeTriggerOrder(uint256 _orderId) external onlyRouter {
        require(orderExists[_orderId], "Order does not exist");
        TriggerOrder storage order = triggerOrders[_orderId];
        require(order.status == OrderStatus.Pending, "Order not pending");
        order.status = OrderStatus.Executed;
        emit TriggerOrderExecuted(_orderId, order.trader);
    }

    function cancelTriggerOrder(uint256 _orderId) external {
        require(orderExists[_orderId], "Order does not exist");
        TriggerOrder storage order = triggerOrders[_orderId];
        require(order.trader == msg.sender, "Not the trader");
        require(order.status == OrderStatus.Pending, "Order not pending");
        order.status = OrderStatus.Canceled;
        emit TriggerOrderCanceled(_orderId, order.trader);
    }
}