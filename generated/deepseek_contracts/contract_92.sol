// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CertificationManager {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event CertificationIssued(address indexed to, uint256 value);
    event CertificationTransferred(address indexed from, address indexed to, uint256 value);
    event TransferApproved(address indexed owner, address indexed spender, uint256 value);
    event TransferRejected(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply;
        balanceOf[msg.sender] = _initialSupply;
        emit CertificationIssued(msg.sender, _initialSupply);
    }

    function issueCertifications(address _to, uint256 _value) public {
        require(_to != address(0), "Invalid address");
        totalSupply += _value;
        balanceOf[_to] += _value;
        emit CertificationIssued(_to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        emit CertificationTransferred(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        emit TransferApproved(msg.sender, _spender, _value);
        return true;
    }

    function rejectTransfer(address _spender) public returns (bool success) {
        allowance[msg.sender][_spender] = 0;
        emit TransferRejected(msg.sender, _spender, 0);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        emit CertificationTransferred(_from, _to, _value);
        return true;
    }
}