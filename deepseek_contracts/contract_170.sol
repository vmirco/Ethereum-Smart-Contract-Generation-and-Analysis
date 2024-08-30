// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PlayerRegistry {
    using SafeMath for uint256;

    struct Player {
        string name;
        address referrer;
        uint256 referralReward;
    }

    mapping(address => Player) public players;
    mapping(string => bool) public nameExists;
    address public owner;
    uint256 public registrationFee;

    event PlayerRegistered(address indexed player, string name, address referrer);
    event RewardAdded(address indexed player, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(uint256 _registrationFee) {
        owner = msg.sender;
        registrationFee = _registrationFee;
    }

    function registerName(string memory _name, address _referrer) public payable {
        require(msg.value == registrationFee, "Incorrect registration fee");
        require(!nameExists[toLower(_name)], "Name already exists");

        players[msg.sender] = Player({
            name: _name,
            referrer: _referrer,
            referralReward: 0
        });
        nameExists[toLower(_name)] = true;

        if (_referrer != address(0)) {
            players[_referrer].referralReward = players[_referrer].referralReward.add(msg.value.div(10));
            emit RewardAdded(_referrer, msg.value.div(10));
        }

        emit PlayerRegistered(msg.sender, _name, _referrer);
    }

    function addReward(address _player, uint256 _amount) public onlyOwner {
        players[_player].referralReward = players[_player].referralReward.add(_amount);
        emit RewardAdded(_player, _amount);
    }

    function withdrawReward() public {
        uint256 reward = players[msg.sender].referralReward;
        require(reward > 0, "No reward to withdraw");

        players[msg.sender].referralReward = 0;
        payable(msg.sender).transfer(reward);
    }

    function setRegistrationFee(uint256 _newFee) public onlyOwner {
        registrationFee = _newFee;
    }

    function toLower(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }
}

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}