// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NFTCollection {
    struct NFT {
        address owner;
        uint256 tokenId;
        uint256 timestamp;
    }

    NFT[] public nfts;
    mapping(uint256 => address) public tokenOwner;
    mapping(address => uint256) public ownerTokenCount;
    mapping(uint256 => uint256) public tokenTimestamps;

    uint256 public tokenCounter;
    uint256 public rerollCost = 100; // Example cost for re-rolling
    uint256 public depositCost = 50; // Example cost for depositing tokens

    event Minted(address indexed owner, uint256 tokenId);
    event Rerolled(address indexed owner, uint256 tokenId);
    event Deposited(address indexed owner, uint256 amount);

    modifier onlyOwnerOf(uint256 _tokenId) {
        require(tokenOwner[_tokenId] == msg.sender, "Not the owner of this NFT");
        _;
    }

    function mintNFT() public payable {
        require(msg.value >= depositCost, "Insufficient payment for minting");
        uint256 newTokenId = tokenCounter++;
        nfts.push(NFT({owner: msg.sender, tokenId: newTokenId, timestamp: block.timestamp}));
        tokenOwner[newTokenId] = msg.sender;
        ownerTokenCount[msg.sender]++;
        tokenTimestamps[newTokenId] = block.timestamp;
        emit Minted(msg.sender, newTokenId);
    }

    function rerollNFT(uint256 _tokenId) public payable onlyOwnerOf(_tokenId) {
        require(msg.value >= rerollCost, "Insufficient payment for re-rolling");
        nfts[_tokenId].timestamp = block.timestamp;
        emit Rerolled(msg.sender, _tokenId);
    }

    function depositTokens() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        emit Deposited(msg.sender, msg.value);
    }

    function checkTokenAccessibility(uint256 _tokenId, uint256 _timeLimit) public view returns (bool) {
        require(_tokenId < tokenCounter, "Token ID does not exist");
        return (block.timestamp - tokenTimestamps[_tokenId]) <= _timeLimit;
    }
}