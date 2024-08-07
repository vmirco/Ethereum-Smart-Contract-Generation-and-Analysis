// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MerkleTreeVerifier {
    bytes32 public commitmentRoot;

    // Event to log validation results
    event ValidationResult(bool isValid);

    // Constructor to set the commitment root
    constructor(bytes32 _commitmentRoot) {
        commitmentRoot = _commitmentRoot;
    }

    // Function to verify the existence of a key-value pair in the Merkle tree
    function verifyExistence(
        bytes32[] memory proof,
        bytes32 leaf,
        uint256 index,
        bytes32 root
    ) public view returns (bool) {
        require(root == commitmentRoot, "Provided root does not match the commitment root");
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

        return computedHash == root;
    }

    // Function to validate the commitment root and leaf node
    function validateCommitment(
        bytes32[] memory proof,
        bytes32 leaf,
        uint256 index
    ) public {
        bool isValid = verifyExistence(proof, leaf, index, commitmentRoot);
        emit ValidationResult(isValid);
    }

    // Function to check internal consistency of the Merkle tree
    function checkConsistency(
        bytes32[] memory proof,
        bytes32 leaf,
        uint256 index,
        bytes32 root
    ) public view returns (bool) {
        return verifyExistence(proof, leaf, index, root);
    }
}