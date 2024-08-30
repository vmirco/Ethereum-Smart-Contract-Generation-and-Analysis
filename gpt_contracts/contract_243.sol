// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IBEP20Token {
    string public constant name = "IBEP20 Token";
    string public constant symbol = "IB20";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 1000000000000000000000000000000; // 100 trillion tokens

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    constructor() {
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
    event Transfer(address indexed from, address indexed to, uint256 tokens);

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function balanceOf(address tokenOwner) public view returns (uint256 balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint256 tokens) public returns (bool success) {
        require(balances[msg.sender] >= tokens, "Not enough tokens");
        balances[msg.sender] -= tokens;
        balances[to] += tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint256 tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public view returns (uint256 remaining) {
        return allowed[tokenOwner][spender];
    }

    function transferFrom(address from, address to, uint256 tokens) public returns (bool success) {
        require(tokens <= balances[from], "Not enough tokens");
        require(tokens <= allowed[from][msg.sender], "Not enough allowance");

        balances[from] -= tokens;
        allowed[from][msg.sender] -= tokens;
        balances[to] += tokens;
        emit Transfer(from, to, tokens);
        return true;
    }

    address public owner = msg.sender;
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }
}