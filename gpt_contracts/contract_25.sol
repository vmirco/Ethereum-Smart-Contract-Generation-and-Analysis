// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract StandardToken {
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    uint256 public totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < uint256(-1)) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract BurnableUpgradeableToken is StandardToken {
    event Burn(address indexed burner, uint256 value);
    event Upgrade(address indexed to, uint256 value);

    address public upgradeTarget;
    mapping(address => bool) public upgraded;

    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);
        balances[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
    }

    function setUpgradeTarget(address _target) public {
        upgradeTarget = _target;
    }

    function upgrade(uint256 _value) public {
        require(upgradeTarget != address(0));
        require(!upgraded[msg.sender]);
        require(_value <= balances[msg.sender]);
        
        balances[msg.sender] -= _value;
        totalSupply -= _value;

        upgraded[msg.sender] = true;
        balances[upgradeTarget] += _value;
        totalSupply += _value;
        
        emit Upgrade(upgradeTarget, _value);
    }
}