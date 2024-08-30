// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReentrancyGuard {
    uint256 private _guardCounter;

    constructor () {
        _guardCounter = 1;
    }

    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "Reentrant call");
    }
}

abstract contract Pausable {
    bool private _paused;

    event Paused(address sender);

    event Unpaused(address sender);

    function _pause() internal {
        _paused = true;
        emit Paused(msg.sender);
    }

    function _unpause() internal {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }
}

abstract contract VolumeControl is Pausable, ReentrancyGuard {
    uint256 private _maxVolume;

    constructor(uint256 maxVolume_) {
        _maxVolume = maxVolume_;
    }

    function _volumeCheck(uint256 amount) internal view {
        require(amount <= _maxVolume, "VolumeControl: volume exceeded");
    }

    function setMaxVolume(uint256 maxVolume_) public whenPaused {
        _maxVolume = maxVolume_;
    }

    modifier volumeControlled(uint256 amount) {
        _volumeCheck(amount);
        _;
    }
}

abstract contract DelayedTransfer is ReentrancyGuard {
    struct Transfer {
        address token;
        address recipient;
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => Transfer) private _pendingTransfers;

    function _delayTransfer(address token, address recipient, uint256 amount, uint256 delay) internal {
        Transfer memory newTransfer;
        newTransfer.token = token;
        newTransfer.recipient = recipient;
        newTransfer.amount = amount;
        newTransfer.timestamp = block.timestamp + delay;
        _pendingTransfers[msg.sender] = newTransfer;
    }

    function executeTransfer(address recipient) public nonReentrant {
        Transfer memory transfer = _pendingTransfers[recipient];
        require(block.timestamp >= transfer.timestamp , "Transfer not yet due");
        delete _pendingTransfers[recipient];
        // _transfer(transfer.token, transfer.recipient, transfer.amount); // This should be a function which handles the actual transfer.
    }
}

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IWETH {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
    function approve(address spender, uint256 amount) external returns (bool);
}

contract OriginalTokenVault is VolumeControl, DelayedTransfer {
    address private _sigsVerifier;
    mapping (address => uint256) private _balances;

    event Deposited(address indexed depositor, uint256 amount);
    event Withdrawn(address indexed withdrawer, uint256 amount);
    
    constructor(address sigsVerifier_) {
        _sigsVerifier = sigsVerifier_;
    }

    function deposit(address token, uint256 amount) public volumeControlled(amount) whenNotPaused nonReentrant {
        // Transfer tokens to this contract
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        // Update internal balance
        _balances[msg.sender] += amount;

        emit Deposited(msg.sender, amount);
    }

    function withdraw(address token, uint256 amount) public whenNotPaused nonReentrant {
        require(_balances[msg.sender] >= amount, "Insufficient balance");

        // Deduct balance
        _balances[msg.sender] -= amount;

        // Schedule token withdrawal
        _delayTransfer(token, msg.sender, amount, 1 days);

        emit Withdrawn(msg.sender, amount);
    }

    function currentBalance(address token) public view returns (uint256) {
        return _balances[token];
    }

}