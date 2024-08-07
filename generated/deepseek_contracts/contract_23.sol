// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LendingContract {
    address public admin;
    mapping(address => uint256) public balances;
    bool internal locked;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    modifier noReentrancy() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    constructor() {
        admin = msg.sender;
    }

    function deposit(uint256 amount) external noReentrancy {
        balances[msg.sender] += amount;
        // Assuming ERC20 transfer from msg.sender to this contract
        // ERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) external noReentrancy {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        // Assuming ERC20 transfer from this contract to msg.sender
        // ERC20(tokenAddress).transfer(msg.sender, amount);
    }

    function changeAdmin(address newAdmin) external onlyAdmin {
        admin = newAdmin;
    }
}

interface ILendingFacet {
    function deposit(uint256 amount) external;
    function withdraw(uint256 amount) external;
}

interface IAdminFacet {
    function changeAdmin(address newAdmin) external;
}