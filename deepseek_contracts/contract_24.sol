// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PausableOwnable {
    address private _owner;
    bool private _paused;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Paused(address account);
    event Unpaused(address account);

    modifier onlyOwner() {
        require(owner() == msg.sender, "PausableOwnable: caller is not the owner");
        _;
    }

    modifier whenNotPaused() {
        require(!_paused, "PausableOwnable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "PausableOwnable: not paused");
        _;
    }

    constructor() {
        _transferOwnership(msg.sender);
        _paused = false;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "PausableOwnable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function pause() public onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    function _transferOwnership(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/*
Overview:
- The contract PausableOwnable combines the functionalities of Ownable and Pausable contracts.
- It allows the contract owner to pause and unpause the contract, transfer ownership, and renounce ownership.
- The contract uses modifiers to restrict certain functions to the owner only and to enforce paused/unpaused states.
- Events are emitted for important state changes such as ownership transfer, pausing, and unpausing.
- The constructor initializes the contract with the deployer as the owner and the contract in an unpaused state.
*/