// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC20Token {
    string public name = "MyToken";
    string public symbol = "MTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    address public feeRecipient;
    uint256 public transferFeePercentage;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event FeeRecipientSet(address indexed newFeeRecipient);
    event TransferFeePercentageSet(uint256 newTransferFeePercentage);

    constructor(uint256 initialSupply, address _feeRecipient, uint256 _transferFeePercentage) {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        feeRecipient = _feeRecipient;
        transferFeePercentage = _transferFeePercentage;
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        uint256 fee = (value * transferFeePercentage) / 100;
        uint256 transferAmount = value - fee;

        balanceOf[msg.sender] -= value;
        balanceOf[to] += transferAmount;
        balanceOf[feeRecipient] += fee;

        emit Transfer(msg.sender, to, transferAmount);
        emit Transfer(msg.sender, feeRecipient, fee);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require(value <= balanceOf[from], "Insufficient balance");
        require(value <= allowance[from][msg.sender], "Allowance exceeded");

        uint256 fee = (value * transferFeePercentage) / 100;
        uint256 transferAmount = value - fee;

        balanceOf[from] -= value;
        balanceOf[to] += transferAmount;
        balanceOf[feeRecipient] += fee;

        allowance[from][msg.sender] -= value;

        emit Transfer(from, to, transferAmount);
        emit Transfer(from, feeRecipient, fee);
        return true;
    }

    function setFeeRecipient(address newFeeRecipient) public {
        require(msg.sender == feeRecipient, "Only fee recipient can set new fee recipient");
        feeRecipient = newFeeRecipient;
        emit FeeRecipientSet(newFeeRecipient);
    }

    function setTransferFeePercentage(uint256 newTransferFeePercentage) public {
        require(msg.sender == feeRecipient, "Only fee recipient can set transfer fee percentage");
        transferFeePercentage = newTransferFeePercentage;
        emit TransferFeePercentageSet(newTransferFeePercentage);
    }
}