// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenMinter {
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

    mapping(address => uint256) public balances;
    mapping(address => uint256) public presaleMints;
    mapping(address => uint256) public publicMints;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        uint256 _publicPrice,
        uint256 _presalePrice,
        uint256 _publicMintLimit,
        uint256 _presaleMintLimit
    ) {
        name = _name;
        symbol = _symbol;
        maxSupply = _maxSupply;
        publicPrice = _publicPrice;
        presalePrice = _presalePrice;
        publicMintLimit = _publicMintLimit;
        presaleMintLimit = _presaleMintLimit;
        owner = msg.sender;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function presaleMint(uint256 amount, bytes32[] calldata proof) external payable {
        require(totalSupply + amount <= maxSupply, "Exceeds max supply");
        require(presaleMints[msg.sender] + amount <= presaleMintLimit, "Exceeds presale mint limit");
        require(msg.value == presalePrice * amount, "Incorrect ETH amount");
        require(verify(proof, keccak256(abi.encodePacked(msg.sender))), "Invalid proof");

        _mint(msg.sender, amount);
        presaleMints[msg.sender] += amount;
    }

    function publicMint(uint256 amount) external payable {
        require(totalSupply + amount <= maxSupply, "Exceeds max supply");
        require(publicMints[msg.sender] + amount <= publicMintLimit, "Exceeds public mint limit");
        require(msg.value == publicPrice * amount, "Incorrect ETH amount");

        _mint(msg.sender, amount);
        publicMints[msg.sender] += amount;
    }

    function _mint(address to, uint256 amount) internal {
        totalSupply += amount;
        balances[to] += amount;
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function verify(bytes32[] memory proof, bytes32 leaf) internal view returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == merkleRoot;
    }
}