// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract NameRegistry {
    mapping(bytes32 => address) public nameToAddress;
    bool public unlocked = true;

    modifier onlyWhenUnlocked() {
        require(unlocked, "The system is currently locked.");
        _;
    }
    
    function registerName(bytes32 name) public onlyWhenUnlocked {
        require(nameToAddress[name] == address(0), "This name is already taken.");

        nameToAddress[name] = msg.sender;
    }

    function resolveToAddress(bytes32 name) public view returns (address) {
        require(nameToAddress[name] != address(0), "This name is not registered.");

        return nameToAddress[name];
    }
    
    function setLock(bool lock) public {
        unlocked = lock;
    }
}