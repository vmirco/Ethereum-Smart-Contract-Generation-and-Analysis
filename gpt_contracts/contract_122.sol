// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract ERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool);
}

abstract contract ERC721 is ERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    function balanceOf(address owner) public view virtual returns (uint256);
    function ownerOf(uint256 tokenId) public view virtual returns (address);
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual;
    function transferFrom(address from, address to, uint256 tokenId) public virtual;
    function approve(address to, uint256 tokenId) public virtual;
    function getApproved(uint256 tokenId) public view virtual returns (address);
    function setApprovalForAll(address operator, bool _approved) public virtual;
    function isApprovedForAll(address owner, address operator) public view virtual returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual;
}

abstract contract ERC721TokenReceiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public virtual returns (bytes4);
}

contract ERC721Mintable is ERC721 {
  
    uint256 public tokenCount = 0;
    mapping(uint256 => address) private _tokenOwners;
    mapping(address => mapping (address => bool)) private _operatorApprovals;
    mapping(uint256 => string) private _tokenURIs;
    event Minted(address indexed owner, uint256 indexed amount, address indexed delegate);

    function mint(address to, uint256 amount, address delegate) public {
        for(uint i=0; i<amount; i++){
            _mint(to, tokenCount);
            emit Minted(to, amount, delegate);
            tokenCount += 1;
        }
    }

    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        _tokenOwners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }
    
    function balanceOf(address owner) public view override returns (uint256){
        uint256 tokenCount = 0;
        for (uint i=0; i<tokenCount; i++){
            if (_tokenOwners[i] == owner){
                tokenCount += 1;
            }
        }
        return tokenCount;
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _tokenOwners[tokenId];
    }
    
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        _tokenURIs[tokenId] = _tokenURI;
    }
    
    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        return _tokenURIs[tokenId];
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool){
        return interfaceId == type(ERC721).interfaceId
            || interfaceId == type(ERC721TokenReceiver).interfaceId;
    }
}