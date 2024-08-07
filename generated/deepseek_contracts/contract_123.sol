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
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
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

    uint256 private _assetCount;
    mapping(uint256 => Asset) private _assets;
    mapping(address => uint256[]) private _userAssets;

    event AssetCreated(uint256 indexed id, string name, address owner);
    event AssetTransferred(uint256 indexed id, address from, address to);

    constructor(string memory uniqueIdentifier, string memory name) {
        createAsset(uniqueIdentifier, name);
    }

    function createAsset(string memory uniqueIdentifier, string memory name) public onlyOwner returns (uint256) {
        _assetCount++;
        Asset memory newAsset = Asset(_assetCount, name, msg.sender);
        _assets[_assetCount] = newAsset;
        _userAssets[msg.sender].push(_assetCount);
        emit AssetCreated(_assetCount, name, msg.sender);
        return _assetCount;
    }

    function transferAsset(uint256 assetId, address to) public {
        require(_assets[assetId].owner == msg.sender, "AssetManager: caller is not the owner of the asset");
        require(to != address(0), "AssetManager: transfer to the zero address");

        _assets[assetId].owner = to;
        _userAssets[to].push(assetId);
        removeAssetFromUser(msg.sender, assetId);

        emit AssetTransferred(assetId, msg.sender, to);
    }

    function getAsset(uint256 assetId) public view returns (uint256, string memory, address) {
        Asset memory asset = _assets[assetId];
        return (asset.id, asset.name, asset.owner);
    }

    function getUserAssets(address user) public view returns (uint256[] memory) {
        return _userAssets[user];
    }

    function removeAssetFromUser(address user, uint256 assetId) internal {
        uint256[] storage userAssetList = _userAssets[user];
        for (uint256 i = 0; i < userAssetList.length; i++) {
            if (userAssetList[i] == assetId) {
                userAssetList[i] = userAssetList[userAssetList.length - 1];
                userAssetList.pop();
                break;
            }
        }
    }
}