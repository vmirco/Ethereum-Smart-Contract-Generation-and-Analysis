// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableBank {
    mapping (address => uint256) private balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance.");

        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed.");

        balances[msg.sender] -= _amount;
    }

    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}