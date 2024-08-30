// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenTransfer {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event TransferETH(address indexed from, address indexed to, uint256 value);

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function safeTransfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "Transfer to the zero address");
        require(_balances[msg.sender] >= value, "Insufficient balance");

        _balances[msg.sender] -= value;
        _balances[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function safeTransferFrom(address from, address to, uint256 value) public returns (bool) {
        require(to != address(0), "Transfer to the zero address");
        require(_balances[from] >= value, "Insufficient balance");
        require(_allowances[from][msg.sender] >= value, "Allowance too low");

        _balances[from] -= value;
        _balances[to] += value;
        _allowances[from][msg.sender] -= value;

        emit Transfer(from, to, value);
        return true;
    }

    function safeApprove(address spender, uint256 value) public returns (bool) {
        require(spender != address(0), "Approve to the zero address");

        _allowances[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);
        return true;
    }

    function safeTransferETH(address payable to, uint256 value) public payable returns (bool) {
        require(to != address(0), "Transfer to the zero address");
        require(address(this).balance >= value, "Insufficient ETH balance");

        (bool success, ) = to.call{value: value}("");
        require(success, "ETH transfer failed");

        emit TransferETH(msg.sender, to, value);
        return true;
    }

    function mint(address account, uint256 amount) public {
        require(account != address(0), "Mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;

        emit Transfer(address(0), account, amount);
    }

    function burn(address account, uint256 amount) public {
        require(account != address(0), "Burn from the zero address");
        require(_balances[account] >= amount, "Insufficient balance");

        _totalSupply -= amount;
        _balances[account] -= amount;

        emit Transfer(account, address(0), amount);
    }
}