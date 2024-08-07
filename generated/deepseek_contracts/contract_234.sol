// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract E4Token {
    string public name = "E4Token";
    string public symbol = "E4T";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public dividends;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event WithdrawDividends(address indexed to, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    address public owner;

    constructor() {
        owner = msg.sender;
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
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function mint(address _to, uint256 _value) public onlyOwner returns (bool success) {
        totalSupply += _value;
        balanceOf[_to] += _value;
        emit Mint(_to, _value);
        emit Transfer(address(0), _to, _value);
        return true;
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        totalSupply -= _value;
        balanceOf[msg.sender] -= _value;
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }

    function distributeDividends(uint256 _amount) public onlyOwner {
        require(totalSupply > 0, "No tokens issued");
        for (uint256 i = 0; i < totalSupply; i++) {
            address holder = address(uint160(i));
            if (balanceOf[holder] > 0) {
                dividends[holder] += (_amount * balanceOf[holder]) / totalSupply;
            }
        }
    }

    function withdrawDividends() public returns (bool success) {
        uint256 amount = dividends[msg.sender];
        require(amount > 0, "No dividends to withdraw");
        dividends[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit WithdrawDividends(msg.sender, amount);
        return true;
    }

    receive() external payable {}
}