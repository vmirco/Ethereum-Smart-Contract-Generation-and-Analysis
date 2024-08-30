// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PIVOTCHAIN {
    string public name = "PIVOTCHAIN";
    string public symbol = "PVT";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public buyPrice;
    address public owner;

    mapping(address => uint256) public balanceOf;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Contribution(address indexed contributor, uint256 value, uint256 tokensReceived);

    constructor(uint256 initialSupply, uint256 _buyPrice) {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        buyPrice = _buyPrice;
        owner = msg.sender;
    }

    function buyTokens() public payable {
        require(msg.value > 0, "Contribution must be greater than 0");
        uint256 tokensToBuy = msg.value * buyPrice;
        require(tokensToBuy <= balanceOf[owner], "Not enough tokens available for sale");
        balanceOf[owner] -= tokensToBuy;
        balanceOf[msg.sender] += tokensToBuy;
        emit Transfer(owner, msg.sender, tokensToBuy);
        emit Contribution(msg.sender, msg.value, tokensToBuy);
    }

    function sellTokens(uint256 tokenAmount) public {
        require(tokenAmount > 0, "Token amount must be greater than 0");
        require(balanceOf[msg.sender] >= tokenAmount, "Insufficient token balance");
        uint256 etherAmount = tokenAmount / buyPrice;
        require(address(this).balance >= etherAmount, "Not enough ether in the contract");
        balanceOf[msg.sender] -= tokenAmount;
        balanceOf[owner] += tokenAmount;
        payable(msg.sender).transfer(etherAmount);
        emit Transfer(msg.sender, owner, tokenAmount);
    }

    function withdrawEther(uint256 amount) public {
        require(msg.sender == owner, "Only owner can withdraw ether");
        require(amount <= address(this).balance, "Insufficient contract balance");
        payable(owner).transfer(amount);
    }

    receive() external payable {
        buyTokens();
    }
}