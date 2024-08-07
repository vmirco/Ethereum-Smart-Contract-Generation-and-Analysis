// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AccessControl.sol";
import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721URIStorage.sol";

contract NFTCollectionManager is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant FACTORY_ROLE = keccak256("FACTORY_ROLE");

    address public nftCollectionFactory;
    address public launchpadFeeWallet;
    uint256 public mintCap;
    uint256 public launchpadFeePercentage;

    struct Collection {
        address collectionAddress;
        string name;
        string symbol;
    }

    Collection[] public collections;

    event CollectionCreated(address indexed collectionAddress, string name, string symbol);
    event FactoryAddressUpdated(address indexed newFactoryAddress);
    event FeeWalletUpdated(address indexed newFeeWallet);
    event MintCapUpdated(uint256 newMintCap);
    event FeePercentageUpdated(uint256 newFeePercentage);

    constructor(address _admin, address _nftCollectionFactory, address _launchpadFeeWallet, uint256 _mintCap, uint256 _launchpadFeePercentage) {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(ADMIN_ROLE, _admin);
        nftCollectionFactory = _nftCollectionFactory;
        launchpadFeeWallet = _launchpadFeeWallet;
        mintCap = _mintCap;
        launchpadFeePercentage = _launchpadFeePercentage;
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "NFTCollectionManager: caller is not an admin");
        _;
    }

    modifier onlyFactory() {
        require(msg.sender == nftCollectionFactory, "NFTCollectionManager: caller is not the factory");
        _;
    }

    function setFactoryAddress(address _newFactoryAddress) external onlyAdmin {
        nftCollectionFactory = _newFactoryAddress;
        emit FactoryAddressUpdated(_newFactoryAddress);
    }

    function setFeeWallet(address _newFeeWallet) external onlyAdmin {
        launchpadFeeWallet = _newFeeWallet;
        emit FeeWalletUpdated(_newFeeWallet);
    }

    function setMintCap(uint256 _newMintCap) external onlyAdmin {
        mintCap = _newMintCap;
        emit MintCapUpdated(_newMintCap);
    }

    function setFeePercentage(uint256 _newFeePercentage) external onlyAdmin {
        launchpadFeePercentage = _newFeePercentage;
        emit FeePercentageUpdated(_newFeePercentage);
    }

    function createCollection(string memory _name, string memory _symbol) external onlyFactory returns (address) {
        NFTCollection newCollection = new NFTCollection(_name, _symbol, msg.sender, launchpadFeeWallet, mintCap, launchpadFeePercentage);
        collections.push(Collection({
            collectionAddress: address(newCollection),
            name: _name,
            symbol: _symbol
        }));
        emit CollectionCreated(address(newCollection), _name, _symbol);
        return address(newCollection);
    }
}

contract NFTCollection is ERC721, ERC721Enumerable, ERC721URIStorage {
    address public factory;
    address public feeWallet;
    uint256 public mintCap;
    uint256 public feePercentage;

    constructor(string memory _name, string memory _symbol, address _factory, address _feeWallet, uint256 _mintCap, uint256 _feePercentage) ERC721(_name, _symbol) {
        factory = _factory;
        feeWallet = _feeWallet;
        mintCap = _mintCap;
        feePercentage = _feePercentage;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function mintNFT(address to, uint256 tokenId, string memory uri) external {
        require(msg.sender == factory, "NFTCollection: caller is not the factory");
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }
}