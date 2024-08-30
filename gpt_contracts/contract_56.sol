// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ERC20 Interface
abstract contract ERC20Interface {
    function totalSupply() public view virtual returns (uint);
    function balanceOf(address tokenOwner) public view virtual returns (uint balance);
    function allowance(address tokenOwner, address spender) public view virtual returns (uint remaining);
    function transfer(address to, uint tokens) public virtual returns (bool success);
    function approve(address spender, uint tokens) public virtual returns (bool success);
    function transferFrom(address from, address to, uint tokens) public virtual returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract BasicAttentionToken is ERC20Interface {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;
    uint public cap;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    
    address owner;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint _cap) {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        _totalSupply = 0;
        cap = _cap;
    }

    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner) public view override returns (uint balance) {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public view override returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function createToken(uint tokens) public onlyOwner {
        require(_totalSupply + tokens <= cap, "Creation would exceed token cap");
        _totalSupply = _totalSupply + tokens;
        balances[owner] = balances[owner] + tokens;
        emit Transfer(address(0), owner, tokens);
    } 

    function transfer(address to, uint tokens) public override returns (bool success) {
        require(balances[msg.sender] >= tokens, "Insufficient balance");
        balances[msg.sender] = balances[msg.sender] - tokens;
        balances[to] = balances[to] + tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) public override returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public override returns (bool success) {
        require(balances[from] >= tokens, "Insufficient balance");
        require(allowed[from][msg.sender] >= tokens, "Insufficient allowance");
        
        balances[from] = balances[from] - tokens;
        allowed[from][msg.sender] = allowed[from][msg.sender] - tokens;
        
        balances[to] = balances[to] + tokens;
        emit Transfer(from, to, tokens);
        return true;
    }

    function refund(address payable to, uint tokens) public onlyOwner {
        require(balances[to] >= tokens, "Insufficient balance");
        _totalSupply = _totalSupply - tokens;
        balances[to] = balances[to] - tokens;
        to.transfer(tokens);
        emit Transfer(to, address(0), tokens);
    }
}