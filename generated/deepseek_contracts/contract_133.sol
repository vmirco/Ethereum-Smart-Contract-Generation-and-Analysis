// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract PaymentSplitter {
    address[] private payees;
    uint256[] private shares;
    uint256 private totalShares;
    uint256 private totalReleased;
    mapping(address => uint256) private released;
    mapping(address => uint256) private tokenReleased;
    IERC20 private erc20Token;

    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event ERC20PaymentReleased(address token, address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    constructor(address[] memory _payees, uint256[] memory _shares, address _erc20Token) {
        require(_payees.length == _shares.length, "PaymentSplitter: payees and shares length mismatch");
        require(_payees.length > 0, "PaymentSplitter: no payees");

        for (uint256 i = 0; i < _payees.length; i++) {
            addPayee(_payees[i], _shares[i]);
        }

        erc20Token = IERC20(_erc20Token);
    }

    receive() external payable {
        emit PaymentReceived(msg.sender, msg.value);
    }

    function totalShares() public view returns (uint256) {
        return totalShares;
    }

    function totalReleased() public view returns (uint256) {
        return totalReleased;
    }

    function shares(address account) public view returns (uint256) {
        return shares[indexOf(account)];
    }

    function released(address account) public view returns (uint256) {
        return released[account];
    }

    function tokenReleased(address account) public view returns (uint256) {
        return tokenReleased[account];
    }

    function payee(uint256 index) public view returns (address) {
        return payees[index];
    }

    function release(address account) public {
        uint256 totalReceived = address(this).balance + totalReleased;
        uint256 payment = pendingPayment(account, totalReceived, released[account]);

        require(payment != 0, "PaymentSplitter: account is not due payment");

        released[account] += payment;
        totalReleased += payment;

        payable(account).transfer(payment);
        emit PaymentReleased(account, payment);
    }

    function releaseERC20(address account) public {
        uint256 totalReceived = erc20Token.balanceOf(address(this)) + tokenReleased[account];
        uint256 payment = pendingPayment(account, totalReceived, tokenReleased[account]);

        require(payment != 0, "PaymentSplitter: account is not due ERC20 payment");

        tokenReleased[account] += payment;

        require(erc20Token.transfer(account, payment), "PaymentSplitter: ERC20 transfer failed");
        emit ERC20PaymentReleased(address(erc20Token), account, payment);
    }

    function pendingPayment(address account, uint256 totalReceived, uint256 alreadyReleased) private view returns (uint256) {
        uint256 share = shares[indexOf(account)];
        return (totalReceived * share) / totalShares - alreadyReleased;
    }

    function addPayee(address account, uint256 _shares) private {
        require(account != address(0), "PaymentSplitter: account is the zero address");
        require(_shares > 0, "PaymentSplitter: shares are 0");
        require(shares[indexOf(account)] == 0, "PaymentSplitter: account already has shares");

        payees.push(account);
        shares.push(_shares);
        totalShares += _shares;

        emit PayeeAdded(account, _shares);
    }

    function indexOf(address account) private view returns (uint256) {
        for (uint256 i = 0; i < payees.length; i++) {
            if (payees[i] == account) {
                return i;
            }
        }
        revert("PaymentSplitter: account not found");
    }
}