// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SafeMathContract {
    // SafeMath library for safe arithmetic operations
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

    // Address library to check if an address is a contract
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    // Function to send Ether to a specified recipient
    function sendEther(address payable recipient) public payable {
        require(recipient != address(0), "Invalid address");
        require(msg.value > 0, "Amount must be greater than 0");
        recipient.transfer(msg.value);
    }
}

// Documentation:
// The SafeMathContract includes functions for safe arithmetic operations using the SafeMath library, which prevents overflow and underflow.
// The isContract function checks if an address is a contract by examining its code size.
// The sendEther function allows sending Ether to a specified recipient, ensuring the recipient address is valid and the amount is greater than 0.