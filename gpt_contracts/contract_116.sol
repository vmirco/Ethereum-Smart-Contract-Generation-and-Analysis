// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// SafeMath Library
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "Subtraction underflow");
        uint256 c = a - b;

        return c;
    }
}

// OlympusAuthority Contract
contract OlympusAuthority {
    mapping(address => bool) public isAuthorized;

    constructor() {
        isAuthorized[msg.sender] = true;
    }

    function authorize(address addr) public onlyAuthorized {
        isAuthorized[addr] = true;
    }

    function unauthorize(address addr) public onlyAuthorized {
        isAuthorized[addr] = false;
    }

    modifier onlyAuthorized() {
        require(isAuthorized[msg.sender], "Unauthorized action!");
        _;
    }
}

// OlympusToken contract implementing ERC20
contract OlympusToken is OlympusAuthority {
    using SafeMath for uint256;

    string public constant name = "Olympus";
    string public constant symbol = "OLY";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        require(_to != address(0), "Invalid address");

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
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
        require(_value <= allowance[_from][msg.sender], "Insufficient allowance");
        require(_to != address(0), "Invalid address");

        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);

        return true;
    }

    function mint(address _to, uint256 _amount) public onlyAuthorized returns (bool) {
        require(_to != address(0), "Invalid address");
        
        totalSupply = totalSupply.add(_amount);
        balanceOf[_to] = balanceOf[_to].add(_amount);
        emit Mint(_to, _amount);

        return true;
    }

    function burn(uint256 _amount) public {
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance to burn");

        totalSupply = totalSupply.sub(_amount);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
        emit Burn(msg.sender, _amount);
    }
}