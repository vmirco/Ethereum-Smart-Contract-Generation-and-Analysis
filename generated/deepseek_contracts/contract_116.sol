// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OlympusAuthority {
    address public governor;
    address public guardian;
    address public policy;

    constructor(address _governor, address _guardian, address _policy) {
        governor = _governor;
        guardian = _guardian;
        policy = _policy;
    }

    modifier onlyGovernor() {
        require(msg.sender == governor, "Only Governor");
        _;
    }

    modifier onlyGuardian() {
        require(msg.sender == guardian, "Only Guardian");
        _;
    }

    modifier onlyPolicy() {
        require(msg.sender == policy, "Only Policy");
        _;
    }

    function setGovernor(address _governor) public onlyGovernor {
        governor = _governor;
    }

    function setGuardian(address _guardian) public onlyGovernor {
        guardian = _guardian;
    }

    function setPolicy(address _policy) public onlyGovernor {
        policy = _policy;
    }
}

contract OlympusERC20Token {
    string public name = "Olympus";
    string public symbol = "OLY";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    OlympusAuthority public authority;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    constructor(address _governor, address _guardian, address _policy) {
        authority = new OlympusAuthority(_governor, _guardian, _policy);
    }

    modifier onlyGovernor() {
        require(msg.sender == authority.governor(), "Only Governor");
        _;
    }

    modifier onlyGuardian() {
        require(msg.sender == authority.guardian(), "Only Guardian");
        _;
    }

    modifier onlyPolicy() {
        require(msg.sender == authority.policy(), "Only Policy");
        _;
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
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function mint(address _to, uint256 _value) public onlyPolicy returns (bool success) {
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
}