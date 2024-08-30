pragma solidity ^0.8.0;

contract ERC721 {
    string public name;
    string public symbol;

    mapping(address => uint) private _balances;
    mapping(uint => address) private _owners;
    mapping(uint => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    uint private _totalSupply;

    event Transfer(address indexed from, address indexed to, uint indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint indexed tokenId);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function balanceOf(address owner) public view returns (uint balance) {
        return _balances[owner];
    }

    function ownerOf(uint tokenId) public view returns (address owner) {
        return _owners[tokenId];
    }

    function approve(address to, uint tokenId) public {
        require(ownerOf(tokenId) == msg.sender);
        _tokenApprovals[tokenId] = to;
        emit Approval(msg.sender, to, tokenId);
    }

    function getApproved(uint tokenId) public view returns (address operator) {
        return _tokenApprovals[tokenId];
    }

    function transferFrom(address from, address to, uint tokenId) public {
        require(to != address(0));
        require(ownerOf(tokenId) == from);
        require(msg.sender == from || getApproved(tokenId) == msg.sender);
        
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    function mint(address to, uint tokenId) public {
        _balances[to] += 1;
        _owners[tokenId] = to;
        _totalSupply += 1;
        emit Transfer(address(0), to, tokenId);
    }

    function totalSupply() public view returns (uint total) {
        return _totalSupply;
    }
}