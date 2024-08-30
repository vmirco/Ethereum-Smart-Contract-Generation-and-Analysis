// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Talentum {

    //Token details
    string public name = "TalentumToken";
    string public symbol = "TTK";
    uint256 public totalSupply = 1000000;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;

    // Structure for Bible Entry
    struct BibleEntry {
       string text;
       address writer;
    }

    BibleEntry[] public bibleEntries;
    mapping(address => bool) public writers;
    mapping(string => bool) public adminSetCountryCodes;
    mapping(address => uint256) public donatedAmount;

    uint256 donateStep1 = 50;
    uint256 donateStep2 = 100;
    uint256 donateStep3 = 500;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event BibleEntryAdded(uint256 id, address writer, string text);
    event DonationReceived(address from, uint256 amount);

    constructor() {
        balances[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value, 'Balance not sufficient');
        require(_to != address(0), 'Invalid address');

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), 'Invalid address');
        require(balances[msg.sender] >= _value, 'Balance not sufficient');

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), 'Invalid address');
        require(balances[_from] >= _value, 'Balance not sufficient');

        balances[_from] -= _value;
        balances[_to] += _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function writeBibleEntry(string memory _text) public returns (bool success) {
        require(writers[msg.sender], 'You are not allowed to write');
        bibleEntries.push(BibleEntry({text: _text, writer: msg.sender}));
        emit BibleEntryAdded(bibleEntries.length - 1, msg.sender, _text);
        return true;
    }

    function readBibleEntry(uint256 _id) public view returns (string memory text, address writer) {
        return (bibleEntries[_id].text, bibleEntries[_id].writer);
    }

    function setWriter(address _writer, bool _status) public returns (bool success) {
        writers[_writer] = _status;
        return true;
    }

    function setCountryCode(string memory _code, bool _status) public returns (bool success) {
        adminSetCountryCodes[_code] = _status;
        return true;
    }

    function donate(uint256 _amount) public returns (bool success) {
        require(balances[msg.sender] >= _amount, 'Balance not sufficient');
        require(_amount >= donateStep1, 'Minimum donation is 50 TTK');

        balances[msg.sender] -= _amount;
        balances[address(this)] += _amount;

        // Assigning tier status based on donation levels
        if(_amount >= donateStep3) {
            donatedAmount[msg.sender] = 3;
        }
        else if(_amount >= donateStep2) {
            donatedAmount[msg.sender] = 2;
        }
        else {
            donatedAmount[msg.sender] = 1;
        }

        emit DonationReceived(msg.sender, _amount);
        return true;
    }

}