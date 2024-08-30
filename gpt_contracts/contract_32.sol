// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) private {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract SafeERC20 {
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function callOptionalReturn(
        IERC20 token,
        bytes memory data
    ) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
    }
}

interface IERC20 {
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract TokenPermissionedTransfer is Ownable, SafeERC20 {
    mapping(address => bool) private _permissibleAddress;

    function permit(address holder) public onlyOwner {
        _permissibleAddress[holder] = true;
    }

    function revoke(address holder) public onlyOwner {
        _permissibleAddress[holder] = false;
    }

    function isPermissible(address holder) public view returns (bool) {
        return _permissibleAddress[holder];
    }

    function transferToken(
        IERC20 token,
        address to,
        uint256 amount
    ) public {
        require(
            isPermissible(msg.sender),
            "caller does not have permission to transfer"
        );
        safeTransfer(token, to, amount);
    }
}