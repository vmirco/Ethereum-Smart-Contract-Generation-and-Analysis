// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}


contract IBitGuildToken {
    function balanceOf(address who) public view virtual returns(uint256);
    function transfer(address to, uint256 value) public virtual returns(bool);
    function approve(address spender, uint256 value) public virtual returns(bool);
    function transferFrom(address from, address to, uint256 value) public virtual returns(bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract IAgonFight {
    function createFight(uint256, address) public virtual returns(bool);
    function cancelFight(uint256) public virtual returns(bool);
    function challengeFight(uint256, address) public virtual returns(bool);
    function resolveFight(uint256) public virtual returns(bool);
    event FightCreated(uint256 indexed fightId);
    event FightCancelled(uint256 indexed fightId);
    event FightChallenged(uint256 indexed fightId, address challenger);
    event FightResolved(uint256 indexed fightId, address winner);
}


contract ServiceAdmin {
    using SafeMath for uint256;

    address private admin;
    uint256 private maxAgonCount;
    IAgonFight private agonFightContract;

    modifier onlyAdmin() {
        require(msg.sender == admin, 'Only Admin can perform this');
        _;
    }

    constructor(uint256 _maxAgonCount, address _agonFightContract) {
         admin = msg.sender;
         maxAgonCount = _maxAgonCount;
         agonFightContract = IAgonFight(_agonFightContract);
    }

    // Admin functions
    function setMaxAgonCount(uint256 _newCount) public onlyAdmin {
        maxAgonCount = _newCount;
    }

    function setAgonFightContract(address _newContract) public onlyAdmin {
        agonFightContract = IAgonFight(_newContract);
    }

    // Agon services
    function createAgonFight(uint256 _fightId) public onlyAdmin {
        require(agonFightContract.createFight(_fightId, msg.sender), 'Cannot create fight');
        maxAgonCount = maxAgonCount.sub(1);
    }

    function cancelAgonFight(uint256 _fightId) public onlyAdmin {
        require(agonFightContract.cancelFight(_fightId), 'Cannot cancel fight');
        maxAgonCount = maxAgonCount.add(1);
    }

    function challengeAgonFight(uint256 _fightId, address _challenger) public onlyAdmin {
        require(agonFightContract.challengeFight(_fightId, _challenger), 'Cannot challenge fight');
    }

    function resolveAgonFight(uint256 _fightId) public onlyAdmin {
        require(agonFightContract.resolveFight(_fightId), 'Cannot resolve fight');
    }
}