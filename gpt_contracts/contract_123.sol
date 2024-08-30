// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Ownership Contract
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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// IBEP20 interface
interface IBEP20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Asset Management Contract
contract AssetManager is Ownable {
    struct Asset {
        uint256 id;
        string name;
        address owner;
    }

    Asset[] public assets;

    constructor(string memory _name, uint256 _id) {
        assets.push(Asset(_id, _name, msg.sender));
    }

    function createAsset(string memory _name, uint256 _id) public onlyOwner {
        assets.push(Asset(_id, _name, msg.sender));
    }

    function transferAsset(uint256 _id, address _recipient) public onlyOwner {
        for(uint256 i = 0; i < assets.length; i++){
            if(assets[i].id == _id){
                assets[i].owner = _recipient;
                break;
            }
        }
    }
}