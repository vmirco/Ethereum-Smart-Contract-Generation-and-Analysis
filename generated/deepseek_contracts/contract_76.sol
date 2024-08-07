// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
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

    function setAsset(address assetAddress, uint256 quantity, uint256 price) public onlyOwner {
        assets[assetAddress] = Asset(quantity, price);
    }

    function calculateTotalValue(address assetAddress) public view onlyOwner returns (uint256) {
        Asset memory asset = assets[assetAddress];
        require(asset.quantity > 0 && asset.price > 0, "Asset not found or invalid data");
        return asset.quantity * asset.price;
    }
}