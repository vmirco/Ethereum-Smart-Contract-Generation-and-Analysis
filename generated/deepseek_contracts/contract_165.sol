// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IncrementalMerkleTree {
    struct Tree {
        uint256 depth;
        uint256[] layers;
        uint256 zeroValue;
    }

    Tree public tree;

    constructor(uint256 _depth, uint256 _zeroValue) {
        tree.depth = _depth;
        tree.zeroValue = _zeroValue;
        tree.layers = new uint256[](1 << _depth);
        for (uint256 i = 0; i < tree.layers.length; i++) {
            tree.layers[i] = _zeroValue;
        }
    }

    function insertLeaf(uint256 _leaf) public {
        require(tree.layers.length > 0, "Tree not initialized");
        require(tree.layers[0] == tree.zeroValue, "Tree is full");

        uint256 index = 0;
        for (uint256 i = 0; i < tree.depth; i++) {
            if (index * 2 + 1 < tree.layers.length && tree.layers[index * 2 + 1] == tree.zeroValue) {
                tree.layers[index * 2 + 1] = _leaf;
                index = index * 2 + 1;
            } else {
                tree.layers[index * 2 + 2] = _leaf;
                index = index * 2 + 2;
            }
        }
    }
}