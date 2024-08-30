// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StakingWarmUp {
    address public immutable stakingAddress;
    address public immutable sohmAddress;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(address _stakingAddress, address _sohmAddress) {
        require(_stakingAddress != address(0), "Invalid staking address");
        require(_sohmAddress != address(0), "Invalid SOHM address");
        stakingAddress = _stakingAddress;
        sohmAddress = _sohmAddress;
    }

    modifier onlyStaking() {
        require(msg.sender == stakingAddress, "Only staking contract can call this function");
        _;
    }

    function retrieve(address _to, uint256 _amount) external onlyStaking {
        require(_to != address(0), "Invalid recipient address");
        require(_amount > 0, "Amount must be greater than zero");

        // Assuming SOHM contract has a transfer function
        (bool success, ) = sohmAddress.call(abi.encodeWithSignature("transfer(address,uint256)", _to, _amount));
        require(success, "Transfer failed");

        emit Transfer(sohmAddress, _to, _amount);
    }
}