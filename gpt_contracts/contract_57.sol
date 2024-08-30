// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CollectionManager {
    struct Collection {
        string name;
        address router;
        address budgetManager;
    }

    mapping(string => Collection) public collections;
    mapping(string => string) public chainNames;
    mapping(string => address) public repositories;
    address owner;
    
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only Owner is allowed!");
        _;
    }

    event CollectionCreated(string name, address router, address budgetManager);
    event RepositorySet(string chainName, address repository);
    event ChainNameSet(string chainName);
    
    function createCollection(string memory name, address router, address budgetManager) public onlyOwner {
        Collection memory newCollection = Collection(name, router, budgetManager);
        collections[name] = newCollection;

        emit CollectionCreated(name, router, budgetManager);
    }

    function setRepository(string memory chainName, address repository) public onlyOwner {
        repositories[chainName] = repository;
        emit RepositorySet(chainName, repository);
    }

    function setChainName(string memory chainName) public onlyOwner {
        chainNames[chainName] = chainName;
        emit ChainNameSet(chainName);
    }

    function depositFunds(string memory name) public payable {
        require(collections[name].router != address(0), "Collection doesn't exists!");
        payable(collections[name].budgetManager).transfer(msg.value);
    }

    function receiveOmnichainMessage(string memory chainName, bytes32 _message) public {
        require(repositories[chainName] != address(0), "Repository doesn't exists!");
        // you can do additional processing here
    }

    function changeOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}