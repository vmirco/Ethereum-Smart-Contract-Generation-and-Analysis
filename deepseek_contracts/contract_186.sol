// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StakingWarmup {
    address public immutable staking;
    address public immutable sHocus;

    constructor(address _staking, address _sHocus) {
        staking = _staking;
        sHocus = _sHocus;
    }

    function retrieve(address staker, uint256 amount) external {
        require(msg.sender == staking, "Only staking contract can call this function");
        (bool success, ) = staker.call{value: amount}("");
        require(success, "Transfer failed");
    }
}