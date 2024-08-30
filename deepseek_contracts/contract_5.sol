// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ArmorTokenCrowdsale {
    string public name = "Armor Token";
    string public symbol = "ARMOR";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public owner;
    uint256 public publicSaleAllocation;
    uint256 public ownerAllocation;
    uint256 public tokensSold;
    bool public isActive = true;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event TokensPurchased(address indexed buyer, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyWhenActive() {
        require(isActive, "Contract is not active");
        _;
    }

    constructor(uint256 _totalSupply) {
        totalSupply = _totalSupply;
        publicSaleAllocation = (_totalSupply * 90) / 100;
        ownerAllocation = (_totalSupply * 10) / 100;
        owner = msg.sender;
        balanceOf[owner] = ownerAllocation;
        emit Transfer(address(0), owner, ownerAllocation);
    }

    function buyTokens() public payable onlyWhenActive {
        require(msg.value > 0, "Ether amount must be greater than 0");
        uint256 tokensToBuy = msg.value * (publicSaleAllocation / address(this).balance);
        require(tokensSold + tokensToBuy <= publicSaleAllocation, "Not enough tokens left for sale");

        balanceOf[msg.sender] += tokensToBuy;
        tokensSold += tokensToBuy;
        emit TokensPurchased(msg.sender, tokensToBuy);
        emit Transfer(address(0), msg.sender, tokensToBuy);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Not enough balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(balanceOf[from] >= amount, "Not enough balance");
        require(allowance[from][msg.sender] >= amount, "Not enough allowance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function withdrawFunds() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function killContract() public onlyOwner {
        isActive = false;
        selfdestruct(payable(owner));
    }
}