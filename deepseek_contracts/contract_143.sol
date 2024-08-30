// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC721 {
    string public name;
    string public symbol;
    uint256 public totalSupply;

    mapping(uint256 => address) private _tokenOwner;
    mapping(address => uint256) private _ownedTokensCount;
    mapping(uint256 => address) private _tokenApprovals;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
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

    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(msg.sender == owner, "ERC721: approve caller is not owner");

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }

    function transfer(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner, "ERC721: transfer caller is not owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _transfer(owner, to, tokenId);
    }

    function takeOwnership(uint256 tokenId) public {
        require(_exists(tokenId), "ERC721: token does not exist");
        address newOwner = msg.sender;
        address owner = ownerOf(tokenId);
        require(newOwner != owner, "ERC721: new owner is the current owner");
        require(_tokenApprovals[tokenId] == newOwner, "ERC721: caller is not approved for token");

        _transfer(owner, newOwner, tokenId);
    }

    function mint(address to, uint256 tokenId) public {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to] += 1;
        totalSupply += 1;

        emit Transfer(address(0), to, tokenId);
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenOwner[tokenId] != address(0);
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        _ownedTokensCount[from] -= 1;
        _ownedTokensCount[to] += 1;
        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
}