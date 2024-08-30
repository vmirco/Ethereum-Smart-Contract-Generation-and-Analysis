// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenContract {
    string public name = "MyToken";
    string public symbol = "MTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(uint256 => string) public tokenMetadata;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event MetadataUpdate(uint256 indexed tokenId, string metadata);

    function mint(address to, uint256 value, string memory metadata) public returns (bool) {
        require(to != address(0), "Invalid address");
        totalSupply += value;
        balanceOf[to] += value;
        tokenMetadata[totalSupply] = metadata;
        emit Transfer(address(0), to, value);
        emit MetadataUpdate(totalSupply, metadata);
        return true;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function updateMetadata(uint256 tokenId, string memory metadata) public returns (bool) {
        require(balanceOf[msg.sender] >= tokenId, "Token not owned by sender");
        tokenMetadata[tokenId] = metadata;
        emit MetadataUpdate(tokenId, metadata);
        return true;
    }
}