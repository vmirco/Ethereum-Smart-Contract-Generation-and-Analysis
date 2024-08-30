// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

contract ERC721Enumerable {
    mapping(address => uint256) private _ownedTokensCount;
    mapping(uint256 => address) private _tokenOwner;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping (address => bool)) private _operatorApprovals;
    string private _name;
    string private _symbol;

    function balanceOf(address owner) public view virtual returns (uint256);
    function ownerOf(uint256 tokenId) public view virtual returns (address);
    function approve(address to, uint256 tokenId) public virtual;
    function getApproved(uint256 tokenId) public view virtual returns (address);
    function setApprovalForAll(address operator, bool _approved) public virtual;
    function isApprovedForAll(address owner, address operator) public view virtual returns (bool);
    function transferFrom(address from, address to, uint256 tokenId) public virtual;
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual;
    function totalSupply() public view virtual returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256 tokenId);
    function tokenByIndex(uint256 index) public view virtual returns (uint256);
}

contract Ownable {
    address private _owner;

    function owner() public view virtual returns (address);
    function isOwner() public view virtual returns (bool);
    function renounceOwnership() public virtual;
    function transferOwnership(address newOwner) public virtual;
}

contract AirdropItem is ERC721Enumerable, Ownable {
  mapping (uint256 => string) private _tokenURIs;
  uint256 public MAX_MINT = 10;
  uint256 public COST = 0.05 ether;
  string public NOT_REVEAL_URI = '';
  uint256 public REVEAL_TIMESTAMP;
  string public BASE_URI = '';
  uint256 public totalSupply = 0;

  event Minted(address indexed minter, uint256 indexed count);
  event Reveal();

  function mint(uint256 count) public payable {
    require(totalSupply + count <= MAX_MINT, 'Exceeds the maximum mint number');
    require(msg.value >= COST * count, 'Not enough Ether to mint');
    for (uint256 i = 0; i < count; i++) {
      _mint(msg.sender, totalSupply++);
    }
    emit Minted(msg.sender, count);
  }

  function _mint(address to, uint256 tokenId) private {
    // compelete your mint logic
  }

  function tokensOfOwner(address owner) public view returns (uint256[] memory ownerTokens){
    // your logic here
  }

  function tokenURI(uint256 tokenId) public view returns (string memory){
    // your logic here
  }

  function reveal() external onlyOwner {
    REVEAL_TIMESTAMP = block.timestamp;
    emit Reveal();
  }

  function setCost(uint256 cost) external onlyOwner {
    COST = cost;
  }

  function setMaxMint(uint256 maxMint) external onlyOwner {
    MAX_MINT = maxMint;
  }

  function setNotRevealUri(string calldata notRevealUri) external onlyOwner {
    NOT_REVEAL_URI = notRevealUri;
  }

  function setBaseUri(string calldata baseUri) external onlyOwner {
    BASE_URI = baseUri;
  }
}