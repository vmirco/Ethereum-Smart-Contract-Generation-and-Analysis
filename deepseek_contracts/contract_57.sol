// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FeeManager {
    address public owner;
    mapping(address => bool) public repositories;
    mapping(address => bool) public routers;
    mapping(address => bool) public budgetManagers;
    string[] public chainNames;
    mapping(address => uint256) public collectionFees;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyRepository() {
        require(repositories[msg.sender], "Not a registered repository");
        _;
    }

    modifier onlyRouter() {
        require(routers[msg.sender], "Not a registered router");
        _;
    }

    modifier onlyBudgetManager() {
        require(budgetManagers[msg.sender], "Not a registered budget manager");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setRepository(address repo, bool status) external onlyOwner {
        repositories[repo] = status;
    }

    function setRouter(address router, bool status) external onlyOwner {
        routers[router] = status;
    }

    function setBudgetManager(address manager, bool status) external onlyOwner {
        budgetManagers[manager] = status;
    }

    function addChainName(string memory chainName) external onlyOwner {
        chainNames.push(chainName);
    }

    function createCollection(address collection, uint256 fee) external onlyRepository {
        collectionFees[collection] = fee;
    }

    function withdrawFees(address collection, uint256 amount) external onlyBudgetManager {
        require(collectionFees[collection] >= amount, "Insufficient fees");
        collectionFees[collection] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function receiveOmnichainMessage(bytes memory message) external onlyRouter {
        // Handle omnichain message
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }

    receive() external payable {
        // Accept ETH for fee deposits
    }
}