// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
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

contract RoleManager is Ownable {
    mapping(address => bool) private _whitelistedAddresses;
    mapping(address => bool) private _fundingManagers;
    mapping(address => bool) private _fundsUnlockers;

    event AddressAdded(address indexed addr, string role);
    event AddressRemoved(address indexed addr, string role);

    function addWhitelistedAddress(address addr) external onlyOwner {
        _whitelistedAddresses[addr] = true;
        emit AddressAdded(addr, "whitelisted");
    }

    function removeWhitelistedAddress(address addr) external onlyOwner {
        _whitelistedAddresses[addr] = false;
        emit AddressRemoved(addr, "whitelisted");
    }

    function isWhitelisted(address addr) public view returns (bool) {
        return _whitelistedAddresses[addr];
    }

    function addFundingManager(address addr) external onlyOwner {
        _fundingManagers[addr] = true;
        emit AddressAdded(addr, "fundingManager");
    }

    function removeFundingManager(address addr) external onlyOwner {
        _fundingManagers[addr] = false;
        emit AddressRemoved(addr, "fundingManager");
    }

    function isFundingManager(address addr) public view returns (bool) {
        return _fundingManagers[addr];
    }

    function addFundsUnlocker(address addr) external onlyOwner {
        _fundsUnlockers[addr] = true;
        emit AddressAdded(addr, "fundsUnlocker");
    }

    function removeFundsUnlocker(address addr) external onlyOwner {
        _fundsUnlockers[addr] = false;
        emit AddressRemoved(addr, "fundsUnlocker");
    }

    function isFundsUnlocker(address addr) public view returns (bool) {
        return _fundsUnlockers[addr];
    }
}