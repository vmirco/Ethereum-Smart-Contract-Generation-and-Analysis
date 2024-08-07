// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Token {
    string public name = "MyToken";
    string public symbol = "MTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public owner;
    bool public transfersEnabled;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public frozenAccount;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed from, uint256 value);
    event FrozenAccount(address indexed target, bool frozen);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier canTransfer() {
        require(transfersEnabled || msg.sender == owner, "Transfers are disabled");
        _;
    }

    constructor() {
        owner = msg.sender;
        totalSupply = 600 * 10**9 * 10**uint256(decimals); // 600 Billion tokens
        balanceOf[owner] = totalSupply;
        transfersEnabled = true;
        emit Transfer(address(0), owner, totalSupply);
    }

    function transfer(address _to, uint256 _value) public canTransfer returns (bool success) {
        require(_to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        require(!frozenAccount[msg.sender], "Sender account is frozen");
        require(!frozenAccount[_to], "Receiver account is frozen");

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

    function transferFrom(address _from, address _to, uint256 _value) public canTransfer returns (bool success) {
        require(_to != address(0), "Invalid address");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        require(!frozenAccount[_from], "Sender account is frozen");
        require(!frozenAccount[_to], "Receiver account is frozen");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");

        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }

    function freezeAccount(address target, bool freeze) public onlyOwner {
        frozenAccount[target] = freeze;
        emit FrozenAccount(target, freeze);
    }

    function enableTransfers(bool _enabled) public onlyOwner {
        transfersEnabled = _enabled;
    }
}