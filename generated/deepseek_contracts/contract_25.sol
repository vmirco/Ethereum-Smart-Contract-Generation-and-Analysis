// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StandardToken {
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;
    uint256 internal _totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "Transfer to the zero address");
        _balances[from] -= value;
        _balances[to] += value;
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0), "Approve to the zero address");
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowances[from][msg.sender] - value);
        return true;
    }
}

contract BurnableUpgradeableToken is StandardToken {
    event Burn(address indexed burner, uint256 value);
    event Upgrade(address indexed upgrader, uint256 value);

    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "Burn from the zero address");
        _totalSupply -= value;
        _balances[account] -= value;
        emit Burn(account, value);
        emit Transfer(account, address(0), value);
    }

    function upgrade(uint256 value) public {
        _upgrade(msg.sender, value);
    }

    function _upgrade(address account, uint256 value) internal {
        require(account != address(0), "Upgrade from the zero address");
        _totalSupply += value;
        _balances[account] += value;
        emit Upgrade(account, value);
        emit Transfer(address(0), account, value);
    }
}