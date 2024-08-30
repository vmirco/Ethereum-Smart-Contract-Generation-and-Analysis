// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NonStopTRX {
    address public owner;

    struct User {
        bool registered;
        uint256 weeklyReferrals;
        bool inCyclePool;
    }

    mapping(address => User) public users;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerUser(address _user) private {
        require(!users[_user].registered, "User already registered");
        users[_user].registered = true;
    }

    function updateWeeklyReferrals(address _user, uint256 _referrals) private {
        require(users[_user].registered, "User not registered");
        users[_user].weeklyReferrals = _referrals;
    }

    function enterCyclePool(address _user) private {
        require(users[_user].registered, "User not registered");
        require(!users[_user].inCyclePool, "User already in cycle pool");
        users[_user].inCyclePool = true;
    }

    function publicRegisterUser() external {
        registerUser(msg.sender);
    }

    function publicUpdateWeeklyReferrals(uint256 _referrals) external {
        updateWeeklyReferrals(msg.sender, _referrals);
    }

    function publicEnterCyclePool() external {
        enterCyclePool(msg.sender);
    }
}