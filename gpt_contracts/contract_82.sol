// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Token {

    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 public totalSupply;

    address public feeRecipient;
    uint256 public transferFee = 1;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(string memory _name, string memory _symbol, uint256 _decimals, uint256 _totalSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = _totalSupply;
    }

    function _transfer(address _from, address _to, uint256 _value) private {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(balanceOf[_to] + _value > balanceOf[_to], "Overflow error");

        uint256 fee = (_value * transferFee) / 100;
        uint256 sendAmount = _value - fee;

        balanceOf[_from] -= _value;
        balanceOf[_to] += sendAmount;
        balanceOf[feeRecipient] += fee;

        emit Transfer(_from, _to, sendAmount);
    }
    
    function setFeeRecipient(address _feeRecipient) external {
        feeRecipient = _feeRecipient;
    }
    
    function setTransferFee(uint256 _transferFee) external {
        transferFee = _transferFee;
    }

    function transfer(address _to, uint256 _value) external returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success) {
        require(allowance[_from][msg.sender] >= _value, "Insufficient allowance");

        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}