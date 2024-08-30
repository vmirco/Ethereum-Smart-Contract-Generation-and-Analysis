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
    mapping(address => uint256) public lastMove;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed to, uint256 value);
    event MintingStopped(address indexed by);
    event MintingStarted(address indexed by);
    event TransferAllowed(address indexed by);
    event TransferDisallowed(address indexed by);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function mint(address _to, uint256 _amount) external onlyOwner {
        require(!mintingStopped, "Minting is stopped");
        totalSupply += _amount;
        balanceOf[_to] += _amount;
        lastMove[_to] = block.timestamp;
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
    }

    function stopMinting() external onlyOwner {
        mintingStopped = true;
        emit MintingStopped(msg.sender);
    }

    function startMinting() external onlyOwner {
        mintingStopped = false;
        emit MintingStarted(msg.sender);
    }

    function allowTransfer() external onlyOwner {
        transferAllowed = true;
        emit TransferAllowed(msg.sender);
    }

    function disallowTransfer() external onlyOwner {
        transferAllowed = false;
        emit TransferDisallowed(msg.sender);
    }

    function transfer(address _to, uint256 _amount) external {
        require(transferAllowed, "Transfers are not allowed");
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance");
        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;
        lastMove[msg.sender] = block.timestamp;
        lastMove[_to] = block.timestamp;
        emit Transfer(msg.sender, _to, _amount);
    }
}