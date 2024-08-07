// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

contract KaijuKingzNFT {
    string public name = "KaijuKingz";
    string public symbol = "KK";
    uint256 public totalSupply;
    address public owner;

    struct Kaiju {
        string name;
        string bio;
        bool revealed;
    }

    mapping(uint256 => Kaiju) public kaijus;
    mapping(uint256 => address) public tokenOwner;
    mapping(uint256 => address) public tokenApprovals;
    mapping(address => mapping(address => bool)) private operatorApprovals;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event KaijuRevealed(uint256 indexed tokenId, string name, string bio);
    event KaijuFused(uint256 indexed tokenId1, uint256 indexed tokenId2, uint256 newTokenId);
    event KaijuNameChanged(uint256 indexed tokenId, string newName);
    event KaijuBioChanged(uint256 indexed tokenId, string newBio);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyTokenOwner(uint256 tokenId) {
        require(msg.sender == tokenOwner[tokenId], "Not token owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function balanceOf(address _owner) external view returns (uint256) {
        uint256 balance = 0;
        for (uint256 i = 1; i <= totalSupply; i++) {
            if (tokenOwner[i] == _owner) {
                balance++;
            }
        }
        return balance;
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        return tokenOwner[tokenId];
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "Transfer to non ERC721Receiver implementer");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external {
        safeTransferFrom(from, to, tokenId, "");
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        require(from == tokenOwner[tokenId] || msg.sender == tokenApprovals[tokenId] || isApprovedForAll(from, msg.sender), "Not approved");
        _transfer(from, to, tokenId);
    }

    function approve(address to, uint256 tokenId) external {
        address owner = tokenOwner[tokenId];
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not approved");
        tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) external {
        operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return operatorApprovals[owner][operator];
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) internal returns (bool) {
        if (to.code.length == 0) return true;
        try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
            return retval == IERC721Receiver.onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert("Transfer to non ERC721Receiver implementer");
            } else {
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        require(tokenOwner[tokenId] == from, "From address is not token owner");
        require(to != address(0), "Transfer to the zero address");

        tokenOwner[tokenId] = to;
        tokenApprovals[tokenId] = address(0);

        emit Transfer(from, to, tokenId);
    }

    function mint(string memory _name, string memory _bio) external onlyOwner {
        totalSupply++;
        kaijus[totalSupply] = Kaiju(_name, _bio, false);
        tokenOwner[totalSupply] = owner;
        emit Transfer(address(0), owner, totalSupply);
    }

    function revealKaiju(uint256 tokenId, string memory _name, string memory _bio) external onlyTokenOwner(tokenId) {
        kaijus[tokenId].name = _name;
        kaijus[tokenId].bio = _bio;
        kaijus[tokenId].revealed = true;
        emit KaijuRevealed(tokenId, _name, _bio);
    }

    function fuseKaijus(uint256 tokenId1, uint256 tokenId2) external onlyTokenOwner(tokenId1) onlyTokenOwner(tokenId2) {
        require(tokenId1 != tokenId2, "Cannot fuse the same token");
        require(kaijus[tokenId1].revealed && kaijus[tokenId2].revealed, "Kaijus must be revealed");

        totalSupply++;
        kaijus[totalSupply] = Kaiju(kaijus[tokenId1].name, kaijus[tokenId2].bio, true);
        tokenOwner[totalSupply] = tokenOwner[tokenId1];

        _burn(tokenId1);
        _burn(tokenId2);

        emit KaijuFused(tokenId1, tokenId2, totalSupply);
    }

    function changeKaijuName(uint256 tokenId, string memory newName) external onlyTokenOwner(tokenId) {
        kaijus[tokenId].name = newName;
        emit KaijuNameChanged(tokenId, newName);
    }

    function changeKaijuBio(uint256 tokenId, string memory newBio) external onlyTokenOwner(tokenId) {
        kaijus[tokenId].bio = newBio;
        emit KaijuBioChanged(tokenId, newBio);
    }

    function _burn(uint256 tokenId) internal {
        address owner = tokenOwner[tokenId];
        tokenOwner[tokenId] = address(0);
        tokenApprovals[tokenId] = address(0);
        emit Transfer(owner, address(0), tokenId);
    }
}