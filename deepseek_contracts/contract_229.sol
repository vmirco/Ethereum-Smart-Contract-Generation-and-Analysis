// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NameRegistry {
    bool public unlocked = false;
    mapping(bytes32 => address) public names;
    mapping(address => bytes32) public addresses;

    event NameRegistered(bytes32 indexed name, address indexed registrant);

    modifier onlyUnlocked() {
        require(unlocked, "Contract is locked");
        _;
    }

    function registerName(bytes32 name) external onlyUnlocked {
        require(names[name] == address(0), "Name already registered");
        require(addresses[msg.sender] == bytes32(0), "Address already registered a name");

        names[name] = msg.sender;
        addresses[msg.sender] = name;

        emit NameRegistered(name, msg.sender);
    }

    function resolveAddress(bytes32 name) external view returns (address) {
        return names[name];
    }

    function getName(address addr) external view returns (bytes32) {
        return addresses[addr];
    }

    function setUnlocked(bool _unlocked) external {
        unlocked = _unlocked;
    }
}