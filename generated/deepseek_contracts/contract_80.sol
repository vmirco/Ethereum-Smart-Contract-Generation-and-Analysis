// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StakingRewards is Ownable, Pausable {
    using SafeMath for uint256;

    struct Pool {
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

    Pool[] public pools;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    event PoolCreated(uint256 indexed pid, uint256 allocationPoints);
    event PoolUpdated(uint256 indexed pid, uint256 allocationPoints);
    event Staked(address indexed user, uint256 indexed pid, uint256 amount);
    event Unstaked(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyUnstake(address indexed user, uint256 indexed pid, uint256 amount);
    event Claimed(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        IERC20 _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock
    ) {
        rewardToken = _rewardToken;
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;
        totalAllocationPoints = 0;
    }

    function createPool(uint256 _allocationPoints) public onlyOwner {
        require(_allocationPoints > 0, "Invalid allocation points");
        pools.push(Pool({
            allocationPoints: _allocationPoints,
            lastRewardBlock: block.number > startBlock ? block.number : startBlock,
            accRewardPerShare: 0
        }));
        totalAllocationPoints = totalAllocationPoints.add(_allocationPoints);
        emit PoolCreated(pools.length.sub(1), _allocationPoints);
    }

    function updatePool(uint256 _pid, uint256 _allocationPoints) public onlyOwner {
        Pool storage pool = pools[_pid];
        if (block.number > pool.lastRewardBlock) {
            uint256 lpSupply = pool.accRewardPerShare;
            if (lpSupply > 0) {
                uint256 blocks = block.number.sub(pool.lastRewardBlock);
                uint256 reward = blocks.mul(rewardPerBlock).mul(pool.allocationPoints).div(totalAllocationPoints);
                pool.accRewardPerShare = pool.accRewardPerShare.add(reward.mul(1e12).div(lpSupply));
            }
            pool.lastRewardBlock = block.number;
        }
        totalAllocationPoints = totalAllocationPoints.sub(pool.allocationPoints).add(_allocationPoints);
        pool.allocationPoints = _allocationPoints;
        emit PoolUpdated(_pid, _allocationPoints);
    }

    function stake(uint256 _pid, uint256 _amount) public whenNotPaused {
        Pool storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid, pool.allocationPoints);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accRewardPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                safeRewardTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            rewardToken.transferFrom(msg.sender, address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        emit Staked(msg.sender, _pid, _amount);
    }

    function unstake(uint256 _pid, uint256 _amount) public {
        Pool storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "Insufficient balance");
        updatePool(_pid, pool.allocationPoints);
        uint256 pending = user.amount.mul(pool.accRewardPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            safeRewardTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            rewardToken.transfer(msg.sender, _amount);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        emit Unstaked(msg.sender, _pid, _amount);
    }

    function emergencyUnstake(uint256 _pid, uint256 _amount) public {
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "Insufficient balance");
        user.amount = user.amount.sub(_amount);
        rewardToken.transfer(msg.sender, _amount);
        emit EmergencyUnstake(msg.sender, _pid, _amount);
    }

    function claim(uint256 _pid) public {
        Pool storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid, pool.allocationPoints);
        uint256 pending = user.amount.mul(pool.accRewardPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            safeRewardTransfer(msg.sender, pending);
        }
        user.rewardDebt = user.amount.mul(pool.accRewardPerShare).div(1e12);
        emit Claimed(msg.sender, _pid, pending);
    }

    function safeRewardTransfer(address _to, uint256 _amount) internal {
        uint256 balance = rewardToken.balanceOf(address(this));
        if (_amount > balance) {
            rewardToken.transfer(_to, balance);
        } else {
            rewardToken.transfer(_to, _amount);
        }
    }
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract Pausable is Ownable {
    bool private _paused;

    event Paused(address account);
    event Unpaused(address account);

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function pause() public virtual onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public virtual onlyOwner whenPaused {
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
}