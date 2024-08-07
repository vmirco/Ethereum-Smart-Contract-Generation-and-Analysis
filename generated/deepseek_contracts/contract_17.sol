// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InsuranceManager {
    address public owner;
    bool public paused;
    uint256 public totalCapital;
    uint256 public totalPremiums;

    struct Policy {
        address holder;
        uint256 premium;
        uint256 coverageAmount;
        bool active;
    }

    mapping(address => Policy) public policies;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    event PolicyPurchased(address indexed holder, uint256 premium, uint256 coverageAmount);
    event PolicyCancelled(address indexed holder, uint256 refundAmount);
    event StatusUpdated(address indexed holder, bool active);

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

    function purchasePolicy(uint256 _premium, uint256 _coverageAmount) external payable whenNotPaused {
        require(msg.value == _premium, "Incorrect premium amount");
        require(_coverageAmount > 0, "Coverage amount must be greater than zero");
        require(policies[msg.sender].holder == address(0), "Policy already exists");

        policies[msg.sender] = Policy({
            holder: msg.sender,
            premium: _premium,
            coverageAmount: _coverageAmount,
            active: true
        });

        totalPremiums += _premium;
        totalCapital += _coverageAmount;

        emit PolicyPurchased(msg.sender, _premium, _coverageAmount);
    }

    function cancelPolicy() external whenNotPaused {
        Policy storage policy = policies[msg.sender];
        require(policy.holder != address(0), "No policy found");
        require(policy.active, "Policy is not active");

        uint256 refundAmount = policy.premium;
        policy.active = false;

        totalPremiums -= policy.premium;
        totalCapital -= policy.coverageAmount;

        payable(msg.sender).transfer(refundAmount);

        emit PolicyCancelled(msg.sender, refundAmount);
    }

    function updatePolicyStatus(address _holder, bool _active) external onlyOwner {
        Policy storage policy = policies[_holder];
        require(policy.holder != address(0), "No policy found");

        policy.active = _active;

        emit StatusUpdated(_holder, _active);
    }
}