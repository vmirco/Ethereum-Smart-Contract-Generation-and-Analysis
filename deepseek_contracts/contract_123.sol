// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract AssetManager is Ownable {
    struct Asset {
        uint256 id;
        string name;
        address owner;
    }

    uint256 private _assetIdCounter;
    mapping(uint256 => Asset) private _assets;

    event AssetCreated(uint256 indexed id, string name, address owner);
    event AssetTransferred(uint256 indexed id, address from, address to);

    constructor(uint256 uniqueIdentifier, string memory name) {
        _createAsset(uniqueIdentifier, name, msg.sender);
    }

    function createAsset(uint256 uniqueIdentifier, string memory name) public onlyOwner {
        _createAsset(uniqueIdentifier, name, msg.sender);
    }

    function transferAsset(uint256 id, address newOwner) public {
        Asset storage asset = _assets[id];
        require(asset.owner == msg.sender, "AssetManager: caller is not the owner of the asset");
        asset.owner = newOwner;
        emit AssetTransferred(id, msg.sender, newOwner);
    }

    function getAsset(uint256 id) public view returns (uint256, string memory, address) {
        Asset storage asset = _assets[id];
        return (asset.id, asset.name, asset.owner);
    }

    function _createAsset(uint256 uniqueIdentifier, string memory name, address owner) internal {
        _assetIdCounter++;
        _assets[_assetIdCounter] = Asset({
            id: uniqueIdentifier,
            name: name,
            owner: owner
        });
        emit AssetCreated(uniqueIdentifier, name, owner);
    }
}