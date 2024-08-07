// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NameRegistry {
    bool public unlocked;
    address public owner;

    struct Registration {
        address registrant;
        uint256 timestamp;
    }

    mapping(bytes32 => Registration) public registrations;
    mapping(address => bytes32) public addressesToNames;

    event NameRegistered(bytes32 indexed nameHash, address indexed registrant, uint256 timestamp);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier whenUnlocked() {
        require(unlocked, "Contract is locked");
        _;
    }

    constructor() {
        owner = msg.sender;
        unlocked = true;
    }

    function setUnlocked(bool _unlocked) external onlyOwner {
        unlocked = _unlocked;
    }

    function registerName(bytes32 nameHash) external whenUnlocked {
        require(registrations[nameHash].registrant == address(0), "Name already registered");
        require(addressesToNames[msg.sender] == bytes32(0), "Address already registered a name");

        registrations[nameHash] = Registration({
            registrant: msg.sender,
            timestamp: block.timestamp
        });
        addressesToNames[msg.sender] = nameHash;

        emit NameRegistered(nameHash, msg.sender, block.timestamp);
    }

    function resolveAddress(bytes32 nameHash) external view returns (address) {
        return registrations[nameHash].registrant;
    }
}