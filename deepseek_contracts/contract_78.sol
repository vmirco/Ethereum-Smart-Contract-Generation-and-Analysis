// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Initializable {
    bool private _initialized;
    bool private _initializing;

    modifier initializer() {
        require(!_initialized, "Initializable: contract is already initialized");
        _;
    }

    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            isTopLevelCall && !_initialized,
            "Initializable: contract is already initialized"
        );
        _initialized = true;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
        }
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

contract WalletBalance is Initializable {
    mapping(address => uint256) private balances;

    function initialize() public initializer {
        // Initialization code
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