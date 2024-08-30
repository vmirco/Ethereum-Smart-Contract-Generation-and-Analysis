// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

interface IStaking {
    function stake(uint256 amount) external;
}

contract StakingWarmUp {
    address public immutable stakingAddress;
    IERC20 public immutable sOHM;

    event Staked(address indexed staker, uint256 amount, uint256 timestamp);

    constructor(address _stakingAddress, address _sOHMAddress) {
        require(_stakingAddress != address(0), 'Staking address cannot be a zero address');
        require(_sOHMAddress != address(0), 'SOHM address cannot be a zero address');
        stakingAddress = _stakingAddress;
        sOHM = IERC20(_sOHMAddress);
    }

    function retrieve(uint256 _amount) external {
        require(msg.sender == stakingAddress, 'Only staking address is allowed to retrieve');
        uint256 sOHMBalance = sOHM.balanceOf(address(this));
        require(_amount <= sOHMBalance, 'Not enough SOHM in contract');
        sOHM.transferFrom(address(this), stakingAddress, _amount);
        emit Staked(stakingAddress, _amount, block.timestamp);
    }
}