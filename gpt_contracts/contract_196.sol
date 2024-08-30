// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FeeManager {
    uint private maxAllowedRate;
    uint private takerFee;
    uint private makerFee;
    address private admin;

    constructor(uint _maxAllowedRate) {
         require(_maxAllowedRate > 0, "Maximum rate must be greater than 0");
         maxAllowedRate = _maxAllowedRate;
         admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function.");
        _;
    }

    function setTakerFee(uint _takerFee) public onlyAdmin {
        require(_takerFee <= maxAllowedRate, "The fee is more than the max allowed.");
        takerFee = _takerFee;
    }

    function setMakerFee(uint _makerFee) public onlyAdmin {
        require(_makerFee <= maxAllowedRate, "The fee is more than the max allowed.");
        makerFee = _makerFee;
    }

    function getTakerFee() public view returns (uint) {
        return takerFee;
    }

    function getMakerFee() public view returns (uint) {
        return makerFee;
    }

    function getMaxAllowedRate() public view returns (uint) {
        return maxAllowedRate;
    }

    function setMaxAllowedRate(uint _maxAllowedRate) public onlyAdmin {
        require(_maxAllowedRate > 0, "Maximum rate must be greater than 0");
        maxAllowedRate = _maxAllowedRate;
        if(takerFee > maxAllowedRate) {
            takerFee = maxAllowedRate;
        }
        if(makerFee > maxAllowedRate) {
            makerFee = maxAllowedRate;
        }
    }
}