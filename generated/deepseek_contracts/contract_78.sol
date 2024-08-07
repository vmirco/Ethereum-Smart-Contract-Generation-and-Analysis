// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Initializable {
    bool inited = false;

    modifier initializer() {
        require(!inited, "already inited");
        _;
        inited = true;
    }
}

library AddressUpgradeable {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

contract Wallet is Initializable {
    mapping(address => uint256) private balances;

    function initialize() public initializer {
        // Initialization code, if any
    }

    function increaseBalance(address wallet, uint256 amount) external {
        require(wallet != address(0), "Invalid wallet address");
        balances[wallet] += amount;
    }

    function transfer(address to, uint256 amount) external {
        require(to != address(0), "Invalid target address");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }

    function getBalance(address wallet) external view returns (uint256) {
        return balances[wallet];
    }
}