// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MintableToken {
    string public name = "MintableToken";
    string public symbol = "MTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public owner;
    bool public mintingStopped = false;
    bool public transferAllowed = false;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public lastTransferTimestamp;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event MintingStopped(address indexed owner);
    event MintingStarted(address indexed owner);
    event TransferAllowed(address indexed owner);
    event TransferDisallowed(address indexed owner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function startMinting() external onlyOwner {
        mintingStopped = false;
        emit MintingStarted(msg.sender);
    }

    function stopMinting() external onlyOwner {
        mintingStopped = true;
        emit MintingStopped(msg.sender);
    }

    function allowTransfer() external onlyOwner {
        transferAllowed = true;
        emit TransferAllowed(msg.sender);
    }

    function disallowTransfer() external onlyOwner {
        transferAllowed = false;
        emit TransferDisallowed(msg.sender);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        require(!mintingStopped, "Minting is stopped");
        _mint(to, amount);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(transferAllowed, "Transfer is not allowed");
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(transferAllowed, "Transfer is not allowed");
        require(allowance[from][msg.sender] >= amount, "Allowance exceeded");
        allowance[from][msg.sender] -= amount;
        _transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function _mint(address to, uint256 amount) internal {
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(balanceOf[from] >= amount, "Insufficient balance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        lastTransferTimestamp[from] = block.timestamp;
        emit Transfer(from, to, amount);
    }
}