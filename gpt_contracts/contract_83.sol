// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply;
    string public name;
    string public symbol;
    uint public decimal;
    address public owner;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor(string memory _name, string memory _symbol, uint _decimal, uint _totalSupply) {
        name = _name;
        symbol = _symbol;
        decimal = _decimal;
        totalSupply = _totalSupply;
        balances[msg.sender] = _totalSupply;
        owner = msg.sender;
    }

    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint _value) public returns(bool success) {
        require(balances[msg.sender] >= _value, 'balance too low');
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns(bool success) {
        require(balances[_from] >= _value, 'balance too low');
        require(allowance[_from][msg.sender] >= _value, 'allowance too low');
        balances[_to] += _value;
        balances[_from] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint _value) public returns(bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
}

contract TransferETH {

    Token public token;
    event Sent(address from, address to, uint amount);

    constructor(Token _token) {
        token = _token;
    }

    function sendETH(address payable _to) public payable {
        require(msg.value > 0, "Amount must be greater than 0");
        _to.transfer(msg.value);
        emit Sent(msg.sender, _to, msg.value);
    }
}