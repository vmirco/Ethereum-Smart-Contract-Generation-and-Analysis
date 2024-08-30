// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NFTMinter {
    string private baseURI;
    string private baseExtension;
    uint256 public cost;
    uint256 public maxSupply;
    uint256 public totalSupply;
    address public owner;

    mapping(uint256 => address) private _owners;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(
        string memory _baseURI,
        string memory _baseExtension,
        uint256 _cost,
        uint256 _maxSupply
    ) {
        baseURI = _baseURI;
        baseExtension = _baseExtension;
        cost = _cost;
        maxSupply = _maxSupply;
        owner = msg.sender;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setMaxSupply(uint256 _newMaxSupply) public onlyOwner {
        require(_newMaxSupply >= totalSupply, "New max supply must be greater or equal to current total supply");
        maxSupply = _newMaxSupply;
    }

    function mint() public payable {
        require(totalSupply < maxSupply, "Max supply reached");
        require(msg.value >= cost, "Insufficient Ether sent");

        uint256 tokenId = totalSupply + 1;
        _owners[tokenId] = msg.sender;
        totalSupply++;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token does not exist");
        return string(abi.encodePacked(baseURI, uint2str(tokenId), baseExtension));
    }

    function uint2str(uint256 _i) internal pure returns (string memory str) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }
        str = string(bstr);
    }
}