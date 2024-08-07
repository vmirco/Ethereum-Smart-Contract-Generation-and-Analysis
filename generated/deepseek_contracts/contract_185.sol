// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC721Full {
    string private _name;
    string private _symbol;
    uint256 private _tokenIdCounter;

    mapping(uint256 => address) private _tokenOwner;
    mapping(uint256 => string) private _tokenURIs;
    mapping(address => uint256) private _ownedTokensCount;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event TokenURIUpdated(uint256 indexed tokenId, string uri);

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _ownedTokensCount[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _tokenOwner[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    function mint(address to, string memory uri) public returns (uint256) {
        require(to != address(0), "ERC721: mint to the zero address");

        _tokenIdCounter++;
        uint256 newTokenId = _tokenIdCounter;
        _mint(to, newTokenId);
        _setTokenURI(newTokenId, uri);

        return newTokenId;
    }

    function updateTokenURI(uint256 tokenId, string memory uri) public {
        require(_exists(tokenId), "ERC721: token does not exist");
        require(msg.sender == ownerOf(tokenId), "ERC721: only owner can update token URI");
        _setTokenURI(tokenId, uri);
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenOwner[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner);
    }

    function _mint(address to, uint256 tokenId) internal {
        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to] += 1;
        emit Transfer(address(0), to, tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _ownedTokensCount[from] -= 1;
        _ownedTokensCount[to] += 1;
        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        _tokenURIs[tokenId] = uri;
        emit TokenURIUpdated(tokenId, uri);
    }
}