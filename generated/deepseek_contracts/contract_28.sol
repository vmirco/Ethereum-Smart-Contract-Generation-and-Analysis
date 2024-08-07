// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DrugMarket {
    struct Drug {
        uint256 price;
        uint256 quantity;
    }

    mapping(address => uint256) public balances;
    mapping(address => uint256) public kilos;
    mapping(address => uint256) public referralRewards;
    Drug public drug;
    address public owner;
    uint256 public marketDrugQuantity;

    event BoughtDrug(address indexed buyer, uint256 quantity);
    event SoldDrug(address indexed seller, uint256 quantity);
    event MarketSeeded(uint256 quantity);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(uint256 initialPrice, uint256 initialQuantity) {
        owner = msg.sender;
        drug = Drug(initialPrice, initialQuantity);
        marketDrugQuantity = initialQuantity;
    }

    function seedMarket(uint256 quantity) external onlyOwner {
        marketDrugQuantity += quantity;
        emit MarketSeeded(quantity);
    }

    function buyDrug(uint256 quantity, address referral) external payable {
        require(quantity <= marketDrugQuantity, "Not enough drugs in market");
        uint256 totalCost = drug.price * quantity;
        require(msg.value >= totalCost, "Insufficient funds");

        balances[msg.sender] += quantity;
        marketDrugQuantity -= quantity;
        kilos[msg.sender] += quantity;

        if (referral != address(0) && referral != msg.sender) {
            uint256 referralReward = totalCost / 10; // 10% referral reward
            referralRewards[referral] += referralReward;
            balances[owner] += totalCost - referralReward;
        } else {
            balances[owner] += totalCost;
        }

        emit BoughtDrug(msg.sender, quantity);
    }

    function sellDrug(uint256 quantity) external {
        require(kilos[msg.sender] >= quantity, "Not enough kilos");
        uint256 totalRevenue = drug.price * quantity;

        kilos[msg.sender] -= quantity;
        marketDrugQuantity += quantity;
        balances[msg.sender] -= quantity;
        balances[msg.sender] += totalRevenue;

        emit SoldDrug(msg.sender, quantity);
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw");
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function withdrawReferralRewards() external {
        uint256 amount = referralRewards[msg.sender];
        require(amount > 0, "No referral rewards to withdraw");
        referralRewards[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
}