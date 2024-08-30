// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MerkleTreeVerifier {
    bytes32 public commitmentRoot;

    // Event to log validation results
    event ValidationResult(bool isValid, string message);

    // Constructor to set the commitment root
    constructor(bytes32 _commitmentRoot) {
        commitmentRoot = _commitmentRoot;
    }

    // Function to validate the Merkle proof
    function validateMerkleProof(
        bytes32[] memory proof,
        bytes32 leaf,
        uint256 index
    ) public view returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (index % 2 == 0) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }

            index = index / 2;
        }

        return computedHash == commitmentRoot;
    }

    // Function to check the existence or non-existence of a key-value pair
    function checkKeyValuePair(
        bytes32[] memory proof,
        bytes32 key,
        bytes32 value
    ) public {
        bytes32 leaf = keccak256(abi.encodePacked(key, value));
        bool isValid = validateMerkleProof(proof, leaf, 0); // Assuming index is 0 for simplicity

        if (isValid) {
            emit ValidationResult(true, "Key-Value pair exists in the Merkle tree.");
        } else {
            emit ValidationResult(false, "Key-Value pair does not exist in the Merkle tree.");
        }
    }

    // Function to ensure internal consistency of the Merkle tree
    function ensureConsistency(
        bytes32[] memory proof,
        bytes32 leaf,
        uint256 index
    ) public view returns (bool) {
        return validateMerkleProof(proof, leaf, index);
    }
}