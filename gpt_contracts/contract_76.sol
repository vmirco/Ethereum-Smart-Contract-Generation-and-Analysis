// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable {
    address private _owner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract AssetValuation is Ownable {
    struct Asset {
        uint256 unitPrice;
        uint256 quantity;
    }

    mapping (address => Asset) private assets;

    function setAsset(address assetAddress, uint256 unitPrice, uint256 quantity) public onlyOwner {
        assets[assetAddress] = Asset(unitPrice, quantity);
    }

    function viewAsset(address assetAddress) public view returns (uint256 unitPrice, uint256 quantity) {
        return (assets[assetAddress].unitPrice, assets[assetAddress].quantity);
    }

    function calculateAssetValue(address assetAddress) public view returns (uint256) {
        Asset memory asset = assets[assetAddress];
        return asset.unitPrice * asset.quantity;
    }
}