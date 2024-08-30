// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OlympusERC20 {
    string public name = "Olympus";
    string public symbol = "OLY";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public minter;
    OlympusAuthority public authority;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    modifier onlyMinter() {
        require(msg.sender == minter, "Only minter can call this function");
        _;
    }

    modifier onlyAuthority() {
        require(authority.canCall(msg.sender, address(this), msg.sig), "Unauthorized");
        _;
    }

    constructor(address _minter, address _authority) {
        minter = _minter;
        authority = OlympusAuthority(_authority);
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

    function mint(address _to, uint256 _value) public onlyMinter onlyAuthority {
        totalSupply += _value;
        balanceOf[_to] += _value;
        emit Mint(_to, _value);
        emit Transfer(address(0), _to, _value);
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

contract OlympusAuthority {
    mapping(address => mapping(address => mapping(bytes4 => bool))) public canCall;

    event SetAuthority(address indexed user, address indexed target, bytes4 indexed functionSig, bool authorized);

    function setAuthority(address user, address target, bytes4 functionSig, bool authorized) public {
        canCall[user][target][functionSig] = authorized;
        emit SetAuthority(user, target, functionSig, authorized);
    }
}