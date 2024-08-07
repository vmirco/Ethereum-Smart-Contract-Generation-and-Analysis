// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPoseidonHasher {
    function poseidon(uint256[] memory input) external pure returns (uint256);
}

contract PoseidonHashRegistry {
    struct HashRecord {
        uint256 hashValue;
        bool exists;
    }

    mapping(uint256 => HashRecord) public hashes;
    IPoseidonHasher public poseidonHasher;

    event HashRegistered(uint256 indexed inputHash, uint256 hashValue);

    constructor(address _poseidonHasherAddress) {
        poseidonHasher = IPoseidonHasher(_poseidonHasherAddress);
    }

    function registerHash(uint256[] memory input) public {
        uint256 inputHash = uint256(keccak256(abi.encodePacked(input)));
        require(!hashes[inputHash].exists, "Hash already registered");

        uint256 hashValue = poseidonHasher.poseidon(input);
        hashes[inputHash] = HashRecord(hashValue, true);

        emit HashRegistered(inputHash, hashValue);
    }

    function getHash(uint256[] memory input) public view returns (uint256) {
        uint256 inputHash = uint256(keccak256(abi.encodePacked(input)));
        require(hashes[inputHash].exists, "Hash not found");

        return hashes[inputHash].hashValue;
    }
}