// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Ownable {
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Pausable is Ownable {
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
        emit Paused(_msgSender());
    }

    function unpause() public virtual onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }  
}

contract ERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {}
    function balanceOf(address account) public view virtual returns (uint256) {}
}

contract StakingContract is Ownable, Pausable {
    struct UserInfo {
        uint256 amount;    
        uint256 rewardDebt; 
    }

    struct PoolInfo {
        ERC20 token;
        uint256 allocPoint;       
        uint256 lastRewardBlock;  
        uint256 accRwardPerShare; 
    }

    ERC20 public rewardToken;  
    
    uint256 public rewardPerBlock;

    PoolInfo[] public poolInfo;
   
    mapping (uint256 => mapping (address => UserInfo)) private _userInfo;
    
    uint256 public totalAllocPoint = 0;
    
    uint256 public startBlock;
    
    uint256 public bonusEndBlock;
    
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    
    constructor(
        ERC20 _rewardToken,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock
    ) {
        rewardToken = _rewardToken;
        rewardPerBlock = _rewardPerBlock;
        startBlock = _startBlock;
        bonusEndBlock = _bonusEndBlock;
    }
    
    function addPool(uint256 _allocPoint, ERC20 _token, bool _withUpdate) public whenNotPaused onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint + _allocPoint;
        poolInfo.push(PoolInfo({
            token: _token,
            allocPoint: _allocPoint,
            lastRewardBlock: block.number > startBlock ? block.number : startBlock,
            accRwardPerShare: 0
        }));
    }

    function updatePool(uint256 _pid) public whenNotPaused {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 tokenSupply = pool.token.balanceOf(address(this));
        if (tokenSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 reward = multiplier * rewardPerBlock * pool.allocPoint / totalAllocPoint;
        pool.accRwardPerShare = pool.accRwardPerShare + (reward * 1e12 / tokenSupply);
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) public whenNotPaused {
        require(_pid < poolInfo.length, 'deposit: invalid pid');
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = _userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount * pool.accRwardPerShare / 1e12 - user.rewardDebt;
            if(pending > 0) {
                safeRewardTransfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            pool.token.transferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount + _amount;
        }
        user.rewardDebt = user.amount * pool.accRwardPerShare / 1e12;
        emit Deposit(msg.sender, _pid, _amount);
    }

    function safeRewardTransfer(address _to, uint256 _amount) internal {
        uint256 balance = rewardToken.balanceOf(address(this));
        if (_amount > balance) {
            rewardToken.transferFrom(address(this), _to, balance);
        } else {
            rewardToken.transferFrom(address(this), _to, _amount);
        }
    }
    
    function getMultiplier(uint256 _from, uint256 _to) public view whenNotPaused returns (uint256) {
        if (_to <= bonusEndBlock) {
            return _to - _from;
        } else if (_from >= bonusEndBlock) {
            return _to - _from;
        } else {
            return bonusEndBlock - _from;
        }
    }
    
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }
}