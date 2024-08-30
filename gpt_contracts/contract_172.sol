// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IPoseidonHasher {
    function poseidon(uint[] calldata elements) external pure returns (uint);
}

contract PoseidonHashStorage {

    address private hasherAddress;
    mapping(uint256 => uint256) private hashStorage;

    constructor(address _hasherAddress) {
        hasherAddress = _hasherAddress;
    }

    function registerHash(uint[] calldata elements) external {
        IPoseidonHasher hasher = IPoseidonHasher(hasherAddress);
        uint256 hash = hasher.poseidon(elements);
        hashStorage[hash] = 1;
    }

    function getHash(uint[] calldata elements) external view returns (uint256) {
        IPoseidonHasher hasher = IPoseidonHasher(hasherAddress);
        uint256 hash = hasher.poseidon(elements);
        require(hashStorage[hash] == 1, "Hash not registered");
        return hash;
    }

    function setHasherAddress(address _hasherAddress) internal {
        hasherAddress = _hasherAddress;
    }
}