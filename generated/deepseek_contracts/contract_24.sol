// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PausableOwnable {
    address private _owner;
    bool private _paused;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Paused(address account);
    event Unpaused(address account);

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    constructor() {
        _owner = msg.sender;
        _paused = false;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    function pause() public onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}
```

### Overview of Contract Functionality

1. **Ownership Management:**
   - The contract starts with an owner, which is set to the deployer of the contract.
   - The `onlyOwner` modifier restricts certain functions to be called only by the owner.
   - The `renounceOwnership` function allows the current owner to relinquish control of the contract.
   - The `transferOwnership` function allows the current owner to transfer ownership to a new address.

2. **Pausable Functionality:**
   - The contract can be paused and unpaused, which affects all functions that use the `whenNotPaused` or `whenPaused` modifiers.
   - The `pause` function can be called by the owner to pause the contract, and the `unpause` function can be called by the owner to unpause it.
   - The `paused` function allows anyone to check the current pause status of the contract.

This contract combines the functionalities of ownership management and pausing mechanisms, providing a robust foundation for contracts that need these features.