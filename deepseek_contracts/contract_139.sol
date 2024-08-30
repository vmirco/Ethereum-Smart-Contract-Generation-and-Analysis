// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DisputableItems {
    struct Item {
        address submitter;
        bool isBlacklisted;
        bool isDisputed;
        address challenger;
    }

    mapping(uint256 => Item) public items;
    uint256 public itemCount;

    event ItemSubmitted(uint256 indexed itemId, address indexed submitter);
    event ItemCleared(uint256 indexed itemId);
    event ItemChallenged(uint256 indexed itemId, address indexed challenger);
    event DisputeResolved(uint256 indexed itemId, bool isBlacklisted);

    function submitItem() external returns (uint256) {
        itemCount++;
        items[itemCount] = Item({
            submitter: msg.sender,
            isBlacklisted: false,
            isDisputed: false,
            challenger: address(0)
        });
        emit ItemSubmitted(itemCount, msg.sender);
        return itemCount;
    }

    function clearItem(uint256 itemId) external {
        require(itemId <= itemCount && itemId > 0, "Invalid item ID");
        Item storage item = items[itemId];
        require(item.submitter == msg.sender, "Not the submitter");
        item.isBlacklisted = false;
        emit ItemCleared(itemId);
    }

    function challengeItem(uint256 itemId) external {
        require(itemId <= itemCount && itemId > 0, "Invalid item ID");
        Item storage item = items[itemId];
        require(!item.isDisputed, "Item already disputed");
        item.isDisputed = true;
        item.challenger = msg.sender;
        emit ItemChallenged(itemId, msg.sender);
    }

    function resolveDispute(uint256 itemId, bool blacklist) external {
        require(itemId <= itemCount && itemId > 0, "Invalid item ID");
        Item storage item = items[itemId];
        require(item.isDisputed, "Item not disputed");
        item.isDisputed = false;
        item.isBlacklisted = blacklist;
        emit DisputeResolved(itemId, blacklist);
    }
}