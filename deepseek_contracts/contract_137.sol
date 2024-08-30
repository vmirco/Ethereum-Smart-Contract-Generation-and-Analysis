// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC721Vault {
    address public owner;
    mapping(address => mapping(uint256 => bool)) public depositedTokens;
    mapping(address => bool) public admins;

    event TokenDeposited(address indexed user, uint256 tokenId);
    event TokenWithdrawn(address indexed user, uint256 tokenId);
    event BatchWithdrawn(address indexed user, uint256[] tokenIds);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyAdmin() {
        require(admins[msg.sender] || msg.sender == owner, "Not an admin");
        _;
    }

    constructor() {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    function addAdmin(address admin) external onlyOwner {
        admins[admin] = true;
    }

    function removeAdmin(address admin) external onlyOwner {
        admins[admin] = false;
    }

    function deposit(uint256 tokenId) external {
        require(!depositedTokens[msg.sender][tokenId], "Token already deposited");
        depositedTokens[msg.sender][tokenId] = true;
        emit TokenDeposited(msg.sender, tokenId);
    }

    function depositBatch(uint256[] calldata tokenIds) external {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(!depositedTokens[msg.sender][tokenIds[i]], "Token already deposited");
            depositedTokens[msg.sender][tokenIds[i]] = true;
            emit TokenDeposited(msg.sender, tokenIds[i]);
        }
    }

    function withdraw(uint256 tokenId) external {
        require(depositedTokens[msg.sender][tokenId], "Token not deposited");
        depositedTokens[msg.sender][tokenId] = false;
        emit TokenWithdrawn(msg.sender, tokenId);
    }

    function withdrawBatch(uint256[] calldata tokenIds) external {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(depositedTokens[msg.sender][tokenIds[i]], "Token not deposited");
            depositedTokens[msg.sender][tokenIds[i]] = false;
        }
        emit BatchWithdrawn(msg.sender, tokenIds);
    }
}