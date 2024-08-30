pragma solidity ^0.8.0;

contract ItemSetManagement {

    enum Rarity {
        Common, 
        Uncommon,
        Rare, 
        Epic,
        Legendary
    }

    struct ItemSet {
        uint256 setId;
        Rarity rarity;
        string[] items;
    }
    
    mapping(uint256 => ItemSet) private itemSets;
    uint256 private nextItemId = 1;

    event ItemSetCreated(uint256 setId, Rarity rarity);
    event ItemSetUpdated(uint256 setId, Rarity rarity);
    event ItemSetRemoved(uint256 setId);
    
    function createItemSet(Rarity rarity, string[] memory items) public {
        ItemSet storage set = itemSets[nextItemId];
        set.setId = nextItemId;
        set.rarity = rarity;
        set.items = items;

        emit ItemSetCreated(nextItemId, rarity);

        nextItemId++;
    }

    function updateItemSet(uint256 setId, Rarity rarity, string[] memory items) public {
        require(setId < nextItemId, "Set does not exist");

        ItemSet storage set = itemSets[setId];
        set.rarity = rarity;
        set.items = items;

        emit ItemSetUpdated(setId, rarity);
    }
    
    function removeItemSet(uint256 setId) public {
        require(setId < nextItemId, "Set does not exist");

        delete itemSets[setId];

        emit ItemSetRemoved(setId);
    }

    function getItemSet(uint256 setId) public view returns (Rarity, string[] memory){
        require(setId < nextItemId, "Set does not exist");

        ItemSet storage set = itemSets[setId];

        return (set.rarity, set.items);
    }

    function getItemSetsByRarity(Rarity rarity) public view returns (uint256[] memory) {
        uint256 count = 0;

        for (uint256 i = 1; i < nextItemId; i++) {
            if (itemSets[i].rarity == rarity) {
                count++;
            }
        }

        uint256[] memory ids = new uint256[](count);

        count = 0;

        for (uint256 i = 1; i < nextItemId; i++) {
            if (itemSets[i].rarity == rarity) {
                ids[count] = i;
                count++;
            }
        }

        return ids;
    }

    function getAllItemSets() public view returns (uint256[] memory) {
        uint256[] memory ids = new uint256[](nextItemId - 1);

        for (uint256 i = 1; i < nextItemId; i++) {
            ids[i - 1] = i;
        }

        return ids;
    }
    
}