// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract PRBProxyPlugin {
    function supportsInterface(bytes4 _interfaceID) external pure virtual returns (bool);
}

interface TargetChangeOwner {
    function changeOwner(address newOwner) external;
    function getOwner() external view returns (address);
}

contract ManageTargetOwnership is PRBProxyPlugin, TargetChangeOwner {
    address private _targetOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner){
        _targetOwner = initialOwner;
    }
    
    modifier onlyOwner() {
        require(isOwner(), "ManageTargetOwnership: caller is not the owner");
        _;
    }

    function supportsInterface(bytes4 _interfaceID) external pure override returns (bool) {
        return _interfaceID == type(TargetChangeOwner).interfaceId;
    }

    function isOwner() public view returns (bool) {
        return (msg.sender == _targetOwner);
    }

    function getOwner() public view override returns (address) {
        return _targetOwner;
    }

    function changeOwner(address newOwner) public override onlyOwner {
        require(newOwner != address(0), "ManageTargetOwnership: new owner is the zero address");
        emit OwnershipTransferred(_targetOwner, newOwner);
        _targetOwner = newOwner;
    }
}