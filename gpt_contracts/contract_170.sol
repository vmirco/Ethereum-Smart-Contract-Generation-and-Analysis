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
}

library NameFilter {
    
    function nameFilter (string calldata _input) internal pure returns (string memory _output) {
        bytes memory _temp = bytes(_input);
        require(_temp.length <= 15, "Name too long");
        for(uint i = 0; i<_temp.length; i++) {
            require(_temp[i] >= 'a' && _temp[i] <= 'z', "Invalid Characters!");
        }
        return _input;
    }
    
}

contract PlayerContract {

    using SafeMath for uint256;
    struct Player {
        address walletAddress;
        string name;
        uint256 referralCount;
    }

    mapping(address => Player) public players;
    mapping(string => bool) private nameExists;
    
    address public admin;
    uint256 public nameRegistrationFee;

    event PlayerRegistered(address indexed playerAddress, string playerName);

    constructor(uint256 _nameRegistrationFee) {
        require(_nameRegistrationFee > 0, "Registration fee should be more than 0");
        admin = msg.sender;
        nameRegistrationFee = _nameRegistrationFee;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == admin, 'Admin access required');
        _;
    }

    function registerPlayer(string calldata _name) external payable {
        require(msg.value == nameRegistrationFee, "Registration fee required");
        _name = NameFilter.nameFilter(_name);
        require(!nameExists[_name], "Name already exists");
        
        players[msg.sender] = Player(msg.sender, _name, 0);
        nameExists[_name] = true;

        emit PlayerRegistered(msg.sender, _name);
    }

    function increasePlayerReferralCount(address _player) external onlyAdmin {
        players[_player].referralCount = players[_player].referralCount.add(1);
    }

    function updateRegistrationFee(uint256 _newFee) external onlyAdmin {
        nameRegistrationFee = _newFee;
    }

}