// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DrugMarket {
    struct User {
        uint kilos;
        uint revenue;
        address referrer;
    }

    mapping(address => User) public users;
    uint public totalKilos;
    uint public drugPrice = 1 ether; // Price per kilo
    uint public referralRewardPercentage = 5; // 5% referral reward

    event DrugsCollected(address indexed user, uint kilos);
    event DrugsSold(address indexed user, uint kilos, uint revenue);
    event DrugsBought(address indexed user, uint kilos, uint cost);
    event MarketSeeded(uint kilos);

    function collectDrugs(uint kilos) external {
        User storage user = users[msg.sender];
        user.kilos += kilos;
        totalKilos += kilos;
        emit DrugsCollected(msg.sender, kilos);
    }

    function sellDrugs(uint kilos) external {
        User storage user = users[msg.sender];
        require(user.kilos >= kilos, "Not enough kilos to sell");

        uint revenue = kilos * drugPrice;
        user.kilos -= kilos;
        user.revenue += revenue;
        totalKilos -= kilos;

        if (user.referrer != address(0)) {
            uint referralReward = (revenue * referralRewardPercentage) / 100;
            users[user.referrer].revenue += referralReward;
            revenue -= referralReward;
        }

        payable(msg.sender).transfer(revenue);
        emit DrugsSold(msg.sender, kilos, revenue);
    }

    function buyDrugs(uint kilos, address referrer) external payable {
        uint cost = kilos * drugPrice;
        require(msg.value >= cost, "Insufficient payment");

        User storage user = users[msg.sender];
        user.kilos += kilos;
        totalKilos += kilos;

        if (referrer != address(0) && referrer != msg.sender) {
            users[referrer].referrer = referrer;
        }

        if (msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }

        emit DrugsBought(msg.sender, kilos, cost);
    }

    function seedMarket(uint kilos) external {
        totalKilos += kilos;
        emit MarketSeeded(kilos);
    }

    receive() external payable {
        // Accept Ether transfers
    }
}