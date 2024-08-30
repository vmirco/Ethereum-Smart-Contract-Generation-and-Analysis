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

interface IBitGuildToken {
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
}

interface IAgonFight {
    function createFight(address challenger, address opponent) external returns (uint256);
    function cancelFight(uint256 fightId) external;
    function challengeFight(uint256 fightId) external;
    function resolveFight(uint256 fightId, address winner) external;
}

contract ServiceAdministrationSystem {
    using SafeMath for uint256;

    address public admin;
    uint256 public maxAgonCount;
    address public agonFightContractAddress;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    constructor(uint256 _maxAgonCount, address _agonFightContractAddress) {
        admin = msg.sender;
        maxAgonCount = _maxAgonCount;
        agonFightContractAddress = _agonFightContractAddress;
    }

    function setMaxAgonCount(uint256 _maxAgonCount) external onlyAdmin {
        maxAgonCount = _maxAgonCount;
    }

    function setAgonFightContractAddress(address _agonFightContractAddress) external onlyAdmin {
        agonFightContractAddress = _agonFightContractAddress;
    }

    function createFight(address challenger, address opponent) external onlyAdmin returns (uint256) {
        IAgonFight agonFight = IAgonFight(agonFightContractAddress);
        return agonFight.createFight(challenger, opponent);
    }

    function cancelFight(uint256 fightId) external onlyAdmin {
        IAgonFight agonFight = IAgonFight(agonFightContractAddress);
        agonFight.cancelFight(fightId);
    }

    function challengeFight(uint256 fightId) external onlyAdmin {
        IAgonFight agonFight = IAgonFight(agonFightContractAddress);
        agonFight.challengeFight(fightId);
    }

    function resolveFight(uint256 fightId, address winner) external onlyAdmin {
        IAgonFight agonFight = IAgonFight(agonFightContractAddress);
        agonFight.resolveFight(fightId, winner);
    }

    function transferBitGuildTokens(address to, uint256 value) external onlyAdmin returns (bool) {
        IBitGuildToken bitGuildToken = IBitGuildToken(agonFightContractAddress);
        return bitGuildToken.transfer(to, value);
    }

    function getBitGuildTokenBalance(address who) external view returns (uint256) {
        IBitGuildToken bitGuildToken = IBitGuildToken(agonFightContractAddress);
        return bitGuildToken.balanceOf(who);
    }
}