// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Token {
    string public name = "MyToken";
    string public symbol = "MTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => FrozenBalance[]) public frozenBalances;

    struct FrozenBalance {
        uint256 amount;
        uint256 releaseTime;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Frozen(address indexed owner, uint256 value, uint256 releaseTime);
    event Unfrozen(address indexed owner, uint256 value);

    constructor(uint256 _totalSupply) {
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = _totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Allowance too low");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function freeze(uint256 _value, uint256 _releaseTime) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        frozenBalances[msg.sender].push(FrozenBalance(_value, _releaseTime));
        emit Frozen(msg.sender, _value, _releaseTime);
        return true;
    }

    function unfreeze(uint256 _index) public returns (bool success) {
        require(_index < frozenBalances[msg.sender].length, "Invalid index");
        FrozenBalance storage frozenBalance = frozenBalances[msg.sender][_index];
        require(block.timestamp >= frozenBalance.releaseTime, "Release time not reached");
        balanceOf[msg.sender] += frozenBalance.amount;
        frozenBalances[msg.sender][_index] = frozenBalances[msg.sender][frozenBalances[msg.sender].length - 1];
        frozenBalances[msg.sender].pop();
        emit Unfrozen(msg.sender, frozenBalance.amount);
        return true;
    }
}