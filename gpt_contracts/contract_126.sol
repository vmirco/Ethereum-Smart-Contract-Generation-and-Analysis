pragma solidity ^0.8.0;

contract WorldID {

    struct User {
        string worldID;
        string uniqueID;
    }

    mapping(string => string) internal proofs;
    mapping(string => User) internal users;

    // Emitted when a user is registered
    event UserRegistered(string worldID, string uniqueID);
    // Emitted when a proof is validated
    event ProofValidated(string worldID, string uniqueID, string hash);

    function registerUser(string memory worldID, string memory uniqueID) public {
        require(bytes(users[worldID].worldID).length == 0, "World ID is already in use");
        require(bytes(users[uniqueID].uniqueID).length == 0, "Unique ID is already in use");

        users[worldID] = User(worldID, uniqueID);

        emit UserRegistered(worldID, uniqueID);
    }

    function storeHash(string memory worldID, string memory hash) public {
        require(bytes(users[worldID].worldID).length != 0, "User is not registered");

        proofs[worldID] = hash;
    }

    function verifyProof(string memory worldID, string memory hash) public {
        require(bytes(users[worldID].worldID).length != 0, "User is not registered");
        require(keccak256(abi.encodePacked(proofs[worldID])) == keccak256(abi.encodePacked(hash)), "Hash doesn't match");

        // Implement specific logic here when a proof is verified

        emit ProofValidated(worldID, users[worldID].uniqueID, hash);
    }

}