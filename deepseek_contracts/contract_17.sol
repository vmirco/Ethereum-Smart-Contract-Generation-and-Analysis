// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InsuranceManager {
    address public owner;
    bool public paused;
    uint256 public totalCapital;
    uint256 public totalPremiums;

    struct InsuranceProduct {
        bool active;
        uint256 premium;
        uint256 coverageAmount;
        uint256 expiration;
    }

    mapping(address => InsuranceProduct) public policies;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    event PolicyPurchased(address indexed policyHolder, uint256 premium, uint256 coverageAmount, uint256 expiration);
    event PolicyCancelled(address indexed policyHolder);
    event ContractPaused(address indexed pauser);
    event ContractUnpaused(address indexed unpauser);

    constructor() {
        owner = msg.sender;
        paused = false;
    }

    function pause() external onlyOwner {
        paused = true;
        emit ContractPaused(msg.sender);
    }

    function unpause() external onlyOwner {
        paused = false;
        emit ContractUnpaused(msg.sender);
    }

    function purchaseCoverage(uint256 _premium, uint256 _coverageAmount, uint256 _duration) external payable whenNotPaused {
        require(msg.value == _premium, "Incorrect premium amount");
        require(_coverageAmount > 0, "Coverage amount must be greater than zero");
        require(_duration > 0, "Duration must be greater than zero");

        InsuranceProduct memory newPolicy = InsuranceProduct({
            active: true,
            premium: _premium,
            coverageAmount: _coverageAmount,
            expiration: block.timestamp + _duration
        });

        policies[msg.sender] = newPolicy;
        totalPremiums += _premium;
        totalCapital += _coverageAmount;

        emit PolicyPurchased(msg.sender, _premium, _coverageAmount, newPolicy.expiration);
    }

    function cancelCoverage() external whenNotPaused {
        InsuranceProduct storage policy = policies[msg.sender];
        require(policy.active, "No active policy found");

        policy.active = false;
        totalPremiums -= policy.premium;
        totalCapital -= policy.coverageAmount;

        (bool success, ) = msg.sender.call{value: policy.premium}("");
        require(success, "Transfer failed");

        emit PolicyCancelled(msg.sender);
    }

    function getPolicyStatus(address _policyHolder) external view returns (bool, uint256, uint256, uint256) {
        InsuranceProduct storage policy = policies[_policyHolder];
        return (policy.active, policy.premium, policy.coverageAmount, policy.expiration);
    }
}