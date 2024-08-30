pragma solidity ^0.8.0;

contract TriggerOrderManager {

    address public router;
    uint256 public nextTriggerOrderId = 1;

    mapping(uint256 => TriggerOrder) public triggerOrders;

    struct TriggerOrder {
        address user;
        bool active;
        uint256 price;
        uint256 amount;
    }

    event RouterSet(address indexed user, address indexed router);
    event TriggerOrderExecuted(uint256 indexed orderId, address indexed user, uint256 price, uint256 amount);
    event TriggerOrderCanceled(uint256 indexed orderId, address indexed user);

    modifier onlyRouter() {
        require(msg.sender == router, "Caller is not the router");
        _;
    }

    modifier onlyOrderOwner(uint256 _orderId) {
        require(msg.sender == triggerOrders[_orderId].user, "Caller is not the order owner");
        _;
    }

    function setRouter(address _router) external onlyRouter {
        router = _router;

        emit RouterSet(msg.sender, _router);
    }

    function triggerPosition(uint256 _price, uint256 _amount) external returns (uint256) {
        triggerOrders[nextTriggerOrderId] = TriggerOrder(msg.sender, true, _price, _amount);

        return nextTriggerOrderId++;
    }

    function cancelTriggerOrder(uint256 _orderId) external onlyOrderOwner(_orderId) {
        require(triggerOrders[_orderId].active == true, "Order is already inactive");

        triggerOrders[_orderId].active = false;

        emit TriggerOrderCanceled(_orderId, msg.sender);
    }

    function executeTriggerOrder(uint256 _orderId) external onlyRouter {
        require(triggerOrders[_orderId].active == true, "Order is inactive");

        triggerOrders[_orderId].active = false;

        emit TriggerOrderExecuted(_orderId, triggerOrders[_orderId].user, triggerOrders[_orderId].price, triggerOrders[_orderId].amount);
    }
}