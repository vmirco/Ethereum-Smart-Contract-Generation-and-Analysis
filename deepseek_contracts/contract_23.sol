// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LendingContract {
    address public owner;
    mapping(address => uint256) public balances;
    bool internal locked;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier noReentrancy() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public noReentrancy {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

    function getBalance(address account) public view returns (uint256) {
        return balances[account];
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

interface ILendingFacet {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}

interface IAdminFacet {
    function transferOwnership(address newOwner) external;
}

// Note: OpenZeppelin's libraries for proxy and clone contracts are not included here as per the instruction to not use import statements.
// However, their functionality would typically be integrated into a full implementation to handle proxy and clone logic securely.