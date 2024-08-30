// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IncrementalMerkleTree {
    struct Tree {
        uint256 depth;
        uint256[] leaves;
        uint256[] nodes;
        uint256 root;
    }

    Tree public tree;

    constructor(uint256 _depth) {
        require(_depth > 0, "Depth must be greater than 0");
        tree.depth = _depth;
        tree.nodes = new uint256[](2 ** (_depth + 1) - 1);
        initializeTree(0, 0, _depth);
    }

    function initializeTree(uint256 nodeIndex, uint256 level, uint256 depth) internal {
        if (level == depth) {
            tree.nodes[nodeIndex] = 0;
        } else {
            tree.nodes[nodeIndex] = 0;
            initializeTree(2 * nodeIndex + 1, level + 1, depth);
            initializeTree(2 * nodeIndex + 2, level + 1, depth);
        }
    }

    function insertLeaf(uint256 _leaf) public {
        require(tree.leaves.length < 2 ** tree.depth, "Tree is full");
        tree.leaves.push(_leaf);
        updateTree(tree.leaves.length - 1, _leaf);
    }

    function updateTree(uint256 leafIndex, uint256 leafValue) internal {
        uint256 nodeIndex = 2 ** tree.depth - 1 + leafIndex;
        tree.nodes[nodeIndex] = leafValue;
        while (nodeIndex != 0) {
            nodeIndex = (nodeIndex - 1) / 2;
            uint256 leftChild = tree.nodes[2 * nodeIndex + 1];
            uint256 rightChild = tree.nodes[2 * nodeIndex + 2];
            tree.nodes[nodeIndex] = hash(leftChild, rightChild);
        }
        tree.root = tree.nodes[0];
    }

    function hash(uint256 a, uint256 b) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(a, b)));
    }
}