// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SevenToken {
    mapping (address => uint) private _balances;
    address private _owner;

    event Withdrew(address indexed user, uint amount);

    modifier onlyOwner () {
        require(msg.sender == _owner, "Only owner can call this function.");
        _;
    }

    constructor() {
        _owner = msg.sender;
    }
    
    function deposit() public payable {
        _balances[msg.sender] += msg.value;
    }
    
    function withdraw(uint amount) public {
        require(_balances[msg.sender] >= amount, "Not enough Ether for withdrawal.");
        _balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrew(msg.sender, amount);
    }

    function getBalance(address userAddress) public view returns(uint) {
        return _balances[userAddress];
    }

    function getTotalBalance() public view onlyOwner returns(uint) {
        return address(this).balance;
    }

    fallback() external payable {
        deposit();
    }
}