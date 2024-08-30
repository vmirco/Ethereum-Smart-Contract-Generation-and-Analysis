// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
  
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
  
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
}

contract ProfitTracker {
    using SafeMath for uint256;

    mapping (address => uint256) private _deposits;
    mapping (address => uint256) private _profits;

    address private _owner;
    address private _F1;
    address private _network;

    constructor() {
        _owner = msg.sender;
    }
  
    modifier onlyOwner(){
        require(msg.sender == _owner, "Only for contract's owner!");
        _;
    }
  
    modifier onlyF1(){
        require(msg.sender == _F1, "Only for F1!");
        _;
    }
  
    modifier onlyNetwork(){
        require(msg.sender == _network, "Only for network!");
        _;
    }
  
    function setF1(address newF1) public onlyOwner {
        _F1 = newF1;
    }
  
    function setNetwork(address newNetwork) public onlyOwner {
        _network = newNetwork;
    }

    function addDeposit(uint256 amount) public {
        require(amount > 0, "Deposit must be a positive number!");
        _deposits[msg.sender] = _deposits[msg.sender].add(amount);
    }

    function addF1Deposit(uint256 amount) public onlyF1 {
        require(amount > 0, "Deposit must be a positive number!");
        _deposits[msg.sender] = _deposits[msg.sender].add(amount);
    }

    function addNetworkDeposit(uint256 amount) public onlyNetwork {
        require(amount > 0, "Deposit must be a positive number!");
        _deposits[msg.sender] = _deposits[msg.sender].add(amount);
    }

    function retrieveDeposits() public view returns (uint256) {
        return _deposits[msg.sender];
    }

    function totalDeposits() public view returns (uint256) {
        uint256 total;
        for (uint256 i = 0; i < _deposits.length; i++) {
            total = total.add(_deposits[i]);
        }
        return total;
    }

    function addProfits(uint256 profit) public onlyOwner {
        require(profit > 0, "Profit must be a positive number!");
        _profits[msg.sender] = _profits[msg.sender].add(profit);
    }

    function retrieveProfits() public view returns (uint256) {
        return _profits[msg.sender];
    }

    function totalProfits() public view returns (uint256) {
        uint256 total;
        for (uint256 i = 0; i < _profits.length; i++) {
            total = total.add(_profits[i]);
        }
        return total;
    }
}