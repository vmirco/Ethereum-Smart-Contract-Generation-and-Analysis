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
    function createFight(uint256 fightId, address challenger) external;
    function cancelFight(uint256 fightId) external;
    function challengeFight(uint256 fightId, address challenger) external;
    function resolveFight(uint256 fightId, address winner) external;
}

contract ServiceAdministration {
    using SafeMath for uint256;

    address public admin;
    uint256 public maxAgonCount;
    address public agonFightContractAddress;

    struct Fight {
        uint256 fightId;
        address challenger;
        bool isActive;
    }

    Fight[] public fights;
    mapping(uint256 => address) public fightOwner;

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

    function createFight(uint256 fightId) external {
        require(fights.length < maxAgonCount, "Max agon count reached");
        fights.push(Fight({fightId: fightId, challenger: msg.sender, isActive: true}));
        fightOwner[fightId] = msg.sender;
        IAgonFight(agonFightContractAddress).createFight(fightId, msg.sender);
    }

    function cancelFight(uint256 fightId) external {
        require(fightOwner[fightId] == msg.sender, "Only fight owner can cancel");
        IAgonFight(agonFightContractAddress).cancelFight(fightId);
        for (uint256 i = 0; i < fights.length; i++) {
            if (fights[i].fightId == fightId) {
                fights[i].isActive = false;
                break;
            }
        }
    }

    function challengeFight(uint256 fightId) external {
        require(fightOwner[fightId] != msg.sender, "Cannot challenge own fight");
        IAgonFight(agonFightContractAddress).challengeFight(fightId, msg.sender);
    }

    function resolveFight(uint256 fightId, address winner) external onlyAdmin {
        IAgonFight(agonFightContractAddress).resolveFight(fightId, winner);
        for (uint256 i = 0; i < fights.length; i++) {
            if (fights[i].fightId == fightId) {
                fights[i].isActive = false;
                break;
            }
        }
    }
}