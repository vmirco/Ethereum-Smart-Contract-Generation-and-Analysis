// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PIVOTCHAIN {
    string public constant symbol = "PVT";
    string public constant name = "PIVOTCHAIN Token";
    uint8 public constant decimals = 18;
    
    uint256 public constant _totalSupply = 1000000 * 10**uint256(decimals);
    uint256 public constant _buyPrice = 1 ether;
    mapping(address => uint256) private _balances;
    address private _creator;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Contribution(address indexed _contributor, uint256 _value);

    constructor() {
        _creator = msg.sender;
        _balances[_creator] = _totalSupply;
        emit Transfer(address(0),_creator, _totalSupply);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return _balances[_owner];
    }

    function transfer(address _to, uint256 _amount) public returns (bool success) {
        require(_balances[msg.sender] >= _amount, "Insufficient balance.");
        _balances[msg.sender] -= _amount;
        _balances[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function buy() public payable returns (bool success){
        require(msg.value > 0, "You need to send some Ether");
        require(_buyPrice * (msg.value/1 ether) <= _balances[_creator], "Not enough tokens in the reserve");
        uint256 amount = (msg.value / 1 ether) * _buyPrice;
        _balances[msg.sender] += amount;
        _balances[_creator] -= amount;
        emit Contribution(msg.sender, amount);
        emit Transfer(_creator, msg.sender, amount);
        return true;
    }
}