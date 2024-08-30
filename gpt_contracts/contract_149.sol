// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/**************************************************
 *  ERC721 Interface
 **************************************************/
contract ERC721 {
    
    mapping (address => uint256) internal _balances;
    mapping (uint256 => address) internal _owners;
    mapping (uint256 => address) internal _tokenApprovals;
    mapping(address => mapping(address => bool)) internal _operatorApprovals;
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    function balanceOf(address owner) external view returns (uint256 balance) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) external view returns (address owner) {
        address owner_ = _owners[tokenId];
        require(owner_ != address(0), "ERC721: owner query for nonexistent token");
        return owner_;
    }
    
    function approve(address to, uint256 tokenId) external {
        address owner = _owners[tokenId];
        require(to != owner, "ERC721: approval to current owner");
        require(msg.sender == owner || _operatorApprovals[owner][msg.sender], "ERC721: approve caller is not owner nor approved for all");

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }
    
    function setApprovalForAll(address operator, bool _approved) external {
        require(operator != msg.sender, "ERC721: approve to caller");
        _operatorApprovals[msg.sender][operator] = _approved;
        emit ApprovalForAll(msg.sender, operator, _approved);
    }
    
    function getApproved(uint256 tokenId) external view returns (address operator) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }
    
    function isApprovedForAll(address owner, address operator) external view returns (bool) {
        return _operatorApprovals[owner][operator];
    }
    
    function _exists(uint256 tokenId) internal view returns (bool) {
         return _owners[tokenId] != address(0);
    }
    
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }
}


/**************************************************
 *  Collection Smart Contract
 **************************************************/
contract NFTCollection is ERC721 {
    
    uint256 public nextTokenId;
    uint256 public timeLimit = block.timestamp + 1 days;
    mapping(address => uint256) public deposit;

    function mint() external {
        require(block.timestamp <= timeLimit, "Time limit exceeded for minting NFT");
        _mint(msg.sender, nextTokenId);
        nextTokenId += 1;
    } 
    
    function reroll(uint256 tokenId) external {
        require(block.timestamp <= timeLimit, "Time limit exceeded for re-rolling NFT");
        require(ownerOf(tokenId) == msg.sender, "Caller is not owner of this NFT");
        _mint(msg.sender, nextTokenId);
        nextTokenId += 1;
    } 

    function depositTokens(uint amount) external {
        deposit[msg.sender] += amount;
    }

    function checkAccessibility(uint256 tokenId) external view returns (bool) {
        if(block.timestamp > timeLimit) {
            return false;
        } else {
            return (_exists(tokenId));
        }
    }
}