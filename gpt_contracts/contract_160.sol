// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Token {
    struct TokenData {
        uint256 tokenId;
        address owner;
        string metadata;
    }

    uint256 private _tokenIdTracker = 0;

    mapping (uint256 => TokenData) private _tokens;
    mapping (uint256 => address) private _tokenApprovals;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    function mintToken(string memory metadata) external returns (uint256) {
        _tokenIdTracker++;
        _tokens[_tokenIdTracker] = TokenData(_tokenIdTracker, msg.sender, metadata);

        emit Transfer(address(0), msg.sender, _tokenIdTracker);

        return _tokenIdTracker;
    }

    function updateMetadata(uint256 tokenId, string memory newMetadata) external {
        require(msg.sender == _tokens[tokenId].owner, "Only token owner can update metadata");

        _tokens[tokenId].metadata = newMetadata;
    }

    function approve(address to, uint256 tokenId) external {
        require(msg.sender == _tokens[tokenId].owner, "Only token owner can approve");

        _tokenApprovals[tokenId] = to;

        emit Approval(msg.sender, to, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) external {
        require(_tokenApprovals[tokenId] == msg.sender, "Transfer not approved for this address");

        _tokens[tokenId].owner = to;
        _tokenApprovals[tokenId] = address(0);

        emit Transfer(from, to, tokenId);
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        return _tokens[tokenId].owner;
    }

    function getTokenData(uint256 tokenId) external view returns (TokenData memory) {
        return _tokens[tokenId];
    }
}