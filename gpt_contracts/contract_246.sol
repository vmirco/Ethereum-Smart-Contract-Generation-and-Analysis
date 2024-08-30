// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract NFTCollection is ERC721, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    address public feeWallet;
    uint256 public feePercentage;
    uint256 public mintCap;

    mapping(address => bool) public nftFactories;

    event CollectionCreated(string _name, string _symbol);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _mintCap,
        address _feeWallet,
        uint256 _feePercentage,
        address _admin
    ) ERC721(_name, _symbol) {
        _setupRole(ADMIN_ROLE, _admin);
        feeWallet = _feeWallet;
        feePercentage = _feePercentage;
        mintCap = _mintCap;
        emit CollectionCreated(_name, _symbol);
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Must have admin role to perform this action");
        _;
    }

    function createCollection(string memory _name, string memory _symbol) public onlyAdmin {
        _setTokenURI(ERC721.totalSupply() + 1, string(abi.encodePacked(_name, ".", _symbol)));
        _mint(msg.sender, ERC721.totalSupply() + 1);
    }

    function setNewAdmin(address _newAdmin) public onlyAdmin {
        grantRole(ADMIN_ROLE, _newAdmin);
        revokeRole(ADMIN_ROLE, msg.sender);
    }

    function setFeeWallet(address _feeWallet) public onlyAdmin {
        feeWallet = _feeWallet;
    }

    function setFeePercentage(uint256 _feePercentage) public onlyAdmin {
        feePercentage = _feePercentage;
    }

    function setMintCap(uint256 _mintCap) public onlyAdmin {
        mintCap = _mintCap;
    }

    function setFactory(address _factory, bool _status) public onlyAdmin {
        nftFactories[_factory] = _status;
    }
}