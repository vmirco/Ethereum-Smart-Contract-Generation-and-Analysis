// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract ERC165 {
    function supportsInterface(bytes4 interfaceId) virtual public view returns (bool);
}

abstract contract ERC721 is ERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) virtual public view returns (uint256 balance);
    function ownerOf(uint256 tokenId) virtual public view returns (address owner);

    function approve(address to, uint256 tokenId) virtual public;
    function getApproved(uint256 tokenId) virtual public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) virtual public;
    function isApprovedForAll(address owner, address operator) virtual public view returns (bool);

    function transferFrom(address from, address to, uint256 tokenId) virtual public;
    function safeTransferFrom(address from, address to, uint256 tokenId) virtual public;
}

abstract contract ERC721Metadata is ERC721 {
    function name() virtual public view returns (string memory _name);
    function symbol() virtual public view returns (string memory _symbol);
    function tokenURI(uint256 tokenId) virtual public view returns (string memory);
}

contract MyNFT is ERC721, ERC721Metadata {

    string private _name = "My NFT";
    string private _symbol = "MNFT";
    address private _owner;
    mapping (uint256 => address) private _tokenOwners;
    mapping (address => uint256) private _balances;
    mapping (uint256 => address) private _tokenApprovals;
    mapping (address => mapping (address => bool)) private _operatorApprovals;
    mapping (uint256 => string) private _tokenURIs;

    constructor() {
        _owner = msg.sender;
    }

    function supportsInterface(bytes4 interfaceId) override public view returns (bool) {
        return interfaceId == type(ERC721).interfaceId || interfaceId == type(ERC721Metadata).interfaceId;
    }

    function name() override public view returns (string memory) {
        return _name;
    }

    function symbol() override public view returns (string memory) {
        return _symbol;
    }

    function balanceOf(address owner) override public view returns (uint256) {
        require(owner != address(0));
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) override public view returns (address) {
        address owner = _tokenOwners[tokenId];
        require(owner != address(0));
        return owner;
    }

    function approve(address to, uint256 tokenId) override public {
        address owner = ownerOf(tokenId);
        require(to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) override public view returns (address) {
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) override public {
        require(operator != msg.sender);

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) override public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) override public {
        require(ownerOf(tokenId) == from);
        require(_isApprovedOrOwner(msg.sender, tokenId));
        require(to != address(0));
        
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) override public {
        transferFrom(from, to, tokenId);
    }

    function mint(address to, uint256 tokenId) public {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _balances[to] += 1;
        _tokenOwners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        require(_exists(tokenId), "URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenOwners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address submitter, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (submitter == owner || getApproved(tokenId) == submitter || isApprovedForAll(owner, submitter));
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        _balances[from] -= 1;
        _balances[to] += 1;

        delete _tokenApprovals[tokenId];

        _tokenOwners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
}