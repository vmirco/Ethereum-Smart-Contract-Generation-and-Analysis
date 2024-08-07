// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ARMORCrowdsale {
    string public name = "ARMOR Token";
    string public symbol = "ARMOR";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public owner;
    uint256 public publicSalePercentage = 90;
    uint256 public ownerPercentage = 10;
    uint256 public publicSaleTokens;
    uint256 public ownerTokens;
    uint256 public tokensSold;
    uint256 public rate; // tokens per ether

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
    event Buy(address indexed buyer, uint256 tokens);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(uint256 _totalSupply, uint256 _rate) {
        totalSupply = _totalSupply * 10 ** uint256(decimals);
        publicSaleTokens = (totalSupply * publicSalePercentage) / 100;
        ownerTokens = (totalSupply * ownerPercentage) / 100;
        rate = _rate;
        owner = msg.sender;
        balances[owner] = ownerTokens;
        emit Transfer(address(0), owner, ownerTokens);
    }

    function buyTokens() public payable {
        require(msg.value > 0, "Ether sent must be greater than 0");
        uint256 tokens = msg.value * rate;
        require(tokensSold + tokens <= publicSaleTokens, "Not enough tokens left for sale");

        balances[msg.sender] += tokens;
        tokensSold += tokens;
        emit Transfer(address(0), msg.sender, tokens);
        emit Buy(msg.sender, tokens);
    }

    function approve(address delegate, uint256 numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function transfer(address receiver, uint256 numTokens) public returns (bool) {
        require(numTokens <= balances[msg.sender], "Not enough tokens");
        balances[msg.sender] -= numTokens;
        balances[receiver] += numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public returns (bool) {
        require(numTokens <= balances[owner], "Not enough tokens");
        require(numTokens <= allowed[owner][msg.sender], "Allowance too low");

        balances[owner] -= numTokens;
        allowed[owner][msg.sender] -= numTokens;
        balances[buyer] += numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }

    function withdrawFunds() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function kill() public onlyOwner {
        selfdestruct(payable(owner));
    }
}