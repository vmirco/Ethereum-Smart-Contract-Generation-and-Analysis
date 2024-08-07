// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Initializable {
    uint256 private _version;
    bool private _initialized;
    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Contract instance has already been initialized");
        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier reinitializer(uint256 version) {
        require(!_initializing && _initialized && version == _version + 1, "Invalid version for reinitialization");
        _initializing = true;
        _version = version;
        _;
        _initialized = true;
        _initializing = false;
    }

    function getVersion() public view returns (uint256) {
        return _version;
    }
}

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

contract MyContract is Initializable {
    using SafeMath for uint256;

    uint256 public value;

    function initialize(uint256 initialValue) public initializer {
        value = initialValue;
    }

    function reinitialize(uint256 newVersion, uint256 newValue) public reinitializer(newVersion) {
        value = newValue;
    }

    function sendValue(address payable recipient, uint256 amount) public {
        require(address(this).balance >= amount, "Insufficient balance");
        recipient.transfer(amount);
    }
}