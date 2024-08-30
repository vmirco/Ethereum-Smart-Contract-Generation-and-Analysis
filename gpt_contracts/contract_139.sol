pragma solidity ^0.8.0;

contract DisputeManager {

    struct Item {
        string name;
        address owner;
        bool isBlacklisted;
        bool isWhiteListed;
        uint disputeCount;
    }

    mapping (bytes32 => Item) public items;
    mapping (bytes32 => bool) blacklist;
    mapping (bytes32 => bool) public whitelist;

    event ItemSubmitted(bytes32 indexed itemId, string name, address indexed owner);
    event ItemCleared(bytes32 indexed itemId, string name, address indexed owner);
    event ItemChallenged(bytes32 indexed itemId, string name, address indexed owner);
    event DisputeResolved(bytes32 indexed itemId, string name, address indexed owner, bool isBlacklisted, bool isWhiteListed);

    function submitItem(string memory _name) public {
        bytes32 itemId = keccak256(abi.encodePacked(_name, msg.sender));
        require(items[itemId].owner == address(0), "Item already exists");
        
        items[itemId].name = _name;
        items[itemId].owner = msg.sender;

        emit ItemSubmitted(itemId, _name, msg.sender);
    }

    function clearItem(string memory _name) public {
        bytes32 itemId = keccak256(abi.encodePacked(_name, msg.sender));
        require(items[itemId].owner == msg.sender, "Only the owner can clear this item");

        items[itemId].isBlacklisted = false;
        items[itemId].isWhiteListed = false;
        items[itemId].disputeCount = 0;

        emit ItemCleared(itemId, _name, msg.sender);
    }

    function challengeItem(string memory _name, address _owner) public {
        bytes32 itemId = keccak256(abi.encodePacked(_name, _owner));
        require(items[itemId].owner == _owner, "This item does not exist");

        items[itemId].disputeCount += 1;

        emit ItemChallenged(itemId, _name, _owner);
    }

    function resolveDispute(string memory _name, address _owner, bool _blacklistFlag) public {
        bytes32 itemId = keccak256(abi.encodePacked(_name, _owner));
        require(items[itemId].owner == _owner, "This item does not exist");

        items[itemId].isBlacklisted = _blacklistFlag;
        items[itemId].isWhiteListed = !_blacklistFlag;

        emit DisputeResolved(itemId, _name, _owner, _blacklistFlag, !_blacklistFlag);
    }
}