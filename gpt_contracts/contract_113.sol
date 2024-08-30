// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DigitalAsset {
    mapping(address => uint) balances;
    address public owner;
    uint public totalSupply;
    string public name;
    string public symbol;

    constructor(string memory _name, string memory _symbol, uint _totalSupply) {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply;
        balances[owner] = totalSupply;
    }

    function transfer(address _to, uint _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
    }

    function balanceOf(address _account) public view returns (uint) {
        return balances[_account];
    }

    function mint(uint _amount) public {
        require(msg.sender == owner, "Only owner can mint tokens");
        totalSupply += _amount;
        balances[owner] += _amount;
    }

    function burn(uint _amount) public {
        require(msg.sender == owner, "Only owner can burn tokens");
        require(balances[owner] >= _amount, "Insufficient balance to burn");
        totalSupply -= _amount;
        balances[owner] -= _amount;
    }
}