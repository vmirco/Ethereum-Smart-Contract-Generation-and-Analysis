// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// "npm install @openzeppelin/contracts"
// Import OpenZeppelin's contracts
// import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

interface IAdminFacet {
    function getLenderAddress() external view returns (address);
}

interface ILendingFacet {
    function deposit(uint256 amount) external;
    function withdraw(uint256 amount) external;
}

contract LendingContract is ReentrancyGuardUpgradeable {
    mapping (address => uint256) private _balances;
    address private _lender;

    function initialize(address lender) public {
        _lender = lender;
        __ReentrancyGuard_init();
    }

    function getBalance(address account) public view returns (uint256) {
        return _balances[account];
    }

    function deposit(uint256 amount) public nonReentrant {
        _balances[msg.sender] += amount;
    }

    function withdraw(uint256 amount) public nonReentrant {
        require(_balances[msg.sender] >= amount, "Not enough balance");
        _balances[msg.sender] -= amount;
    }

    function getLenderAddress() public view returns (address) {
        return _lender;
    }
}