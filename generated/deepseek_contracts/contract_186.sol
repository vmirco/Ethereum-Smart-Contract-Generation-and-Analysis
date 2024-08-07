// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StakingWarmup {
    address immutable public staking;
    address immutable public sHocus;

    constructor(address _staking, address _sHocus) {
        staking = _staking;
        sHocus = _sHocus;
    }

    function retrieve(address staker, uint256 amount) external {
        require(msg.sender == staking, "Only staking contract can call this function");
        payable(staker).transfer(amount);
    }
}