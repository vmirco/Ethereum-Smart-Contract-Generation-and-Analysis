// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SubscriptionNFT {
    struct Plan {
        uint256 duration; // in seconds
        uint256 price; // in wei
    }

    struct Subscription {
        uint256 planId;
        uint256 startTimestamp;
    }

    address public owner;
    uint256 public nextPlanId;
    uint256 public nextTokenId;
    mapping(uint256 => Plan) public plans;
    mapping(address => Subscription) public subscriptions;
    mapping(uint256 => address) public tokenOwners;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier validPlan(uint256 _planId) {
        require(_planId < nextPlanId, "Invalid plan ID");
        _;
    }

    modifier validAddress(address _addr) {
        require(_addr != address(0), "Invalid address");
        _;
    }

    constructor() {
        owner = msg.sender;
        nextPlanId = 0;
        nextTokenId = 0;
    }

    function addPlan(uint256 _duration, uint256 _price) external onlyOwner {
        plans[nextPlanId] = Plan(_duration, _price);
        nextPlanId++;
    }

    function updatePlan(uint256 _planId, uint256 _duration, uint256 _price) external onlyOwner validPlan(_planId) {
        plans[_planId] = Plan(_duration, _price);
    }

    function subscribe(uint256 _planId) external payable validPlan(_planId) {
        Plan memory plan = plans[_planId];
        require(msg.value == plan.price, "Incorrect subscription fee");
        require(subscriptions[msg.sender].planId == 0, "Already subscribed");

        subscriptions[msg.sender] = Subscription(_planId, block.timestamp);
        _mintToken(msg.sender);
    }

    function renewSubscription() external payable {
        Subscription storage sub = subscriptions[msg.sender];
        require(sub.planId != 0, "Not subscribed");

        Plan memory plan = plans[sub.planId];
        require(msg.value == plan.price, "Incorrect subscription fee");
        require(block.timestamp >= sub.startTimestamp + plan.duration, "Subscription still active");

        sub.startTimestamp = block.timestamp;
    }

    function isSubscriptionActive(address _user) public view returns (bool) {
        Subscription memory sub = subscriptions[_user];
        if (sub.planId == 0) return false;

        Plan memory plan = plans[sub.planId];
        return block.timestamp < sub.startTimestamp + plan.duration;
    }

    function _mintToken(address _to) internal validAddress(_to) {
        tokenOwners[nextTokenId] = _to;
        nextTokenId++;
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}