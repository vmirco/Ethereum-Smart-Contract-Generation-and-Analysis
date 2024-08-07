// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LimitedNFT {
    string private _baseURI;
    string private _baseExtension;
    uint256 private _cost;
    uint256 private _maxSupply;
    uint256 private _totalSupply;
    address private _owner;

    mapping(uint256 => string) private _tokenURIs;

    event Mint(address indexed to, uint256 tokenId);

    modifier onlyOwner() {
        require(msg.sender == _owner, "Not the contract owner");
        _;
    }

    constructor(string memory baseURI, string memory baseExtension, uint256 cost, uint256 maxSupply) {
        _baseURI = baseURI;
        _baseExtension = baseExtension;
        _cost = cost;
        _maxSupply = maxSupply;
        _owner = msg.sender;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseURI = baseURI;
    }

    function setBaseExtension(string memory baseExtension) public onlyOwner {
        _baseExtension = baseExtension;
    }

    function setCost(uint256 cost) public onlyOwner {
        _cost = cost;
    }

    function setMaxSupply(uint256 maxSupply) public onlyOwner {
        require(maxSupply >= _totalSupply, "New max supply must be greater than current total supply");
        _maxSupply = maxSupply;
    }

    function mint() public payable {
        require(_totalSupply < _maxSupply, "Max supply reached");
        require(msg.value >= _cost, "Insufficient Ether sent");

        _totalSupply++;
        uint256 tokenId = _totalSupply;
        _tokenURIs[tokenId] = string(abi.encodePacked(_baseURI, toString(tokenId), _baseExtension));

        emit Mint(msg.sender, tokenId);
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(tokenId <= _totalSupply && tokenId > 0, "Token ID does not exist");
        return _tokenURIs[tokenId];
    }

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}