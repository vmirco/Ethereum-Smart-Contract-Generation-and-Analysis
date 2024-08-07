// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ItemSetManager {
    struct ItemSet {
        uint256 setId;
        string name;
        string rarity;
        bool registered;
    }

    mapping(uint256 => ItemSet) private itemSets;
    uint256 private nextSetId;

    event ItemSetRegistered(uint256 indexed setId, string name, string rarity);
    event ItemSetDeregistered(uint256 indexed setId);

    function registerItemSet(string memory name, string memory rarity) public {
        uint256 setId = nextSetId++;
        itemSets[setId] = ItemSet(setId, name, rarity, true);
        emit ItemSetRegistered(setId, name, rarity);
    }

    function deregisterItemSet(uint256 setId) public {
        require(itemSets[setId].registered, "Item set not found");
        itemSets[setId].registered = false;
        emit ItemSetDeregistered(setId);
    }

    function getItemSetById(uint256 setId) public view returns (ItemSet memory) {
        require(itemSets[setId].registered, "Item set not found");
        return itemSets[setId];
    }

    function getItemSetsByRarity(string memory rarity) public view returns (ItemSet[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < nextSetId; i++) {
            if (itemSets[i].registered && keccak256(abi.encodePacked(itemSets[i].rarity)) == keccak256(abi.encodePacked(rarity))) {
                count++;
            }
        }

        ItemSet[] memory sets = new ItemSet[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < nextSetId; i++) {
            if (itemSets[i].registered && keccak256(abi.encodePacked(itemSets[i].rarity)) == keccak256(abi.encodePacked(rarity))) {
                sets[index] = itemSets[i];
                index++;
            }
        }
        return sets;
    }

    function getAllItemSets() public view returns (ItemSet[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < nextSetId; i++) {
            if (itemSets[i].registered) {
                count++;
            }
        }

        ItemSet[] memory sets = new ItemSet[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < nextSetId; i++) {
            if (itemSets[i].registered) {
                sets[index] = itemSets[i];
                index++;
            }
        }
        return sets;
    }
}