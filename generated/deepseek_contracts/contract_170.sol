// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PlayerRegistry {
    using SafeMath for uint256;

    struct Player {
        string name;
        address referrer;
        uint256 referralCount;
        uint256 balance;
    }

    mapping(address => Player) public players;
    mapping(string => address) public nameToAddress;
    address public owner;
    uint256 public registrationFee;

    event PlayerRegistered(address indexed player, string name, address referrer);
    event ReferralAdded(address indexed player, address indexed referrer);

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
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(nameToAddress[_name] == address(0), "Name already registered");

        _name = _filterName(_name);
        require(bytes(_name).length > 0, "Invalid name");

        Player storage player = players[msg.sender];
        require(bytes(player.name).length == 0, "Player already registered");

        player.name = _name;
        player.referrer = _referrer;
        nameToAddress[_name] = msg.sender;

        if (_referrer != address(0)) {
            Player storage referrerPlayer = players[_referrer];
            referrerPlayer.referralCount = referrerPlayer.referralCount.add(1);
            referrerPlayer.balance = referrerPlayer.balance.add(msg.value.div(10)); // 10% referral bonus
            emit ReferralAdded(msg.sender, _referrer);
        }

        emit PlayerRegistered(msg.sender, _name, _referrer);
    }

    function _filterName(string memory _name) internal pure returns (string memory) {
        bytes memory nameBytes = bytes(_name);
        bytes memory result = new bytes(nameBytes.length);
        uint256 resultLength = 0;

        for (uint256 i = 0; i < nameBytes.length; i++) {
            if (nameBytes[i] >= 0x41 && nameBytes[i] <= 0x5A) { // A-Z
                result[resultLength++] = nameBytes[i] + 0x20; // Convert to lowercase
            } else if (nameBytes[i] >= 0x61 && nameBytes[i] <= 0x7A) { // a-z
                result[resultLength++] = nameBytes[i];
            }
        }

        return string(result);
    }

    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function setRegistrationFee(uint256 _newFee) public onlyOwner {
        registrationFee = _newFee;
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
}