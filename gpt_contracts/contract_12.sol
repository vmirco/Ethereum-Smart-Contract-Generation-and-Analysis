// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MerkleVerifier {
    
    function merkleVerify(bytes32 root, bytes32 leaf, bytes32[] memory proof) public pure returns (bool valid) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash < proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        // Check if the computed hash (root) is equal to the provided root
        return computedHash == root;
    }

    function getRoot(bytes32 leaf, bytes32[] memory proof) public pure returns (bytes32) {
        
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash < proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash;
    }

    function checkConsistency(bytes32 root, bytes32[] memory proof) public view returns (bool) {
        // Check if each proof element is hashed to derive the root
        bytes32 computedHash = root;
        
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            // Check consistency of each proof element
            if (keccak256(abi.encodePacked(proofElement, computedHash)) != root ||
                keccak256(abi.encodePacked(computedHash, proofElement)) != root) {
                return false;
            }
            computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
        }

        return true;
    }

}