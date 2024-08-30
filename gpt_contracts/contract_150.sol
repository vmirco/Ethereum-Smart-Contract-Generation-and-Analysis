// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TransparentUpgradeableProxy {
    bytes32 private constant _ADMIN_SLOT = 0xb1f109e973300cf66f8b24f15326f30fc6e2e36b7c0e8e02e9c25d9d60584e93;
    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    constructor(address _logic, address admin_) payable {
        assert(_ADMIN_SLOT == keccak256("eip1967.proxy.admin"));
        assert(_IMPLEMENTATION_SLOT == keccak256("eip1967.proxy.implementation"));
        _setImplementation(_logic);
        _setAdmin(admin_);
    }

    function _implementation() public view returns (address impl) {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function _admin() public view returns (address admin) {
        bytes32 slot = _ADMIN_SLOT;
        assembly {
            admin := sload(slot)
        }
    }

    function _setImplementation(address newImplementation) internal {
        bytes32 slot = _IMPLEMENTATION_SLOT;

        assembly {
            sstore(slot, newImplementation)
        }
    }

    function _setAdmin(address newAdmin) internal {
        bytes32 slot = _ADMIN_SLOT;

        assembly {
            sstore(slot, newAdmin)
        }
    }

    function upgradeTo(address newImplementation) public {
        require(msg.sender == _admin());
        require(newImplementation != _implementation(), 'Cannot upgrade to the same implementation');
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function changeAdmin(address newAdmin) public {
        require(msg.sender == _admin());
        require(newAdmin != _admin(), 'New admin is the current admin');
        _setAdmin(newAdmin);
    }
    
    fallback() external payable {
        address _impl = _implementation();
        require(_impl != address(0));

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}