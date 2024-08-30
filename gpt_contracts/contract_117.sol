// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract AccessControl {
    mapping (address => bool) private _admins;

    event AdminRoleAssigned(address indexed admin);
    event AdminRoleRevoked(address indexed admin);

    modifier onlyAdmin() {
        require(_admins[msg.sender], "AccessControl: caller is not an admin");
        _;
    }

    constructor () {
        _assignAdmin(msg.sender);
    }

    function isAdmin(address account) public view returns (bool) {
        return _admins[account];
    }

    function assignAdmin(address account) public onlyAdmin {
        _assignAdmin(account);
    }

    function revokeAdmin(address account) public onlyAdmin {
        _revokeAdmin(account);
    }

    function _assignAdmin(address account) private {
        _admins[account] = true;
        emit AdminRoleAssigned(account);
    }

    function _revokeAdmin(address account) private {
        _admins[account] = false;
        emit AdminRoleRevoked(account);
    }
}

contract ERC721 is AccessControl {

    uint256 private _tokenCounter;
    mapping(uint256 => address) private _tokenOwners;
    mapping(address => uint256) private _ownedTokensCount;
    mapping (uint256 => string) private _tokenURIs;

    event Transfer(address from, address to, uint256 tokenId);
    event TokenURIUpdated(uint256 tokenId, string uri);

    function balanceOf(address owner) public view returns (uint256) {
        return _ownedTokensCount[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        return _tokenOwners[tokenId];
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        return _tokenURIs[tokenId];
    }

    function mint(address to) public onlyAdmin {
        _tokenCounter++;
        uint256 newTokenId = _tokenCounter;
        _tokenOwners[newTokenId] = to;
        _ownedTokensCount[to]++;
        emit Transfer(address(0), to, newTokenId);
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) public onlyAdmin {
        _tokenURIs[tokenId] = _tokenURI;
        emit TokenURIUpdated(tokenId, _tokenURI);
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        _transfer(from, to, tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        _tokenOwners[tokenId] = to;
        _ownedTokensCount[from]--;
        _ownedTokensCount[to]++;
        emit Transfer(from, to, tokenId);
    }
}