// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Token {
    mapping (address => uint256) public balanceOf;

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract StakingContract {
    Token public token;
    mapping(address => uint256) public stakers;
    uint256 public totalStaked;

    event Staked(address indexed user, uint256 amount, uint256 totalAmount);
    event Unstaked(address indexed user, uint256 amount, uint256 totalAmount);

    constructor(address _token) {
        token = Token(_token);
    }

    function stakeTokens(uint256 _amount) public {
        require(_amount > 0, "Stake amount can't be 0");
        require(token.transferFrom(msg.sender, address(this), _amount), "Token transfer was unsuccessful");
        stakers[msg.sender] += _amount;
        totalStaked += _amount;

        emit Staked(msg.sender, _amount, totalStaked);
    }

    function unstakeTokens(uint256 _amount) public {
        uint256 userStake = stakers[msg.sender];
        require(userStake >= _amount, "You cannot unstake more tokens than you have staked");

        stakers[msg.sender] -= _amount;
        totalStaked -= _amount;
        require(token.transfer(msg.sender, _amount), "Unable to transfer tokens back to staker");

        emit Unstaked(msg.sender, _amount, totalStaked);
    }

    function stakeOf(address _user) public view returns(uint256) {
        return stakers[_user];
    }

    function totalStakes() public view returns (uint256) {
        return totalStaked;
    }
}