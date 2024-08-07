// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IdentityVerifier {
    // World ID verification status
    enum VerificationStatus { Unverified, Verified }

    // Struct to store user details
    struct User {
        bytes32 hash; // Hash of the user's identity
        VerificationStatus status; // Verification status
    }

    // Mapping from user's unique identifier to User struct
    mapping(uint256 => User) public users;

    // Event emitted when a user is verified
    event UserVerified(uint256 indexed userId, bytes32 hash);

    // Function to verify a proof and store the hash
    function verifyProof(uint256 userId, bytes32 hash, bytes memory proof) public {
        // Placeholder for actual World ID verification logic
        // This should be replaced with actual verification code from World ID
        bool isValid = _verifyWorldIDProof(proof);

        require(isValid, "Proof verification failed");

        // Store the hash and mark the user as verified
        users[userId] = User({
            hash: hash,
            status: VerificationStatus.Verified
        });

        emit UserVerified(userId, hash);
    }

    // Function to check if a user is verified
    function isVerified(uint256 userId) public view returns (bool) {
        return users[userId].status == VerificationStatus.Verified;
    }

    // Placeholder function for World ID proof verification
    function _verifyWorldIDProof(bytes memory proof) internal pure returns (bool) {
        // Replace this with actual World ID verification logic
        // This is a placeholder and should be implemented according to World ID's specifications
        return true;
    }
}
```

This contract provides a basic framework for verifying identities using World ID and storing a unique identifier for each user. The `verifyProof` function is intended to verify a proof provided by World ID and store the hash of the user's identity. The `isVerified` function checks if a user is verified. The `_verifyWorldIDProof` function is a placeholder for the actual World ID verification logic, which should be implemented according to World ID's specifications.