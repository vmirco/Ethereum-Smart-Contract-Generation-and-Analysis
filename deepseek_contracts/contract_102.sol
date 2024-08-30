// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PRBProxyPlugin {
    // Placeholder for the parent contract's logic
}

interface TargetChangeOwner {
    function changeOwner(address newOwner) external;
    function getCurrentOwner() external view returns (address);
}

contract TargetOwnerManager is PRBProxyPlugin, TargetChangeOwner {
    address private _targetOwner;

    event OwnerChanged(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        require(initialOwner != address(0), "Initial owner cannot be zero address");
        _targetOwner = initialOwner;
    }

    function changeOwner(address newOwner) external override {
        require(newOwner != address(0), "New owner cannot be zero address");
        require(msg.sender == _targetOwner, "Only current owner can change the owner");
        emit OwnerChanged(_targetOwner, newOwner);
        _targetOwner = newOwner;
    }

    function getCurrentOwner() external view override returns (address) {
        return _targetOwner;
    }
}