// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC20Token {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    address public feeRecipient;
    uint256 public transferFeePercentage;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event FeeRecipientSet(address indexed newFeeRecipient);
    event TransferFeePercentageSet(uint256 newTransferFeePercentage);

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply,
        address _feeRecipient,
        uint256 _transferFeePercentage
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply * 10**uint256(_decimals);
        balanceOf[msg.sender] = totalSupply;
        feeRecipient = _feeRecipient;
        transferFeePercentage = _transferFeePercentage;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(allowance[_from][msg.sender] >= _value, "Insufficient allowance");
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function setFeeRecipient(address _newFeeRecipient) public {
        require(msg.sender == feeRecipient, "Only fee recipient can set new fee recipient");
        feeRecipient = _newFeeRecipient;
        emit FeeRecipientSet(_newFeeRecipient);
    }

    function setTransferFeePercentage(uint256 _newTransferFeePercentage) public {
        require(msg.sender == feeRecipient, "Only fee recipient can set transfer fee percentage");
        require(_newTransferFeePercentage <= 100, "Fee percentage must be <= 100");
        transferFeePercentage = _newTransferFeePercentage;
        emit TransferFeePercentageSet(_newTransferFeePercentage);
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0), "Cannot transfer to the zero address");
        require(balanceOf[_from] >= _value, "Insufficient balance");

        uint256 fee = (_value * transferFeePercentage) / 100;
        uint256 amountAfterFee = _value - fee;

        balanceOf[_from] -= _value;
        balanceOf[_to] += amountAfterFee;
        balanceOf[feeRecipient] += fee;

        emit Transfer(_from, _to, amountAfterFee);
        emit Transfer(_from, feeRecipient, fee);
    }
}