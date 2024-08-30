// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC721 {

    string public name;
    string public symbol;

    mapping(address => uint) private _balances;
    mapping(uint => address) private _owners;
    mapping(uint => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    event Transfer(address indexed from, address indexed to, uint indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function balanceOf(address owner) public view returns (uint balance) {
        require(owner != address(0));
        return _balances[owner];
    }

    function ownerOf(uint tokenId) public view returns (address owner) {
        owner = _owners[tokenId];
        require(owner != address(0));
        return owner;
    }

    function safeTransferFrom(address from, address to, uint tokenId, bytes memory data) public {
        transferFrom(from, to, tokenId);
        if(to.isContract()) {
            bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data);
            require(retval == ERC721_RECEIVED);
        }
    }

    function safeTransferFrom(address from, address to, uint tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    function transferFrom(address from, address to, uint tokenId) public {
        require(ownerOf(tokenId) == msg.sender || getApproved(tokenId) == msg.sender || isApprovedForAll(ownerOf(tokenId), msg.sender));
        _transfer(from, to, tokenId);
    }

    function approve(address approved, uint tokenId) public {
        require(ownerOf(tokenId) == msg.sender || isApprovedForAll(ownerOf(tokenId), msg.sender));
        _approve(approved, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function getApproved(uint tokenId) public view returns (address operator) {
        require(_exists(tokenId));
        return _tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function _mint(address to, uint tokenId) internal {
        require(to != address(0));
        _balances[to]++;
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint tokenId) internal {
        address owner = ownerOf(tokenId);
        _balances[owner]--;
        delete _owners[tokenId];
        emit Transfer(owner, address(0), tokenId);
    }

    function _exists(uint tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _transfer(address from, address to, uint tokenId) internal {
        require(from != address(0));
        require(to != address(0));
        _balances[from]--;
        _balances[to]++;
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }
}

interface IERC721Receiver {

    bytes4 constant ERC721_RECEIVED = 0x150b7a02;

    function onERC721Received(address operator, address from, uint tokenId, bytes calldata data) external returns (bytes4);
}