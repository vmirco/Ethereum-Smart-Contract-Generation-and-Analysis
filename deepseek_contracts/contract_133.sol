// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract PaymentSplitter {
    address[] private payees;
    uint256[] private shares;
    mapping(address => uint256) private released;
    uint256 private totalReleased;

    event PaymentReleased(address to, uint256 amount);
    event ERC20PaymentReleased(IERC20 token, address to, uint256 amount);

    constructor(address[] memory _payees, uint256[] memory _shares) payable {
        require(_payees.length == _shares.length, "PaymentSplitter: payees and shares length mismatch");
        require(_payees.length > 0, "PaymentSplitter: no payees");

        for (uint256 i = 0; i < _payees.length; i++) {
            _addPayee(_payees[i], _shares[i]);
        }
    }

    function _addPayee(address _payee, uint256 _share) private {
        require(_payee != address(0), "PaymentSplitter: payee is the zero address");
        require(_share > 0, "PaymentSplitter: share is 0");
        payees.push(_payee);
        shares.push(_share);
    }

    function release(address payable _payee) public {
        uint256 totalReceived = address(this).balance + totalReleased;
        uint256 payment = (totalReceived * shares[indexOf(_payee)]) / totalShares() - released[_payee];

        require(payment != 0, "PaymentSplitter: _payee is not due payment");
        require(address(this).balance >= payment, "PaymentSplitter: not enough balance");

        released[_payee] += payment;
        totalReleased += payment;

        _payee.transfer(payment);
        emit PaymentReleased(_payee, payment);
    }

    function releaseERC20(IERC20 token, address _payee) public {
        uint256 totalReceived = token.balanceOf(address(this)) + totalReleased;
        uint256 payment = (totalReceived * shares[indexOf(_payee)]) / totalShares() - released[_payee];

        require(payment != 0, "PaymentSplitter: _payee is not due payment");
        require(token.balanceOf(address(this)) >= payment, "PaymentSplitter: not enough token balance");

        released[_payee] += payment;
        totalReleased += payment;

        require(token.transfer(_payee, payment), "PaymentSplitter: ERC20 transfer failed");
        emit ERC20PaymentReleased(token, _payee, payment);
    }

    function totalShares() public view returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < shares.length; i++) {
            total += shares[i];
        }
        return total;
    }

    function indexOf(address _payee) private view returns (uint256) {
        for (uint256 i = 0; i < payees.length; i++) {
            if (payees[i] == _payee) {
                return i;
            }
        }
        revert("PaymentSplitter: payee not found");
    }
}