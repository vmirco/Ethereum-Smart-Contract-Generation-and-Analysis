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
    mapping(address => uint256) public donationSteps;

    address public admin;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Donation(address indexed donor, uint256 amount, uint256 step);
    event Write(address indexed writer, string text);

    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyWriter() {
        require(writers[msg.sender], "Only writers can perform this action");
        _;
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
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function setWriter(address _writer, bool _status) public onlyAdmin {
        writers[_writer] = _status;
    }

    function setCountryCode(address _user, string memory _code) public onlyAdmin {
        countryCodes[_user] = _code;
    }

    function donate(uint256 _step) public payable {
        require(_step > 0, "Invalid donation step");
        uint256[] memory prices = [0.1 ether, 0.5 ether, 1 ether];
        require(msg.value == prices[_step - 1], "Incorrect donation amount");
        donationSteps[msg.sender] = _step;
        emit Donation(msg.sender, msg.value, _step);
    }

    function write(string memory _text) public onlyWriter {
        emit Write(msg.sender, _text);
    }
}