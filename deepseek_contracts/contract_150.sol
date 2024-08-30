// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TransparentUpgradeableProxy {
    address private _admin;
    address private _implementation;

    constructor(address admin_, address implementation_) {
        _admin = admin_;
        _implementation = implementation_;
    }

    modifier onlyAdmin() {
        require(msg.sender == _admin, "TransparentUpgradeableProxy: caller is not the admin");
        _;
    }

    function changeAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "TransparentUpgradeableProxy: new admin is the zero address");
        _admin = newAdmin;
    }

    function upgradeTo(address newImplementation) external onlyAdmin {
        require(newImplementation != address(0), "TransparentUpgradeableProxy: new implementation is the zero address");
        _implementation = newImplementation;
    }

    function implementation() external view returns (address) {
        return _implementation;
    }

    function admin() external view returns (address) {
        return _admin;
    }

    fallback() external payable {
        _fallback();
    }

    receive() external payable {
        _fallback();
    }

    function _fallback() internal {
        address impl = _implementation;
        require(impl != address(0), "TransparentUpgradeableProxy: implementation is not set");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}