// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IdentityVerifier {
    // Struct to store user identity information
    struct Identity {
        bool verified;
        bytes32 hash;
    }

    // Mapping from user address to their identity information
    mapping(address => Identity) public identities;

    // Event emitted when an identity is verified
    event IdentityVerified(address indexed user, bytes32 hash);

    // Function to verify a proof and store the hash
    function verifyProof(bytes32 proofHash) external {
        // Placeholder for actual World ID verification logic
        // In a real scenario, this would involve verifying the proofHash against World ID's API
        bool proofIsValid = true; // Assume proof is valid for demonstration purposes

        if (proofIsValid) {
            identities[msg.sender] = Identity({
                verified: true,
                hash: proofHash
            });
            emit IdentityVerified(msg.sender, proofHash);
        } else {
            revert("Proof verification failed");
        }
    }

    // Function to check if an address has a verified identity
    function isVerified(address user) external view returns (bool) {
        return identities[user].verified;
    }

    // Function to get the hash of a verified identity
    function getIdentityHash(address user) external view returns (bytes32) {
        require(identities[user].verified, "Identity not verified");
        return identities[user].hash;
    }

    // Example function that executes specific logic when a proof is verified
    function executeVerifiedLogic(address user) external {
        require(identities[user].verified, "Identity not verified");
        // Placeholder for specific logic to be executed
        // For example, granting access to certain functionalities or assets
    }
}