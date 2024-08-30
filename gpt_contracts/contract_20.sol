// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Defining contract of ERC20 token
contract Token {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    uint public totalSupply = 1000000 * 10 ** 18;
    string public name = "New Token";
    string public symbol = "NT";
    uint public decimals = 18;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor() {
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }

    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint value) public returns(bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }
}

// Liquidity provider contract
contract LiquidityProvider {
    Token private token;
    address public admin;
    uint public providerFee;
    uint public balance;
    uint public liquidity;

    constructor(Token _token, uint _providerFee) {
        token = _token;
        admin = msg.sender;
        providerFee = _providerFee;
    }

    function provideLiquidity(uint _liquidity) public {
        uint fee = (_liquidity * providerFee) / 100;
        require(token.transferFrom(msg.sender, address(this), _liquidity + fee), "transfer from failed");
        liquidity += _liquidity;
        balance += fee;
    }

    function removeLiquidity(uint _liquidity) public {
        require(liquidity >= _liquidity, 'Not enough liquidity');
        require(token.transfer(msg.sender, _liquidity), "transfer failed");
        liquidity -= _liquidity;
    }

    function swapTokens(address _to, uint _amount) public {
        require(_amount <= liquidity, 'Not enough liquidity');
        require(token.transfer(_to, _amount), "transfer failed");
        liquidity -= _amount;
    }

    function claimFees() public {
        require(msg.sender == admin, 'only admin');
        require(token.transfer(admin, balance), "transfer failed");
        balance = 0;
    }
}