// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC20Token {
    string public name = "MyToken";
    string public symbol = "MTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 initialSupply) {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require(value <= balanceOf[from], "Insufficient balance");
        require(value <= allowance[from][msg.sender], "Allowance exceeded");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }
}

contract TokenInteraction {
    ERC20Token public token;

    constructor(address tokenAddress) {
        token = ERC20Token(tokenAddress);
    }

    function transferTokens(address to, uint256 value) public {
        require(token.transferFrom(msg.sender, to, value), "Transfer failed");
    }

    function approveTokens(address spender, uint256 value) public {
        require(token.approve(spender, value), "Approval failed");
    }

    function getTotalSupply() public view returns (uint256) {
        return token.totalSupply();
    }

    function getBalanceOf(address owner) public view returns (uint256) {
        return token.balanceOf(owner);
    }
}

contract ModuleSystem {
    address public owner;
    mapping(address => bool) public modules;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addModule(address module) public onlyOwner {
        modules[module] = true;
    }

    function removeModule(address module) public onlyOwner {
        modules[module] = false;
    }

    function isModuleActive(address module) public view returns (bool) {
        return modules[module];
    }
}

contract TokenManager is TokenInteraction, ModuleSystem {
    constructor(address tokenAddress) TokenInteraction(tokenAddress) ModuleSystem() {}

    function staticCall(address target, bytes memory data) public view returns (bool, bytes memory) {
        return target.staticcall(data);
    }
}