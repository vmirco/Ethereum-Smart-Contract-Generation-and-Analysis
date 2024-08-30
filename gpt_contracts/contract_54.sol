// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyToken {
    string public constant name = "MyToken";
    string public constant symbol = "MTK";
    uint8 public constant decimals = 18;
  
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint tokens);

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
  
    uint256 totalSupply_;

    address public owner_;

    constructor(uint256 total) {
        totalSupply_ = total;
        balances[msg.sender] = totalSupply_;
        owner_ = msg.sender;
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public view returns (uint) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint numTokens) public returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender] - numTokens;
        balances[receiver] = balances[receiver] + numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint numTokens) public returns (bool) {
        require(numTokens <= balances[owner]);    
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner] - numTokens;
        allowed[owner][msg.sender] = allowed[owner][msg.sender] - numTokens;
        balances[buyer] = balances[buyer] + numTokens;
        
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    function mint(uint256 amount) public {
        require(msg.sender == owner_);
        totalSupply_ += amount;
        balances[owner_] += amount;
    }

    function burn(uint256 amount) public {
        require(msg.sender == owner_ && balances[owner_] >= amount);
        totalSupply_ -= amount;
        balances[owner_] -= amount;
    }

    function getOwner() public view returns (address) {
        return owner_;
    }

    function setOwner(address newOwner) public {
        require(msg.sender == owner_);
        owner_ = newOwner;
    }
}