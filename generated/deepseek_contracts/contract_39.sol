// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StakingWarmUp {
    address public immutable stakingAddress;
    address public immutable sOHMAddress;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(address _stakingAddress, address _sOHMAddress) {
        require(_stakingAddress != address(0), "Invalid staking address");
        require(_sOHMAddress != address(0), "Invalid sOHM address");
        stakingAddress = _stakingAddress;
        sOHMAddress = _sOHMAddress;
    }

    modifier onlyStaking() {
        require(msg.sender == stakingAddress, "Only staking contract can call this function");
        _;
    }

    function retrieve(address recipient, uint256 amount) external onlyStaking {
        require(recipient != address(0), "Invalid recipient address");
        require(amount > 0, "Amount must be greater than zero");

        // Assuming sOHM is an ERC20 token
        (bool success, bytes memory data) = sOHMAddress.call(
            abi.encodeWithSignature("transfer(address,uint256)", recipient, amount)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), "Transfer failed");

        emit Transfer(sOHMAddress, recipient, amount);
    }
}