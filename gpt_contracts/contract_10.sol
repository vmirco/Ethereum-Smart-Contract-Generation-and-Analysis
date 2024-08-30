// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

contract TokenGuard is Ownable, ReentrancyGuard {
    struct Deposit {
        uint256 amount;
        uint256 unlockDate;
    }

    mapping (address => Deposit) private _balances;

    event DepositMade(address indexed depositor, uint256 amount, uint256 unlockDate);
    event WithdrawalMade(address indexed depositor, uint256 amount);

    function deposit(uint256 amount, uint256 unlockDate) public nonReentrant {
        require(amount > 0, "Cannot deposit 0");
        require(unlockDate > block.timestamp, "Unlock date is not in the future");

        _balances[msg.sender].amount += amount;
        _balances[msg.sender].unlockDate = unlockDate;

        emit DepositMade(msg.sender, amount, unlockDate);
    }

    function withdraw() public nonReentrant {
        require(block.timestamp >= _balances[msg.sender].unlockDate, "Not yet unlocked");

        uint256 amount = _balances[msg.sender].amount;
        _balances[msg.sender].amount = 0;
        _balances[msg.sender].unlockDate = 0;

        payable(msg.sender).transfer(amount);
        emit WithdrawalMade(msg.sender, amount);
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account].amount;
    }
}