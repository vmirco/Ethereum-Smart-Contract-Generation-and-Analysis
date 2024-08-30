// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StakingRewards is Ownable, Pausable {
    struct PoolInfo {
        IERC20 token;
        uint256 allocationPoints;
        uint256 lastRewardBlock;
        uint256 accRewardPerShare;
    }

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    IERC20 public rewardToken;
    uint256 public rewardPerBlock;
    uint256 public totalAllocationPoints;
    uint256 public startBlock;

    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    event PoolCreated(uint256 indexed pid, uint256 allocationPoints);
    event PoolUpdated(uint256 indexed pid, uint256 allocationPoints);
    event Staked(address indexed user, uint256 indexed pid, uint256 amount);
    event Unstaked(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyUnstaked(address indexed user, uint256 indexed pid, uint256 amount);
    event RewardClaimed(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(IERC20 _rewardToken, uint256 _rewardPerBlock, uint256 _startBlock) {
        rewardToken = _rewardToken;
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;
    }

    function createPool(IERC20 _token, uint256 _allocationPoints) external onlyOwner {
        totalAllocationPoints += _allocationPoints;
        poolInfo.push(PoolInfo({
            token: _token,
            allocationPoints: _allocationPoints,
            lastRewardBlock: block.number > startBlock ? block.number : startBlock,
            accRewardPerShare: 0
        }));
        emit PoolCreated(poolInfo.length - 1, _allocationPoints);
    }

    function updatePool(uint256 _pid, uint256 _allocationPoints) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        totalAllocationPoints = totalAllocationPoints - pool.allocationPoints + _allocationPoints;
        pool.allocationPoints = _allocationPoints;
        emit PoolUpdated(_pid, _allocationPoints);
    }

    function stake(uint256 _pid, uint256 _amount) external whenNotPaused {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePoolRewards(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount * pool.accRewardPerShare / 1e12 - user.rewardDebt;
            if (pending > 0) {
                safeRewardTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            pool.token.transferFrom(msg.sender, address(this), _amount);
            user.amount += _amount;
        }
        user.rewardDebt = user.amount * pool.accRewardPerShare / 1e12;
        emit Staked(msg.sender, _pid, _amount);
    }

    function unstake(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "unstake: not good");
        updatePoolRewards(_pid);
        uint256 pending = user.amount * pool.accRewardPerShare / 1e12 - user.rewardDebt;
        if (pending > 0) {
            safeRewardTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount -= _amount;
            pool.token.transfer(msg.sender, _amount);
        }
        user.rewardDebt = user.amount * pool.accRewardPerShare / 1e12;
        emit Unstaked(msg.sender, _pid, _amount);
    }

    function emergencyUnstake(uint256 _pid, uint256 _amount) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "emergencyUnstake: not good");
        user.amount -= _amount;
        pool.token.transfer(msg.sender, _amount);
        emit EmergencyUnstaked(msg.sender, _pid, _amount);
    }

    function claimReward(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePoolRewards(_pid);
        uint256 pending = user.amount * pool.accRewardPerShare / 1e12 - user.rewardDebt;
        if (pending > 0) {
            safeRewardTransfer(msg.sender, pending);
            emit RewardClaimed(msg.sender, _pid, pending);
        }
        user.rewardDebt = user.amount * pool.accRewardPerShare / 1e12;
    }

    function updatePoolRewards(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 tokenSupply = pool.token.balanceOf(address(this));
        if (tokenSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = block.number - pool.lastRewardBlock;
        uint256 reward = multiplier * rewardPerBlock * pool.allocationPoints / totalAllocationPoints;
        pool.accRewardPerShare += reward * 1e12 / tokenSupply;
        pool.lastRewardBlock = block.number;
    }

    function safeRewardTransfer(address _to, uint256 _amount) internal {
        uint256 rewardBal = rewardToken.balanceOf(address(this));
        if (_amount > rewardBal) {
            rewardToken.transfer(_to, rewardBal);
        } else {
            rewardToken.transfer(_to, _amount);
        }
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract Pausable is Ownable {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}