// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract ERC721 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory tokenIds
    ) public virtual;

    function balanceOf(address owner) public view virtual returns (uint256 balance);
}

contract DepositWithdraw {
    mapping(address => mapping(uint256 => bool)) public deposits;

    event Deposited(address indexed user, uint256 indexed tokenId, address indexed contractAddress);
    event BatchDeposited(address indexed user, uint256[] indexed tokens, address indexed contractAddress);
    event Withdrawn(address indexed user, uint256 indexed tokenId, address indexed contractAddress);
    event BatchWithdrawn(address indexed user, uint256[] indexed tokens, address indexed contractAddress);

    function depositSingle(address tokenAddress, uint256 tokenId) public {
        ERC721(tokenAddress).safeTransferFrom(msg.sender, address(this), tokenId);
        deposits[tokenAddress][tokenId] = true;
        emit Deposited(msg.sender, tokenId, tokenAddress);
    }

    function depositBatch(address tokenAddress, uint256[] calldata tokenIds) public {
        for(uint i=0; i<tokenIds.length; i++){
            this.depositSingle(tokenAddress, tokenIds[i]);
        }
        emit BatchDeposited(msg.sender, tokenIds, tokenAddress);
    }

    function withdrawSingle(address tokenAddress, uint256 tokenId) public {
        require(deposits[tokenAddress][tokenId] == true, "Token not deposited in contract");
        deposits[tokenAddress][tokenId] = false;
        ERC721(tokenAddress).safeTransferFrom(address(this), msg.sender, tokenId);
        emit Withdrawn(msg.sender, tokenId, tokenAddress);
    }

    function withdrawBatch(address tokenAddress, uint256[] calldata tokenIds) public {
        for(uint i=0; i<tokenIds.length; i++){
            this.withdrawSingle(tokenAddress, tokenIds[i]);
        }
        emit BatchWithdrawn(msg.sender, tokenIds, tokenAddress);
    }
}