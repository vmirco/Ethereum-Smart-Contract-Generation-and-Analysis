// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NonStopTRX {
    address public owner;

    struct User {
        bool isRegistered;
        uint256 weeklyReferrals;
        bool inCyclePool;
    }

    mapping(address => User) private users;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyRegistered() {
        require(users[msg.sender].isRegistered, "User not registered");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerUser() external {
        require(!users[msg.sender].isRegistered, "User already registered");
        users[msg.sender] = User({
            isRegistered: true,
            weeklyReferrals: 0,
            inCyclePool: false
        });
    }

    function updateWeeklyReferrals(uint256 referrals) external onlyRegistered {
        users[msg.sender].weeklyReferrals = referrals;
    }

    function enterCyclePool() external onlyRegistered {
        require(!users[msg.sender].inCyclePool, "User already in cycle pool");
        users[msg.sender].inCyclePool = true;
    }

    function getUserInfo(address userAddress) external view returns (bool, uint256, bool) {
        User memory user = users[userAddress];
        return (user.isRegistered, user.weeklyReferrals, user.inCyclePool);
    }
}