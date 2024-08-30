// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC1822Proxiable {
    function proxiableUUID() external view returns (bytes32);
    function updateCodeAddress(address newAddress) external;
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

library StorageSlot {
    struct AddressSlot {
        address value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

contract MyContract is IERC1822Proxiable {
    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function proxiableUUID() external pure override returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    function updateCodeAddress(address newAddress) external override {
        require(Address.isContract(newAddress), "New address is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newAddress;
    }

    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    fallback() external payable {
        _delegate(StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value);
    }

    receive() external payable {
        _delegate(StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value);
    }
}