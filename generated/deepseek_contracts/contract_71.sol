// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenManagement {
    string public name = "MyToken";
    string public symbol = "MTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public owner;
    address public treasuryFund;
    address public devFund;
    uint256 public vestingPeriod;
    uint256 public rewardRate;
    uint256 public communityFund;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event ClaimReward(address indexed user, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(uint256 initialSupply, uint256 _vestingPeriod, uint256 _rewardRate) {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
        vestingPeriod = _vestingPeriod;
        rewardRate = _rewardRate;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require(value <= balanceOf[from], "Insufficient balance");
        require(value <= allowance[from][msg.sender], "Allowance exceeded");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function mint(address to, uint256 value) public onlyOwner returns (bool success) {
        totalSupply += value;
        balanceOf[to] += value;
        emit Mint(to, value);
        emit Transfer(address(0), to, value);
        return true;
    }

    function burn(uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        totalSupply -= value;
        balanceOf[msg.sender] -= value;
        emit Burn(msg.sender, value);
        emit Transfer(msg.sender, address(0), value);
        return true;
    }

    function setTreasuryFund(address _treasuryFund) public onlyOwner {
        treasuryFund = _treasuryFund;
    }

    function setDevFund(address _devFund) public onlyOwner {
        devFund = _devFund;
    }

    function claimReward(address user, uint256 value) public returns (bool success) {
        require(balanceOf[treasuryFund] >= value, "Insufficient funds in treasury");
        balanceOf[treasuryFund] -= value;
        balanceOf[user] += value;
        emit ClaimReward(user, value);
        emit Transfer(treasuryFund, user, value);
        return true;
    }

    function distributeFarmingIncentives(address to, uint256 value) public onlyOwner returns (bool success) {
        require(balanceOf[devFund] >= value, "Insufficient funds in dev fund");
        balanceOf[devFund] -= value;
        balanceOf[to] += value;
        emit Transfer(devFund, to, value);
        return true;
    }
}