pragma solidity ^0.8.0;

library IncrementalMerkleTree {
    struct Data {
        uint256 depth;
        uint256[] leaves;
        uint256[] tree;
    }

    function insert(Data storage self, uint256 item) internal {
        self.leaves.push(item);
        if(self.leaves.length > (2 ** self.depth)){
            revert("Merkle Tree is full");
        }
        self.tree[0] = item;
        for(uint256 i = 0; i < self.depth; i++) {
            self.tree[i + 1] = uint256(keccak256(abi.encodePacked(self.tree[i], self.tree[i])));
        }
    }
}

contract MerkleManager {
    using IncrementalMerkleTree for IncrementalMerkleTree.Data;
    IncrementalMerkleTree.Data private merkleTree;

    constructor(uint256 depth) {
        merkleTree.depth = depth;
        merkleTree.leaves = new uint256[](0);
        merkleTree.tree = new uint256[](depth);
    }

    function insert(uint256 item) public {
        merkleTree.insert(item);
    }
}