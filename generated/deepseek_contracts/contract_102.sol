// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface TargetChangeOwner {
    function changeOwner(address newOwner) external;
    function getOwner() external view returns (address);
}

contract PRBProxyPlugin {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }
}

contract TargetOwnerManager is PRBProxyPlugin, TargetChangeOwner {
    address private targetOwner;

    constructor(address initialOwner) {
        targetOwner = initialOwner;
    }

    function changeOwner(address newOwner) external override onlyOwner {
        require(newOwner != address(0), "Invalid address");
        targetOwner = newOwner;
    }

    function getOwner() external view override returns (address) {
        return targetOwner;
    }
}