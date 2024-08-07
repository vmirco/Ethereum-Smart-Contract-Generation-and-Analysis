// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SafeMath {
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

contract Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

contract SafeOperations is SafeMath, Address {
    function safeAdd(uint256 a, uint256 b) public pure returns (uint256) {
        return add(a, b);
    }

    function safeSub(uint256 a, uint256 b) public pure returns (uint256) {
        return sub(a, b);
    }

    function safeMul(uint256 a, uint256 b) public pure returns (uint256) {
        return mul(a, b);
    }

    function safeDiv(uint256 a, uint256 b) public pure returns (uint256) {
        return div(a, b);
    }

    function checkContract(address account) public view returns (bool) {
        return isContract(account);
    }

    function sendEther(address payable recipient) public payable {
        require(recipient != address(0), "Invalid recipient address");
        require(msg.value > 0, "Ether amount must be greater than zero");
        recipient.transfer(msg.value);
    }
}
```

This contract includes the SafeMath library for safe arithmetic operations and the Address library to check if an address is a contract. It provides functions for safe addition, subtraction, multiplication, and division, as well as a function to check if an address is a contract. Additionally, it includes a function to send Ether to a specified recipient with appropriate error handling.