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
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IOracle {
    function consult(address token, uint amountIn) external view returns (uint amountOut);
}

interface IMasonry {
    function distributeSeigniorage(uint256 amount) external;
    function delegateBonds(address to, uint256 amount) external;
}

contract Treasury is Ownable {

    IMasonry public masonry;
    IOracle public oracle;
    address public piggyAddress;
    uint256 public lastestPrice;

    constructor(address masonryAddress, address oracleAddress, address piggy) {
        masonry = IMasonry(masonryAddress);
        oracle = IOracle(oracleAddress);
        piggyAddress = piggy;
    }

    function setMasonry(address masonryAddress) public onlyOwner {
        masonry = IMasonry(masonryAddress);
    }

    function setOperator(address oracleAddress) public onlyOwner {
        oracle = IOracle(oracleAddress);;
    }
  
    function updatePiggyAddress(address piggy) public onlyOwner {
        piggyAddress = piggy;
    }

    function distributeSeigniorage(uint256 amount) public onlyOwner {
        masonry.distributeSeigniorage(amount);
    }

    function delegateBonds(address to, uint256 amount) public onlyOwner {
        masonry.delegateBonds(to, amount);
    }

    function getPiggyPrice() public returns (uint256) {
        lastestPrice = oracle.consult(piggyAddress, 1e18);
        return lastestPrice;
    }
}