// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FeeManager {
    address public owner;
    mapping(address => bool) public repositoryManagers;
    mapping(address => bool) public routerManagers;
    mapping(address => bool) public budgetManagers;
    string[] public chainNames;
    mapping(uint256 => Collection) public collections;
    uint256 public collectionCount;

    struct Collection {
        string name;
        address creator;
        uint256 balance;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyRepositoryManager() {
        require(repositoryManagers[msg.sender], "Not a repository manager");
        _;
    }

    modifier onlyRouterManager() {
        require(routerManagers[msg.sender], "Not a router manager");
        _;
    }

    modifier onlyBudgetManager() {
        require(budgetManagers[msg.sender], "Not a budget manager");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setRepositoryManager(address manager, bool status) external onlyOwner {
        repositoryManagers[manager] = status;
    }

    function setRouterManager(address manager, bool status) external onlyOwner {
        routerManagers[manager] = status;
    }

    function setBudgetManager(address manager, bool status) external onlyOwner {
        budgetManagers[manager] = status;
    }

    function addChainName(string memory chainName) external onlyOwner {
        chainNames.push(chainName);
    }

    function createCollection(string memory name) external onlyRepositoryManager {
        collections[collectionCount] = Collection(name, msg.sender, 0);
        collectionCount++;
    }

    function depositToCollection(uint256 collectionId) external payable onlyRouterManager {
        require(collectionId < collectionCount, "Invalid collection ID");
        collections[collectionId].balance += msg.value;
    }

    function withdrawFromCollection(uint256 collectionId, uint256 amount) external onlyBudgetManager {
        require(collectionId < collectionCount, "Invalid collection ID");
        Collection storage collection = collections[collectionId];
        require(collection.balance >= amount, "Insufficient balance");
        collection.balance -= amount;
        payable(msg.sender).transfer(amount);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    receive() external payable {}
}