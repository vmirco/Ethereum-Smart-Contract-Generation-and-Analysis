// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Copied from OpenZeppelin library
abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Contract instance has already been initialized");
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

    function _isConstructor() private view returns (bool) {
        return !address(this).getCodeSize() > 0;
    }
}

// Copied from OpenZeppelin library
library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

contract Wallet is Initializable {
    using AddressUpgradeable for address;
    mapping(address => uint256) private _balances;

    function initialize() public initializer {
        _balances[msg.sender] = 10000; //for testing, it assigns an initial balance of 10k to the contract deployer
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function isContract(address account) public view returns (bool) {
        return account.isContract();
    }

    function sendMoney(address recipient, uint256 amount)
        public
        returns (bool)
    {
        require(!isContract(recipient), "Wallet: contract address provided instead of wallet address");
        require(_balances[msg.sender] >= amount, "Wallet: insufficient balance for transaction");
        require(recipient != address(0), "Wallet: transfer to the zero address");

        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;

        return true;
    }
}