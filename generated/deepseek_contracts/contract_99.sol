// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OwnershipManager {
    address public owner;
    bool public initialized;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier isInitialized() {
        require(initialized, "Contract not initialized");
        _;
    }

    function initialize(address _owner) public {
        require(!initialized, "Already initialized");
        require(_owner != address(0), "Invalid owner address");
        owner = _owner;
        initialized = true;
    }

    function transferOwnership(address newOwner) public onlyOwner isInitialized {
        require(newOwner != address(0), "Invalid new owner address");
        owner = newOwner;
    }

    function migrateContract(address newContract) public onlyOwner isInitialized {
        require(newContract != address(0), "Invalid new contract address");
        (bool success, ) = newContract.call("");
        require(success, "Migration failed");
    }

    function getOwner() public view returns (address) {
        return owner;
    }
}