// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StakingWarmup {

    address public immutable staking;
    address public immutable sHocus;

    constructor(address _staking, address _sHocus) {
        staking = _staking;
        sHocus = _sHocus;
    }

    function retrieve(uint256 amount, address staker) external {
        require(msg.sender == staking, "Only staking contract can call this function");
        require(amount <= address(this).balance, "Not enough balance in contract");
        payable(staker).transfer(amount);
    }
}