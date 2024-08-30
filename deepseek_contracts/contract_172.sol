// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPoseidonHasher {
    function poseidon(uint256[2] memory input) external pure returns (uint256);
}

contract PoseidonHashRegistry {
    IPoseidonHasher private poseidonHasher;
    mapping(uint256 => uint256) public hashes;

    constructor(address _poseidonHasherAddress) {
        poseidonHasher = IPoseidonHasher(_poseidonHasherAddress);
    }

    function registerPoseidonHash(uint256[2] memory input) public {
        uint256 hash = poseidonHasher.poseidon(input);
        hashes[input[0]] = hash;
    }

    function getPoseidonHash(uint256[2] memory input) public view returns (uint256) {
        return poseidonHasher.poseidon(input);
    }
}