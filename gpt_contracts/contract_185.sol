// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IERC721Full {

    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _owners;
    mapping(uint256 => string) private _tokenURIs;
    uint256[] private _allTokens;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    function balanceOf(address owner) public view returns (uint256 balance) {
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address owner) {
        return _owners[tokenId];
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        return _tokenURIs[tokenId];
    }

    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {
        require(index < totalSupply());
        return _allTokens[index];
    }
 
    function mint(address to, uint256 tokenId, string memory uri) public {
        require(to != address(0), "ERC721: mint to the zero address");
        require(_owners[tokenId] == address(0), "ERC721: token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;
        _tokenURIs[tokenId] = uri;
        _allTokens.push(tokenId);

        emit Transfer(address(0), to, tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not owned");

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        _transfer(from, to, tokenId);
    }
    
    function updateTokenURI(uint256 tokenId, string memory newUri) public {
        require(_owners[tokenId] != address(0), "ERC721: nonexistent token");
        _tokenURIs[tokenId] = newUri;
    }
}