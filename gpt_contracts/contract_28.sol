// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EtherCartel {
    uint256 constant public PAYOUT_INTERVAL = 1 hours;
    uint256 constant public DRUGS_TO_PRODUCE_1KILO = 100 ether;
    uint256 constant public STARTING_KILOS = 300;

    uint256 public kilosToProduce = 0;
    uint256 public claimedKilos = 0;

    uint256 public marketDrugs;
    uint256 public totalDrugs;

    mapping (address => uint256) public kilos;
    mapping (address => uint256) public claimedDrugs;
    mapping (address => uint256) public lastUpdate;

    function drugsProduced(address _customer) public view returns (uint256) {
        return kilos[_customer] * (block.timestamp - lastUpdate[_customer]) / PAYOUT_INTERVAL;
    }

    function myDrugs() public view returns (uint256) {
        return drugsProduced(msg.sender) + claimedDrugs[msg.sender];
    }

    function sellDrugs(uint256 _amount) public {
        uint256 drugs = myDrugs();
        require(_amount <= drugs, "Not enough drugs to sell");

        marketDrugs += _amount;
        totalDrugs += _amount;
        claimedDrugs[msg.sender] += _amount - drugs;

        lastUpdate[msg.sender] = block.timestamp;
    }

    function buyDrugs(uint256 _amount) public payable {
        require(_amount <= marketDrugs, "Not enough drugs in market");

        uint256 drugsCost = calculateDrugCost(_amount);
        require(msg.value >= drugsCost, "Not enough Ether sent");

        if (msg.value > drugsCost) {
            msg.sender.transfer(msg.value - drugsCost);
        }

        claimedDrugs[msg.sender] -= _amount;
        marketDrugs -= _amount;
    }

    function collectDrugs(address _referrer) public {
        uint256 kilosUsed = getKilosForDrugs(1 ether);
        require(myDrugs() >= kilosUsed, "Not enough drugs");

        lastUpdate[msg.sender] = block.timestamp;
        claimedDrugs[msg.sender] -= kilosUsed;
        kilos[_referrer] += kilosUsed / 3;
        claimedKilos += kilosUsed;

        kilosToProduce += kilosUsed;
    }

    function seedMarket(uint256 _kilos) public {
        kilosToProduce += _kilos;
        claimedKilos += _kilos;
        kilos[msg.sender] += _kilos;
    }

    function calculateDrugCost(uint256 _amount) public view returns (uint256) {
        return DRUGS_TO_PRODUCE_1KILO * _amount / marketDrugs;
    }

    function getKilosForDrugs(uint256 _drugs) public view returns (uint256) {
        return _drugs * totalDrugs / marketDrugs;
    }

    function kilosToCollect() public view returns (uint256) {
        uint256 drugs = myDrugs();
        return getKilosForDrugs(drugs);
    }
}