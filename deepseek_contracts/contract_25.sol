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

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        require(_balances[msg.sender] >= amount, "ST: transfer amount exceeds balance");
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        require(_allowances[sender][msg.sender] >= amount, "ST: transfer amount exceeds allowance");
        require(_balances[sender] >= amount, "ST: transfer amount exceeds balance");
        _allowances[sender][msg.sender] -= amount;
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
}

contract BurnableUpgradeableToken is StandardToken {
    event Burn(address indexed burner, uint256 value);
    event Upgrade(address indexed upgrader, uint256 value);

    function burn(uint256 _value) public {
        require(_balances[msg.sender] >= _value, "BUT: burn amount exceeds balance");
        _balances[msg.sender] -= _value;
        _totalSupply -= _value;
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0), _value);
    }

    function upgrade(uint256 _value) public {
        _totalSupply += _value;
        _balances[msg.sender] += _value;
        emit Upgrade(msg.sender, _value);
        emit Transfer(address(0), msg.sender, _value);
    }
}