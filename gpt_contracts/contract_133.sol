// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Simplified ERC20 interface
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract PaymentSplitter {
    address[] private _payees;
    mapping(address => uint256) private _shares;
    mapping(address => uint256) private _released;
    uint256 private _totalShares;
    uint256 private _totalReleased;
   
    constructor(address[] memory payees, uint256[] memory shares_) {
        require(payees.length == shares_.length, "PaymentSplitter: payees and shares length mismatch");
        require(payees.length > 0, "PaymentSplitter: no payees");

        for (uint256 i = 0; i < payees.length; i++) {
            address payee = payees[i];
            uint256 shares = shares_[i];
            _addPayee(payee, shares);
        }
    }

    receive() external payable {
        uint256 balance = address(this).balance;
        for (uint256 i = 0; i < _payees.length; i++) {
            uint256 payment = (balance * _shares[_payees[i]]) / _totalShares;
            _released[_payees[i]] += payment;
            _totalReleased += payment;
            payable(_payees[i]).transfer(payment);
        }
    }
   
    function releaseERC20(IERC20 token) public {
        uint256 balance = token.balanceOf(address(this));
        for (uint256 i = 0; i < _payees.length; i++) {
            uint256 payment = (balance * _shares[_payees[i]]) / _totalShares;
            _released[_payees[i]] += payment;
            _totalReleased += payment;
            token.transfer(_payees[i], payment);
        }
    }

    function totalShares() public view returns (uint256) {
        return _totalShares;
    }

    function shares(address account) public view returns (uint256) {
        return _shares[account];
    }

    function released(address account) public view returns (uint256) {
        return _released[account];
    }

    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }

    function payees(uint256 index) public view returns (address) {
        return _payees[index];
    }

    function _addPayee(address account, uint256 shares_) private {
        require(account != address(0), "PaymentSplitter: account is the zero address");
        require(shares_ > 0, "PaymentSplitter: shares are 0");
        require(_shares[account] == 0, "PaymentSpitter: account already has shares");

        _payees.push(account);
        _shares[account] = shares_;
        _totalShares += shares_;
    }
}