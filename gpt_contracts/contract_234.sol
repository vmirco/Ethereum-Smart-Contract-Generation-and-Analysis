// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract E4Token {

    // track token balances
    mapping (address => uint256) private balances;
    mapping (address => mapping(address => uint256)) private allowed;
    uint256 private totalSupply;
    
    // track dividends
    mapping (address => uint256) private dividends;

    string public constant name = "E4Token";
    string public constant symbol = "E4T";
    uint8 public constant decimals = 18;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    //modifiers
    modifier onlyValidAddress(address account){
        require(account != address(0), 'Invalid address');
        _;
    }

    function mint(address account, uint256 amount) external onlyValidAddress(account) {
        totalSupply += amount;
        balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function burn(address account, uint256 amount) external onlyValidAddress(account) {
        require(balances[account] >= amount, 'Insufficient balance');
        totalSupply -= amount;
        balances[account] -= amount;
        emit Transfer(account, address(0), amount);
    }

     function totalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount, 'Insufficient balance');
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowed[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(amount <= balances[sender], 'Insufficient balance');
        require(amount <= allowed[sender][msg.sender], 'Insufficient allowance');
        
        balances[sender] -= amount;
        balances[recipient] += amount;
        allowed[sender][msg.sender] -= amount;
        
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function dividendsOf(address account) public view returns (uint256) {
        return dividends[account];
    }

    function withdrawDividends(address account) public returns (bool) {
        require(dividends[account] > 0, 'No dividends available to withdraw');
        
        uint256 amount = dividends[account];
        dividends[account] = 0;
        
        payable(account).transfer(amount);
        return true;
    }

}