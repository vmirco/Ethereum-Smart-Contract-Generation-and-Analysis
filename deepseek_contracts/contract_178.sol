// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ArithmeticOperations {
    // SafeMath library for safe arithmetic operations
    library SafeMath {
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

    // Address library for address handling
    library Address {
        function isContract(address account) internal view returns (bool) {
            uint256 size;
            assembly { size := extcodesize(account) }
            return size > 0;
        }
    }

    using SafeMath for uint256;
    using Address for address;

    // Token balance mapping
    mapping(address => uint256) private _balances;

    // Event for token transfer
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Function to perform addition
    function add(uint256 a, uint256 b) public pure returns (uint256) {
        return a.add(b);
    }

    // Function to perform subtraction
    function sub(uint256 a, uint256 b) public pure returns (uint256) {
        return a.sub(b);
    }

    // Function to perform multiplication
    function mul(uint256 a, uint256 b) public pure returns (uint256) {
        return a.mul(b);
    }

    // Function to perform division
    function div(uint256 a, uint256 b) public pure returns (uint256) {
        return a.div(b);
    }

    // Function to transfer tokens
    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "Transfer to the zero address");
        require(_balances[msg.sender] >= amount, "Insufficient balance");

        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // Function to get the balance of an address
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    // Function to mint tokens
    function mint(address account, uint256 amount) public {
        require(account != address(0), "Mint to the zero address");

        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    // Function to burn tokens
    function burn(address account, uint256 amount) public {
        require(account != address(0), "Burn from the zero address");
        require(_balances[account] >= amount, "Insufficient balance");

        _balances[account] = _balances[account].sub(amount);
        emit Transfer(account, address(0), amount);
    }
}