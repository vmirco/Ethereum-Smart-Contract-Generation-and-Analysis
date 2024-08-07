// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MedianProtocol {
    struct CurrencyPair {
        uint256 rate;
        uint256 lastUpdate;
    }

    mapping(bytes32 => CurrencyPair) public currencyPairs;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function updateRate(bytes32 _currencyPair, uint256 _rate) external onlyOwner {
        currencyPairs[_currencyPair].rate = _rate;
        currencyPairs[_currencyPair].lastUpdate = block.timestamp;
    }

    function getRate(bytes32 _currencyPair) external view returns (uint256) {
        return currencyPairs[_currencyPair].rate;
    }

    function getLastUpdate(bytes32 _currencyPair) external view returns (uint256) {
        return currencyPairs[_currencyPair].lastUpdate;
    }

    function recoverSigner(bytes32 message, bytes memory signature) public pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (signature.length != 65) {
            return address(0);
        }

        // Divide the signature in r, s and v variables
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return address(0);
        } else {
            return ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", message)), v, r, s);
        }
    }
}