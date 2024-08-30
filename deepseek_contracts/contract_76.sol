// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract AssetValueCalculator is Ownable {
    struct Asset {
        uint256 quantity;
        uint256 price;
    }

    mapping(address => Asset) public assets;

    event AssetAdded(address indexed assetOwner, uint256 quantity, uint256 price);
    event AssetUpdated(address indexed assetOwner, uint256 quantity, uint256 price);

    function addAsset(uint256 _quantity, uint256 _price) external onlyOwner {
        require(_quantity > 0, "Quantity must be greater than zero");
        require(_price > 0, "Price must be greater than zero");

        assets[msg.sender] = Asset(_quantity, _price);
        emit AssetAdded(msg.sender, _quantity, _price);
    }

    function updateAsset(uint256 _quantity, uint256 _price) external onlyOwner {
        require(_quantity > 0, "Quantity must be greater than zero");
        require(_price > 0, "Price must be greater than zero");
        require(assets[msg.sender].quantity > 0, "Asset does not exist");

        assets[msg.sender] = Asset(_quantity, _price);
        emit AssetUpdated(msg.sender, _quantity, _price);
    }

    function calculateTotalValue(address _assetOwner) public view onlyOwner returns (uint256) {
        Asset memory asset = assets[_assetOwner];
        require(asset.quantity > 0, "Asset does not exist");

        return asset.quantity * asset.price;
    }
}