// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GMTokenUnwrapper {
    address public gmTokenAddress;
    bool public unwrapLocked;
    uint256 public unwrapInterval;

    mapping(address => uint256) public lastUnwrapTime;
    mapping(address => uint256) public unwrappedAmount;

    event Unwrapped(address indexed user, uint256 amount);
    event UnwrapLocked(bool status);
    event GMTokenAddressChanged(address newAddress);

    modifier whenUnwrapUnlocked() {
        require(!unwrapLocked, "Unwrap is locked");
        _;
    }

    modifier onlyOwner() {
        // Assuming owner is the deployer of the contract
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    address private owner;

    constructor(address _gmTokenAddress, uint256 _unwrapInterval) {
        gmTokenAddress = _gmTokenAddress;
        unwrapInterval = _unwrapInterval;
        owner = msg.sender;
    }

    function setUnwrapLocked(bool _status) external onlyOwner {
        unwrapLocked = _status;
        emit UnwrapLocked(_status);
    }

    function changeGMTokenAddress(address _newAddress) external onlyOwner {
        gmTokenAddress = _newAddress;
        emit GMTokenAddressChanged(_newAddress);
    }

    function unwrap(uint256 amount) external whenUnwrapUnlocked {
        require(canUnwrap(msg.sender), "Unwrap interval not met");
        require(amount <= maxUnwrapAmount(msg.sender), "Exceeds max unwrap amount");

        // Assuming transferFrom function exists in the GMToken contract
        require(IGMToken(gmTokenAddress).transferFrom(msg.sender, address(this), amount), "Transfer failed");

        unwrappedAmount[msg.sender] += amount;
        lastUnwrapTime[msg.sender] = block.timestamp;

        emit Unwrapped(msg.sender, amount);
    }

    function canUnwrap(address user) public view returns (bool) {
        return block.timestamp >= lastUnwrapTime[user] + unwrapInterval;
    }

    function maxUnwrapAmount(address user) public view returns (uint256) {
        // Placeholder logic for maximum unwrap amount calculation
        // This should be replaced with actual logic based on the token's economics
        return IGMToken(gmTokenAddress).balanceOf(user);
    }
}

interface IGMToken {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}