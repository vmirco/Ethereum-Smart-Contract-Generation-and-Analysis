// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TransparentUpgradeableProxy {
    address private _admin;
    address private _implementation;

    event Upgraded(address indexed implementation);
    event AdminChanged(address previousAdmin, address newAdmin);

    constructor(address _logic, address admin_, bytes memory _data) payable {
        _setAdmin(admin_);
        _setImplementation(_logic);
        if (_data.length > 0) {
            (bool success, ) = _logic.delegatecall(_data);
            require(success, "Proxy: data execution failed");
        }
    }

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Proxy: caller is not the admin");
        _;
    }

    function upgradeTo(address newImplementation) external onlyAdmin {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable onlyAdmin {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
        (bool success, ) = newImplementation.delegatecall(data);
        require(success, "Proxy: data execution failed");
    }

    function changeAdmin(address newAdmin) external onlyAdmin {
        emit AdminChanged(_admin, newAdmin);
        _setAdmin(newAdmin);
    }

    function getAdmin() external view returns (address) {
        return _admin;
    }

    function getImplementation() external view returns (address) {
        return _implementation;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "Proxy: new admin is the zero address");
        _admin = newAdmin;
    }

    function _setImplementation(address newImplementation) private {
        require(newImplementation != address(0), "Proxy: new implementation is the zero address");
        _implementation = newImplementation;
    }

    fallback() external payable {
        _fallback();
    }

    receive() external payable {
        _fallback();
    }

    function _fallback() private {
        _delegate(_implementation);
    }

    function _delegate(address implementation) private {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}