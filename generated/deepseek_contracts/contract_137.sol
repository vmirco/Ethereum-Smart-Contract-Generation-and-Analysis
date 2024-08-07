// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract ERC721DepositWithdraw {
    address public owner;
    mapping(address => bool) public admins;
    mapping(address => mapping(uint256 => bool)) public depositedTokens;

    event TokenDeposited(address indexed user, uint256 tokenId);
    event TokenWithdrawn(address indexed user, uint256 tokenId);
    event BatchWithdrawn(address indexed user, uint256[] tokenIds);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
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
        IERC721 tokenContract = IERC721(msg.sender);
        require(tokenContract.ownerOf(tokenId) == msg.sender, "Not the owner of the token");
        tokenContract.transferFrom(msg.sender, address(this), tokenId);
        depositedTokens[msg.sender][tokenId] = true;
        emit TokenDeposited(msg.sender, tokenId);
    }

    function depositBatch(uint256[] calldata tokenIds) external {
        IERC721 tokenContract = IERC721(msg.sender);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(tokenContract.ownerOf(tokenId) == msg.sender, "Not the owner of the token");
            tokenContract.transferFrom(msg.sender, address(this), tokenId);
            depositedTokens[msg.sender][tokenId] = true;
            emit TokenDeposited(msg.sender, tokenId);
        }
    }

    function withdraw(uint256 tokenId) external {
        require(depositedTokens[msg.sender][tokenId], "Token not deposited or not owned by sender");
        IERC721 tokenContract = IERC721(msg.sender);
        tokenContract.safeTransferFrom(address(this), msg.sender, tokenId);
        depositedTokens[msg.sender][tokenId] = false;
        emit TokenWithdrawn(msg.sender, tokenId);
    }

    function withdrawBatch(uint256[] calldata tokenIds) external {
        IERC721 tokenContract = IERC721(msg.sender);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(depositedTokens[msg.sender][tokenId], "Token not deposited or not owned by sender");
            tokenContract.safeTransferFrom(address(this), msg.sender, tokenId);
            depositedTokens[msg.sender][tokenId] = false;
        }
        emit BatchWithdrawn(msg.sender, tokenIds);
    }
}