// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ItemSetManager {
    struct Item {
        uint256 id;
        string name;
        string rarity;
    }

    struct ItemSet {
        uint256 id;
        Item[] items;
    }

    uint256 private nextSetId = 1;
    mapping(uint256 => ItemSet) private itemSets;
    mapping(string => ItemSet[]) private raritySets;

    event ItemSetRegistered(uint256 setId);
    event ItemDeregistered(uint256 setId, uint256 itemId);

    function registerItemSet(Item[] memory items) external returns (uint256) {
        uint256 setId = nextSetId++;
        ItemSet storage newSet = itemSets[setId];
        newSet.id = setId;

        for (uint256 i = 0; i < items.length; i++) {
            items[i].id = i + 1;
            newSet.items.push(items[i]);
            raritySets[items[i].rarity].push(newSet);
        }

        emit ItemSetRegistered(setId);
        return setId;
    }

    function deregisterItem(uint256 setId, uint256 itemId) external {
        ItemSet storage set = itemSets[setId];
        require(set.id != 0, "Set does not exist");

        for (uint256 i = 0; i < set.items.length; i++) {
            if (set.items[i].id == itemId) {
                string memory rarity = set.items[i].rarity;
                for (uint256 j = 0; j < raritySets[rarity].length; j++) {
                    if (raritySets[rarity][j].id == setId) {
                        raritySets[rarity][j] = raritySets[rarity][raritySets[rarity].length - 1];
                        raritySets[rarity].pop();
                        break;
                    }
                }
                set.items[i] = set.items[set.items.length - 1];
                set.items.pop();
                emit ItemDeregistered(setId, itemId);
                return;
            }
        }

        revert("Item not found in the set");
    }

    function getItemSet(uint256 setId) external view returns (Item[] memory) {
        return itemSets[setId].items;
    }

    function getItemSetsByRarity(string memory rarity) external view returns (ItemSet[] memory) {
        return raritySets[rarity];
    }

    function getAllItemSets() external view returns (ItemSet[] memory) {
        ItemSet[] memory sets = new ItemSet[](nextSetId - 1);
        for (uint256 i = 1; i < nextSetId; i++) {
            sets[i - 1] = itemSets[i];
        }
        return sets;
    }
}