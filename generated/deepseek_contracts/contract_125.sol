// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISwapper {
    function swap(address tokenIn, address tokenOut, uint256 amountIn) external returns (uint256 amountOut);
}

contract PucieToken {
    string public name = "PucieToken";
    string public symbol = "PUC";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public taxRecipient;
    uint256 public taxRate; // in basis points (10000 = 100%)

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public feeExempt;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event TaxRateUpdated(uint256 newRate);
    event TaxRecipientUpdated(address newRecipient);
    event FeeExemptionSet(address indexed account, bool exempt);

    constructor(uint256 initialSupply, address _taxRecipient, uint256 _taxRate) {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        taxRecipient = _taxRecipient;
        taxRate = _taxRate;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(allowance[from][msg.sender] >= value, "Insufficient allowance");
        allowance[from][msg.sender] -= value;
        _transfer(from, to, value);
        return true;
    }

    function setTaxRate(uint256 newRate) external {
        require(msg.sender == taxRecipient, "Only tax recipient can update tax rate");
        taxRate = newRate;
        emit TaxRateUpdated(newRate);
    }

    function setTaxRecipient(address newRecipient) external {
        require(msg.sender == taxRecipient, "Only tax recipient can update tax recipient");
        taxRecipient = newRecipient;
        emit TaxRecipientUpdated(newRecipient);
    }

    function setFeeExemption(address account, bool exempt) external {
        require(msg.sender == taxRecipient, "Only tax recipient can set fee exemption");
        feeExempt[account] = exempt;
        emit FeeExemptionSet(account, exempt);
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(balanceOf[from] >= value, "Insufficient balance");
        uint256 taxAmount = feeExempt[from] ? 0 : (value * taxRate) / 10000;
        uint256 transferAmount = value - taxAmount;

        balanceOf[from] -= value;
        balanceOf[to] += transferAmount;
        balanceOf[taxRecipient] += taxAmount;

        emit Transfer(from, to, transferAmount);
        emit Transfer(from, taxRecipient, taxAmount);
    }

    function swapTokens(address tokenIn, address tokenOut, uint256 amountIn, ISwapper swapper) external returns (uint256 amountOut) {
        require(allowance[msg.sender][address(this)] >= amountIn, "Insufficient allowance");
        allowance[msg.sender][address(this)] -= amountIn;
        _transfer(msg.sender, address(this), amountIn);
        amountOut = swapper.swap(tokenIn, tokenOut, amountIn);
        _transfer(address(this), msg.sender, amountOut);
    }
}