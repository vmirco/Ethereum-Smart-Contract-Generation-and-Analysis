// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

contract ReentrancyGuard {
    bool private _notEntered;

    constructor () {
        _notEntered = true;
    }

    modifier nonReentrant() {
        require(_notEntered, "ReentrancyGuard: reentrant call");
        _notEntered = false;
        _;
        _notEntered = true;
    }
}

contract Pauser {
    bool private _paused;

    constructor () {
        _paused = false;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pauser: paused");
        _;
    }

    function pause() public {
        _paused = true;
    }

    function unpause() public {
        _paused = false;
    }
}

contract VolumeControl {
    uint256 private _dailyLimit;
    uint256 private _usedToday;
    uint256 private _dayStart;

    constructor (uint256 dailyLimit) {
        _dailyLimit = dailyLimit;
        _usedToday = 0;
        _dayStart = block.timestamp;
    }

    modifier withinLimit(uint256 amount) {
        if (block.timestamp >= _dayStart + 1 days) {
            _dayStart = block.timestamp;
            _usedToday = 0;
        }
        require(_usedToday + amount <= _dailyLimit, "VolumeControl: daily limit exceeded");
        _;
        _usedToday += amount;
    }
}

contract DelayedTransfer {
    struct Transfer {
        address recipient;
        uint256 amount;
        uint256 unlockTime;
    }

    mapping(address => Transfer) private _transfers;

    function scheduleTransfer(address recipient, uint256 amount, uint256 delay) public {
        _transfers[msg.sender] = Transfer(recipient, amount, block.timestamp + delay);
    }

    function executeTransfer(address sender) public {
        Transfer storage transfer = _transfers[sender];
        require(block.timestamp >= transfer.unlockTime, "DelayedTransfer: transfer is still locked");
        IERC20(msg.sender).transfer(transfer.recipient, transfer.amount);
        delete _transfers[sender];
    }
}

contract OriginalTokenVault is ReentrancyGuard, Pauser, VolumeControl, DelayedTransfer {
    address public sigsVerifier;
    IERC20 public token;
    IWETH public weth;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    constructor(address _sigsVerifier, address _token, address _weth, uint256 dailyLimit) VolumeControl(dailyLimit) {
        sigsVerifier = _sigsVerifier;
        token = IERC20(_token);
        weth = IWETH(_weth);
    }

    function depositTokens(uint256 amount) public whenNotPaused nonReentrant withinLimit(amount) {
        require(token.transferFrom(msg.sender, address(this), amount), "OriginalTokenVault: token transfer failed");
        emit Deposit(msg.sender, amount);
    }

    function withdrawTokens(uint256 amount) public whenNotPaused nonReentrant {
        require(token.balanceOf(address(this)) >= amount, "OriginalTokenVault: insufficient balance");
        require(token.transfer(msg.sender, amount), "OriginalTokenVault: token transfer failed");
        emit Withdrawal(msg.sender, amount);
    }

    function depositETH() public payable whenNotPaused nonReentrant {
        weth.deposit{value: msg.value}();
        emit Deposit(msg.sender, msg.value);
    }

    function withdrawETH(uint256 amount) public whenNotPaused nonReentrant {
        weth.withdraw(amount);
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "OriginalTokenVault: ETH transfer failed");
        emit Withdrawal(msg.sender, amount);
    }
}