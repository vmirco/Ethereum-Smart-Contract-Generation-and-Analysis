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

contract AdvancedContract is Ownable {
    mapping(address => bool) private _whitelisted;
    mapping(address => bool) private _fundingManagers;
    mapping(address => bool) private _fundsUnlockers;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);
    event FundingManagerAdded(address indexed account);
    event FundingManagerRemoved(address indexed account);
    event FundsUnlockerAdded(address indexed account);
    event FundsUnlockerRemoved(address indexed account);

    modifier onlyWhitelisted() {
        require(_whitelisted[msg.sender], "Not whitelisted");
        _;
    }

    modifier onlyFundingManager() {
        require(_fundingManagers[msg.sender], "Not a funding manager");
        _;
    }

    modifier onlyFundsUnlocker() {
        require(_fundsUnlockers[msg.sender], "Not a funds unlocker");
        _;
    }

    function addWhitelisted(address account) public onlyOwner {
        _whitelisted[account] = true;
        emit WhitelistedAdded(account);
    }

    function removeWhitelisted(address account) public onlyOwner {
        _whitelisted[account] = false;
        emit WhitelistedRemoved(account);
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisted[account];
    }

    function addFundingManager(address account) public onlyOwner {
        _fundingManagers[account] = true;
        emit FundingManagerAdded(account);
    }

    function removeFundingManager(address account) public onlyOwner {
        _fundingManagers[account] = false;
        emit FundingManagerRemoved(account);
    }

    function isFundingManager(address account) public view returns (bool) {
        return _fundingManagers[account];
    }

    function addFundsUnlocker(address account) public onlyOwner {
        _fundsUnlockers[account] = true;
        emit FundsUnlockerAdded(account);
    }

    function removeFundsUnlocker(address account) public onlyOwner {
        _fundsUnlockers[account] = false;
        emit FundsUnlockerRemoved(account);
    }

    function isFundsUnlocker(address account) public view returns (bool) {
        return _fundsUnlockers[account];
    }
}