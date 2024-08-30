pragma solidity ^0.8.0;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        if (!success) { revert('Unsuccessful'); }
    }
    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 weiValue) internal returns (bytes memory) {
        require(isContract(target), "Target address is not a contract");
        (bool success, bytes memory result) = target.call{ value: weiValue }(data);
        return _verifyCallResult(success, result, "Low-level call failed");
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory revertReason) internal pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(revertReason);
            }
        }
    }
}

library StorageSlot {
    struct Uint256Slot { uint256 value; }
    struct AddressSlot { address value; }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly { r.slot := slot }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly { r.slot := slot }
    }
}

contract ProxiableContract {
    bytes32 constant IMPLEMENTATION_SLOT = keccak256("ProxiableContract.implementation");
    
    modifier onlyProxy() {
        require(isProxy(), "Only proxy can call");
        _;
    }
    
    function isProxy() internal view returns (bool) {
        return Address.isContract(_implementation());
    }
    
    function _implementation() internal view returns (address impl) {
        impl = StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    function proxiableUUID() public pure virtual returns (bytes32) {
        return keccak256("org.1820a.proxiable");
    }

    function updateCode(address newAddress) internal onlyProxy {
        require(Address.isContract(newAddress), "Cannot set a proxy implementation to a non-contract address");
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = newAddress;
    }

    function updateCodeAndCall(address newCode, bytes calldata data) payable onlyProxy returns(bytes memory) {
        updateCode(newCode);
        return Address.functionCallWithValue(newCode, data, msg.value);
    }
}