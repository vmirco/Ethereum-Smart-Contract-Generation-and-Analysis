// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DisputableItems {
    struct Item {
        address submitter;
        bool isBlacklisted;
        bool isWhitelisted;
        bool isChallenged;
        uint256 challengeTimestamp;
    }

    mapping(uint256 => Item) public items;
    uint256 public itemCount;
    uint256 public challengePeriod = 3 days;

    event ItemSubmitted(uint256 indexed itemId, address indexed submitter);
    event ItemCleared(uint256 indexed itemId);
    event ItemChallenged(uint256 indexed itemId, address indexed challenger);
    event DisputeResolved(uint256 indexed itemId, bool isBlacklisted);

    function submitItem() external returns (uint256) {
        uint256 itemId = itemCount++;
        items[itemId] = Item({
            submitter: msg.sender,
            isBlacklisted: false,
            isWhitelisted: false,
            isChallenged: false,
            challengeTimestamp: 0
        });
        emit ItemSubmitted(itemId, msg.sender);
        return itemId;
    }

    function clearItem(uint256 itemId) external {
        require(items[itemId].submitter == msg.sender, "Not the submitter");
        items[itemId].isWhitelisted = true;
        emit ItemCleared(itemId);
    }

    function challengeItem(uint256 itemId) external {
        require(!items[itemId].isChallenged, "Item already challenged");
        items[itemId].isChallenged = true;
        items[itemId].challengeTimestamp = block.timestamp;
        emit ItemChallenged(itemId, msg.sender);
    }

    function resolveDispute(uint256 itemId, bool blacklist) external {
        require(items[itemId].isChallenged, "Item not challenged");
        require(block.timestamp >= items[itemId].challengeTimestamp + challengePeriod, "Challenge period not over");
        items[itemId].isChallenged = false;
        items[itemId].isBlacklisted = blacklist;
        items[itemId].isWhitelisted = !blacklist;
        emit DisputeResolved(itemId, blacklist);
    }
}