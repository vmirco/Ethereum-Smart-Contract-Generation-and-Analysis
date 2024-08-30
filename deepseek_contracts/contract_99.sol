// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OwnershipManager {
    address private _owner;
    bool private _initialized;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == _owner, "OwnershipManager: caller is not the owner");
        _;
    }

    function initializeOwner(address initialOwner) public {
        require(!_initialized, "OwnershipManager: already initialized");
        require(initialOwner != address(0), "OwnershipManager: initial owner is the zero address");
        _owner = initialOwner;
        _initialized = true;
        emit OwnershipTransferred(address(0), initialOwner);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "OwnershipManager: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function getOwner() public view returns (address) {
        return _owner;
    }

    function migrateContract(address newContract) public onlyOwner {
        require(newContract != address(0), "OwnershipManager: new contract is the zero address");
        // Logic to migrate contract state can be added here
        // This is a placeholder function for demonstration purposes
    }
}