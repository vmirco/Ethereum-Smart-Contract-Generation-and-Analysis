// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenMinting {
    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint256 public maxSupply;
    uint256 public publicPrice;
    uint256 public presalePrice;
    uint256 public publicMintLimit;
    uint256 public presaleMintLimit;
    bytes32 public merkleRoot;
    address public owner;

    mapping(address => uint256) public balanceOf;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(string memory _name, string memory _symbol, uint256 _maxSupply, uint256 _publicPrice, uint256 _presalePrice, uint256 _publicMintLimit, uint256 _presaleMintLimit) {
        name = _name;
        symbol = _symbol;
        maxSupply = _maxSupply;
        publicPrice = _publicPrice;
        presalePrice = _presalePrice;
        publicMintLimit = _publicMintLimit;
        presaleMintLimit = _presaleMintLimit;
        owner = msg.sender;
    }

    function mintPublic(uint256 amount) public payable {
        require(totalSupply + amount <= maxSupply, "Exceeds max supply");
        require(amount <= publicMintLimit, "Exceeds public mint limit");
        require(msg.value >= publicPrice * amount, "Insufficient funds");

        totalSupply += amount;
        balanceOf[msg.sender] += amount;
    }

    function mintPresale(uint256 amount, bytes32[] calldata merkleProof) public payable {
        require(totalSupply + amount <= maxSupply, "Exceeds max supply");
        require(amount <= presaleMintLimit, "Exceeds presale mint limit");
        require(msg.value >= presalePrice * amount, "Insufficient funds");
        require(verify(merkleProof, merkleRoot, keccak256(abi.encodePacked(msg.sender))), "Invalid proof");

        totalSupply += amount;
        balanceOf[msg.sender] += amount;
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function withdrawFunds() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
    }
}