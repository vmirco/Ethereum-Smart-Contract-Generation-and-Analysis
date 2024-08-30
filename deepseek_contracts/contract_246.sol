// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NFTCollectionManager {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant CREATOR_ROLE = keccak256("CREATOR_ROLE");

    address public nftCollectionFactory;
    address public launchpadFeeWallet;
    uint256 public mintCap;
    uint256 public launchpadFeePercentage;

    struct NFTCollection {
        address collectionAddress;
        string name;
        string symbol;
    }

    NFTCollection[] public collections;

    mapping(address => bool) public isCollection;
    mapping(address => mapping(bytes32 => bool)) private roles;

    event NFTCollectionCreated(address indexed collectionAddress, string name, string symbol);
    event FactoryAddressUpdated(address indexed newFactoryAddress);
    event FeeWalletUpdated(address indexed newFeeWallet);
    event MintCapUpdated(uint256 newMintCap);
    event FeePercentageUpdated(uint256 newFeePercentage);

    modifier onlyRole(bytes32 role) {
        require(roles[msg.sender][role], "Not authorized");
        _;
    }

    constructor(address _nftCollectionFactory, address _launchpadFeeWallet, uint256 _mintCap, uint256 _launchpadFeePercentage) {
        nftCollectionFactory = _nftCollectionFactory;
        launchpadFeeWallet = _launchpadFeeWallet;
        mintCap = _mintCap;
        launchpadFeePercentage = _launchpadFeePercentage;

        _grantRole(msg.sender, ADMIN_ROLE);
    }

    function createNFTCollection(string memory _name, string memory _symbol) public onlyRole(CREATOR_ROLE) {
        // Dummy implementation for creating NFT collection
        address newCollectionAddress = address(uint160(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)))));
        collections.push(NFTCollection(newCollectionAddress, _name, _symbol));
        isCollection[newCollectionAddress] = true;

        emit NFTCollectionCreated(newCollectionAddress, _name, _symbol);
    }

    function setNFTCollectionFactory(address _newFactoryAddress) public onlyRole(ADMIN_ROLE) {
        nftCollectionFactory = _newFactoryAddress;
        emit FactoryAddressUpdated(_newFactoryAddress);
    }

    function setLaunchpadFeeWallet(address _newFeeWallet) public onlyRole(ADMIN_ROLE) {
        launchpadFeeWallet = _newFeeWallet;
        emit FeeWalletUpdated(_newFeeWallet);
    }

    function setMintCap(uint256 _newMintCap) public onlyRole(ADMIN_ROLE) {
        mintCap = _newMintCap;
        emit MintCapUpdated(_newMintCap);
    }

    function setLaunchpadFeePercentage(uint256 _newFeePercentage) public onlyRole(ADMIN_ROLE) {
        launchpadFeePercentage = _newFeePercentage;
        emit FeePercentageUpdated(_newFeePercentage);
    }

    function grantRole(address account, bytes32 role) public onlyRole(ADMIN_ROLE) {
        _grantRole(account, role);
    }

    function revokeRole(address account, bytes32 role) public onlyRole(ADMIN_ROLE) {
        _revokeRole(account, role);
    }

    function _grantRole(address account, bytes32 role) internal {
        roles[account][role] = true;
    }

    function _revokeRole(address account, bytes32 role) internal {
        roles[account][role] = false;
    }
}