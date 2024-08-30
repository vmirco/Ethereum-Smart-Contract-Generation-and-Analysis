// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}

contract InitializableContract {
    using SafeMath for uint256;

    address private _owner;
    uint256 private _version;
    bool private _initialized;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Not the contract owner");
        _;
    }

    modifier notInitialized() {
        require(!_initialized, "Already initialized");
        _;
    }

    modifier initialized() {
        require(_initialized, "Not initialized yet");
        _;
    }

    constructor() {
        _owner = msg.sender;
        _version = 0;
        _initialized = false;
    }

    function initialize(uint256 version) public onlyOwner notInitialized {
        _version = version;
        _initialized = true;
    }

    function reinitialize(uint256 newVersion) public onlyOwner initialized {
        _version = newVersion;
    }

    function getVersion() public view returns (uint256) {
        return _version;
    }

    function isInitialized() public view returns (bool) {
        return _initialized;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        _owner = newOwner;
    }

    function getOwner() public view returns (address) {
        return _owner;
    }

    function sendValue(address payable recipient, uint256 amount) public onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Transfer failed");
    }

    receive() external payable {}
}