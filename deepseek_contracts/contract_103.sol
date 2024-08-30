// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MedianProtocol {
    struct CurrencyPair {
        uint256 rate;
        uint256 lastUpdated;
    }

    mapping(bytes32 => CurrencyPair) public currencyPairs;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function updateRate(bytes32 _currencyPair, uint256 _rate) external onlyOwner {
        currencyPairs[_currencyPair].rate = _rate;
        currencyPairs[_currencyPair].lastUpdated = block.timestamp;
    }

    function getRate(bytes32 _currencyPair) external view returns (uint256) {
        return currencyPairs[_currencyPair].rate;
    }

    function recoverSigner(bytes32 message, bytes memory sig) public pure returns (address) {
        require(sig.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid signature recovery id");

        return ecrecover(message, v, r, s);
    }
}