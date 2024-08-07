// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;

interface ComptrollerInterface {
    function claimComp(address holder) external;
    function getCompAddress() external view returns (address);
}

contract CompClaim {
    ComptrollerInterface public comptroller;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(address _comptroller) {
        comptroller = ComptrollerInterface(_comptroller);
        owner = msg.sender;
    }

    function claimComp() external onlyOwner {
        comptroller.claimComp(owner);
    }

    function getCompAddress() external view returns (address) {
        return comptroller.getCompAddress();
    }
}