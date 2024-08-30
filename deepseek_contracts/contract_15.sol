// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract KaijuKingzNFT {
    address public owner;
    uint256 public totalSupply;
    string public baseURI;

    struct Kaiju {
        string name;
        string bio;
        bool isRevealed;
    }

    mapping(uint256 => Kaiju) public kaijus;
    mapping(uint256 => address) public kaijuToOwner;
    mapping(address => uint256) public ownerKaijuCount;

    event KaijuCreated(uint256 indexed kaijuId, string name, string bio, address indexed owner);
    event KaijuRevealed(uint256 indexed kaijuId);
    event KaijuNameChanged(uint256 indexed kaijuId, string newName);
    event KaijuBioChanged(uint256 indexed kaijuId, string newBio);
    event KaijuFused(uint256 indexed kaijuId1, uint256 indexed kaijuId2, uint256 newKaijuId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyKaijuOwner(uint256 kaijuId) {
        require(kaijuToOwner[kaijuId] == msg.sender, "Not the owner of this Kaiju");
        _;
    }

    constructor(string memory _baseURI) {
        owner = msg.sender;
        baseURI = _baseURI;
    }

    function createKaiju(string memory _name, string memory _bio) external {
        totalSupply++;
        uint256 kaijuId = totalSupply;
        kaijus[kaijuId] = Kaiju(_name, _bio, false);
        kaijuToOwner[kaijuId] = msg.sender;
        ownerKaijuCount[msg.sender]++;
        emit KaijuCreated(kaijuId, _name, _bio, msg.sender);
    }

    function revealKaiju(uint256 kaijuId) external onlyKaijuOwner(kaijuId) {
        kaijus[kaijuId].isRevealed = true;
        emit KaijuRevealed(kaijuId);
    }

    function changeKaijuName(uint256 kaijuId, string memory newName) external onlyKaijuOwner(kaijuId) {
        kaijus[kaijuId].name = newName;
        emit KaijuNameChanged(kaijuId, newName);
    }

    function changeKaijuBio(uint256 kaijuId, string memory newBio) external onlyKaijuOwner(kaijuId) {
        kaijus[kaijuId].bio = newBio;
        emit KaijuBioChanged(kaijuId, newBio);
    }

    function fuseKaijus(uint256 kaijuId1, uint256 kaijuId2) external onlyKaijuOwner(kaijuId1) onlyKaijuOwner(kaijuId2) {
        require(kaijuId1 != kaijuId2, "Cannot fuse the same Kaiju");
        require(kaijus[kaijuId1].isRevealed && kaijus[kaijuId2].isRevealed, "Both Kaijus must be revealed");

        // Burn the original Kaijus
        delete kaijus[kaijuId1];
        delete kaijus[kaijuId2];
        ownerKaijuCount[msg.sender] -= 2;

        // Create a new Kaiju
        totalSupply++;
        uint256 newKaijuId = totalSupply;
        kaijus[newKaijuId] = Kaiju("Fusion Kaiju", "A powerful fusion of two Kaijus", false);
        kaijuToOwner[newKaijuId] = msg.sender;
        ownerKaijuCount[msg.sender]++;

        emit KaijuFused(kaijuId1, kaijuId2, newKaijuId);
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }
}