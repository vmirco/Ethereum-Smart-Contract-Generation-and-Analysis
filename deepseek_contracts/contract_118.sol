// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SubscriptionNFT {
    struct SubscriptionPlan {
        uint256 duration; // Duration in seconds
        uint256 price; // Price in wei
        bool active;
    }

    struct UserSubscription {
        uint256 planId;
        uint256 startTimestamp;
    }

    address public owner;
    uint256 public nextPlanId;
    mapping(uint256 => SubscriptionPlan) public plans;
    mapping(address => UserSubscription) public userSubscriptions;
    mapping(address => uint256) public balances;

    event PlanAdded(uint256 planId, uint256 duration, uint256 price);
    event SubscriptionStarted(address user, uint256 planId, uint256 startTimestamp);
    event Withdrawal(address indexed to, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        nextPlanId = 1;
    }

    function addPlan(uint256 duration, uint256 price) external onlyOwner {
        require(duration > 0, "Duration must be greater than 0");
        require(price > 0, "Price must be greater than 0");

        plans[nextPlanId] = SubscriptionPlan(duration, price, true);
        emit PlanAdded(nextPlanId, duration, price);
        nextPlanId++;
    }

    function subscribe(uint256 planId) external payable {
        SubscriptionPlan storage plan = plans[planId];
        require(plan.active, "Plan is not active");
        require(msg.value == plan.price, "Incorrect subscription price");

        UserSubscription storage userSub = userSubscriptions[msg.sender];
        require(userSub.planId == 0 || block.timestamp > userSub.startTimestamp + plans[userSub.planId].duration, "User already subscribed");

        userSub.planId = planId;
        userSub.startTimestamp = block.timestamp;
        balances[owner] += msg.value;

        emit SubscriptionStarted(msg.sender, planId, block.timestamp);
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(amount <= balances[owner], "Insufficient balance");
        balances[owner] -= amount;
        payable(owner).transfer(amount);
        emit Withdrawal(owner, amount);
    }

    function deactivatePlan(uint256 planId) external onlyOwner {
        require(plans[planId].active, "Plan is already inactive");
        plans[planId].active = false;
    }

    function activatePlan(uint256 planId) external onlyOwner {
        require(!plans[planId].active, "Plan is already active");
        plans[planId].active = true;
    }

    function updatePlan(uint256 planId, uint256 duration, uint256 price) external onlyOwner {
        require(duration > 0, "Duration must be greater than 0");
        require(price > 0, "Price must be greater than 0");
        SubscriptionPlan storage plan = plans[planId];
        require(plan.duration > 0, "Plan does not exist");

        plan.duration = duration;
        plan.price = price;
    }

    function isSubscribed(address user) public view returns (bool) {
        UserSubscription storage userSub = userSubscriptions[user];
        return userSub.planId != 0 && block.timestamp <= userSub.startTimestamp + plans[userSub.planId].duration;
    }
}