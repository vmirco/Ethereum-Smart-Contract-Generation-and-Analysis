// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NonStopTRX {
    address private contractOwner;
    
    struct User {
        bool isRegistered;
        uint weeklyReferralsCount;
        bool isInCyclePool;
    }

    mapping(address => User) private users;

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Not contract owner");
        _;
    }

    constructor() {
        contractOwner = msg.sender;
    }

    function registerUser(address _user) private onlyOwner {
        require(!users[_user].isRegistered, "Already registered");
        users[_user] = User(true, 0, false);
    }

    function updateWeeklyReferrals(address _user, uint _count) private onlyOwner {
        require(users[_user].isRegistered, "Not registered");
        users[_user].weeklyReferralsCount += _count;
    }

    function enterCyclePool(address _user) private onlyOwner {
        require(users[_user].isRegistered, "Not registered");
        users[_user].isInCyclePool = true;
    }
}