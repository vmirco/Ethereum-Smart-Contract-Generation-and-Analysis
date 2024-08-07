// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC721 {
    using SafeMath for uint256;
    using AddressUtils for address;

    mapping(uint256 => address) private _tokenOwner;
    mapping(address => uint256) private _ownedTokensCount;
    mapping(uint256 => address) private _tokenApprovals;

    modifier onlyOwnerOf(uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender, "Not the owner of the token");
        _;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0), "Owner query for the zero address");
        return _ownedTokensCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = _tokenOwner[_tokenId];
        require(owner != address(0), "Owner query for nonexistent token");
        return owner;
    }

    function exists(uint256 _tokenId) public view returns (bool) {
        return _tokenOwner[_tokenId] != address(0);
    }

    function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        _tokenApprovals[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public {
        require(_from != address(0), "Transfer from the zero address");
        require(_to != address(0), "Transfer to the zero address");
        require(_from == msg.sender || _tokenApprovals[_tokenId] == msg.sender, "Not approved to transfer");
        require(ownerOf(_tokenId) == _from, "From address is not the owner");

        _ownedTokensCount[_from] = _ownedTokensCount[_from].sub(1);
        _ownedTokensCount[_to] = _ownedTokensCount[_to].add(1);
        _tokenOwner[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
}

library AddressUtils {
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}