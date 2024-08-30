// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TalentumToken {
    string public name = "Talentum Token";
    string public symbol = "TTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public writers;
    mapping(address => string) public countryCodes;

    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event WriterSet(address indexed writer, bool status);
    event CountryCodeSet(address indexed user, string code);
    event Donation(address indexed donor, uint256 amount, uint256 step);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyWriter() {
        require(writers[msg.sender], "Not a writer");
        _;
    }

    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        mint(owner, _initialSupply);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Allowance too low");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function mint(address _to, uint256 _value) public onlyOwner {
        totalSupply += _value;
        balanceOf[_to] += _value;
        emit Transfer(address(0), _to, _value);
    }

    function setWriter(address _writer, bool _status) public onlyOwner {
        writers[_writer] = _status;
        emit WriterSet(_writer, _status);
    }

    function setCountryCode(address _user, string memory _code) public onlyOwner {
        countryCodes[_user] = _code;
        emit CountryCodeSet(_user, _code);
    }

    function donate(uint256 _step) public payable {
        require(_step > 0, "Invalid step");
        uint256 amount;
        if (_step == 1) {
            amount = 0.1 ether;
        } else if (_step == 2) {
            amount = 1 ether;
        } else if (_step == 3) {
            amount = 10 ether;
        } else {
            revert("Invalid donation step");
        }
        require(msg.value >= amount, "Insufficient donation amount");
        // Handle the donation, e.g., transfer to a donation wallet
        emit Donation(msg.sender, msg.value, _step);
    }
}