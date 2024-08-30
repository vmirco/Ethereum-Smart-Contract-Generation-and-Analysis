pragma solidity ^0.8.0;

abstract contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public view virtual returns (uint256);
    function transfer(address to, uint256 value) public virtual;
    event Transfer(address indexed from, address indexed to, uint256 value);
} 

contract GoldContract is ERC20Basic {
    mapping(address => uint256) balances;

    function transfer(address _to, uint256 _value) public virtual override {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        emit Transfer(msg.sender, _to, _value);
    }

    function balanceOf(address _owner) public view virtual override returns (uint256 balance) {
        return balances[_owner];
    }
}

contract CacheContract {
    GoldContract public goldContract;
    mapping(address => uint256) public lockedBalances;

    constructor(GoldContract _goldContract) {
        goldContract = _goldContract;
    }

    function lockGold(uint256 _amount) public {
        require(goldContract.balanceOf(msg.sender) >= _amount, "Not enough gold to lock");
        goldContract.transfer(address(this), _amount);
        lockedBalances[msg.sender] += _amount;
    }

    function unlockGold(uint256 _amount) public {
        require(lockedBalances[msg.sender] >= _amount, "Not enough gold locked");
        lockedBalances[msg.sender] -= _amount;
        goldContract.transfer(msg.sender, _amount);
    }

    function getLockedBalance(address _owner) public view returns (uint256) {
        return lockedBalances[_owner];
    }
}