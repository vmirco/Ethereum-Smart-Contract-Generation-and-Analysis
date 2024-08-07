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
    event Contribution(address indexed contributor, uint256 value, uint256 tokens);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(uint256 initialSupply, uint256 _buyPrice) {
        owner = msg.sender;
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[owner] = totalSupply;
        buyPrice = _buyPrice;
        emit Transfer(address(0), owner, totalSupply);
    }

    function buyTokens() public payable {
        require(msg.value > 0, "Insufficient ether sent");
        uint256 tokensToBuy = msg.value * buyPrice;
        require(tokensToBuy <= balanceOf[owner], "Not enough tokens available for sale");
        balanceOf[owner] -= tokensToBuy;
        balanceOf[msg.sender] += tokensToBuy;
        emit Transfer(owner, msg.sender, tokensToBuy);
        emit Contribution(msg.sender, msg.value, tokensToBuy);
    }

    function sellTokens(uint256 tokenAmount) public {
        require(tokenAmount > 0, "Insufficient tokens to sell");
        require(balanceOf[msg.sender] >= tokenAmount, "Insufficient balance");
        uint256 etherToSend = tokenAmount / buyPrice;
        require(address(this).balance >= etherToSend, "Insufficient contract balance");
        balanceOf[msg.sender] -= tokenAmount;
        balanceOf[owner] += tokenAmount;
        payable(msg.sender).transfer(etherToSend);
        emit Transfer(msg.sender, owner, tokenAmount);
    }

    function withdrawEther() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {
        buyTokens();
    }
}