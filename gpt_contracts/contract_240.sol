// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Permissioned Access Control and EntryPoint Contract in Solidity

contract AccessControl {

    struct Operator {
        address operatorAddress;
        bool hasPermission;
    }
    
    struct FeesAndValues {
        uint256 remainingFee;
        uint256 remainingValue;
    }

    mapping(address => Operator) public operators;
    
    mapping(address => FeesAndValues) public feesAndValues;

    bytes32 public DOMAIN_SEPARATOR;
    string public NAME;
    string public VERSION;
    
    bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );
    
    constructor (string memory name_, string memory version_) {
        NAME = name_;
        VERSION = version_;
        
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                EIP712DOMAIN_TYPEHASH,
                keccak256(bytes(NAME)),
                keccak256(bytes(VERSION)),
                block.chainid,
                address(this)
            )
        );
    }

    function setPermissions(address operatorAddress, bool hasPermission) public {
        Operator memory operator;
        operator.operatorAddress = operatorAddress;
        operator.hasPermission = hasPermission;
        operators[operatorAddress] = operator;
    }

    function checkPermission(address operatorAddress) public view returns(bool) {
        return operators[operatorAddress].hasPermission;
    }
    
    function setFeesAndValues(address userAddress, uint256 remainingFee, uint256 remainingValue) public {
        FeesAndValues memory data;
        data.remainingFee = remainingFee;
        data.remainingValue = remainingValue;
        
        feesAndValues[userAddress] = data;
    }

    function isValidSignature(
        bytes32 hash,
        bytes memory signature
    ) public view returns(bool) {
        address recoveredAddress = recover(hash, signature);

        return operators[recoveredAddress].hasPermission;
    }
    
    // ECDSA recovery function
    function recover(bytes32 hash, bytes memory signature)
        private
        pure
        returns (address)
    {
        if (signature.length != 65) {
            revert();
        }
        
        bytes32 r;
        bytes32 s;
        uint8 v;
        
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }
}