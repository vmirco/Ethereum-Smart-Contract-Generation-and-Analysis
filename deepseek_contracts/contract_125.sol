// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PucieToken {
    string public name = "PucieToken";
    string public symbol = "PUC";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public feeExempt;

    address public taxRecipient;
    uint256 public taxRate; // Basis points (100 = 1%)

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event TaxRateUpdated(uint256 newTaxRate);
    event TaxRecipientUpdated(address newTaxRecipient);
    event FeeExemptionUpdated(address indexed account, bool isExempt);

    constructor(uint256 initialSupply, uint256 initialTaxRate, address initialTaxRecipient) {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        taxRate = initialTaxRate;
        taxRecipient = initialTaxRecipient;
        feeExempt[msg.sender] = true;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require(value <= allowance[from][msg.sender], "Allowance exceeded");
        allowance[from][msg.sender] -= value;
        _transfer(from, to, value);
        return true;
    }

    function updateTaxRate(uint256 newTaxRate) public {
        require(msg.sender == taxRecipient, "Only tax recipient can update tax rate");
        taxRate = newTaxRate;
        emit TaxRateUpdated(newTaxRate);
    }

    function updateTaxRecipient(address newTaxRecipient) public {
        require(msg.sender == taxRecipient, "Only tax recipient can update tax recipient");
        taxRecipient = newTaxRecipient;
        emit TaxRecipientUpdated(newTaxRecipient);
    }

    function updateFeeExemption(address account, bool isExempt) public {
        require(msg.sender == taxRecipient, "Only tax recipient can update fee exemption");
        feeExempt[account] = isExempt;
        emit FeeExemptionUpdated(account, isExempt);
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "Cannot transfer to the zero address");
        require(balanceOf[from] >= value, "Insufficient balance");

        uint256 taxAmount = feeExempt[from] ? 0 : (value * taxRate) / 10000;
        uint256 transferAmount = value - taxAmount;

        balanceOf[from] -= value;
        balanceOf[to] += transferAmount;
        balanceOf[taxRecipient] += taxAmount;

        emit Transfer(from, to, transferAmount);
        emit Transfer(from, taxRecipient, taxAmount);
    }
}