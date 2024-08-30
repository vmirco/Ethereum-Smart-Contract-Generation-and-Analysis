// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ManageableToken {
    string public constant name = "ManageableToken";
    string public constant symbol = "MGT";
    uint8 public constant decimals = 18;
    uint public totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    
    struct Frozen {
        uint value;
        uint releaseTime;
    }

    mapping(address => Frozen) frozenBalances;

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed owner, address indexed spender, uint tokens);
    event Freeze(address indexed account, uint value, uint releaseTime);
    event Unfreeze(address indexed account, uint value);

    constructor(uint _initialSupply) {
        totalSupply = _initialSupply;
        balances[msg.sender] = _initialSupply;
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        require(balances[msg.sender] >= tokens,"Insufficient balance");
        
        balances[msg.sender] -= tokens;
        balances[to] += tokens;
        
        emit Transfer(msg.sender, to, tokens);
        
        return true;
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require(tokens <= balances[from],"Insufficient balance");
        require(tokens <= allowed[from][msg.sender], "Not allowed");
        
        balances[from] -= tokens;
        balances[to] += tokens;
        allowed[from][msg.sender] -= tokens;
        
        emit Transfer(from, to, tokens);
        
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint remaining) {
        return allowed[owner][spender];
    }

    function freeze(uint value, uint releaseTime) public {
        require(value <= balances[msg.sender], "Insufficient balance");
        require(releaseTime > block.timestamp, "Invalid release time");

        balances[msg.sender] -= value;
        frozenBalances[msg.sender] = Frozen(value, releaseTime);

        emit Freeze(msg.sender, value, releaseTime);
    }

    function unfreeze() public {
        require(block.timestamp >= frozenBalances[msg.sender].releaseTime, "Tokens are still frozen");
        
        uint oldValue = frozenBalances[msg.sender].value;
        
        balances[msg.sender] += oldValue;
        delete frozenBalances[msg.sender];
        
        emit Unfreeze(msg.sender, oldValue);
    }

    function frozenBalanceOf(address account) public view returns (uint value, uint releaseTime) {
        return (frozenBalances[account].value, frozenBalances[account].releaseTime);
    }
}