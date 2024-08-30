// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable {
    address private _owner;
    address private _pendingOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferPending(address indexed currentOwner, address indexed pendingOwner);

    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner, bool direct) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        if (direct) {
            _transferOwnership(newOwner);
        } else {
            _pendingOwner = newOwner;
            emit OwnershipTransferPending(_owner, newOwner);
        }
    }

    function claimOwnership() public {
        require(msg.sender == _pendingOwner, "Ownable: caller is not the pending owner");
        _transferOwnership(msg.sender);
    }

    function _transferOwnership(address newOwner) internal {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
        _pendingOwner = address(0);
    }
}