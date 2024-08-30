// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC721 {
    using SafeMath for uint256;
    using AddressUtils for address;

    mapping (uint256 => address) private _tokenOwner;
    mapping (address => uint256) private _ownedTokensCount;
    mapping (uint256 => address) private _tokenApprovals;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    modifier onlyOwnerOf(uint256 _tokenId) {
        require(_tokenOwner[_tokenId] == msg.sender, "Not the owner of the token");
        _;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0), "Owner query for non-existent token");
        return _ownedTokensCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = _tokenOwner[_tokenId];
        require(owner != address(0), "Owner query for non-existent token");
        return owner;
    }

    function exists(uint256 _tokenId) public view returns (bool) {
        return _tokenOwner[_tokenId] != address(0);
    }

    function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        _tokenApprovals[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
    }

    function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        require(_to != address(0), "Transfer to the zero address");
        clearApproval(msg.sender, _tokenId);
        removeTokenFrom(msg.sender, _tokenId);
        addTokenTo(_to, _tokenId);
        emit Transfer(msg.sender, _to, _tokenId);
    }

    function clearApproval(address _owner, uint256 _tokenId) internal {
        require(_tokenOwner[_tokenId] == _owner, "Not the owner of the token");
        if (_tokenApprovals[_tokenId] != address(0)) {
            _tokenApprovals[_tokenId] = address(0);
        }
    }

    function removeTokenFrom(address _from, uint256 _tokenId) internal {
        require(_tokenOwner[_tokenId] == _from, "Not the owner of the token");
        _ownedTokensCount[_from] = _ownedTokensCount[_from].sub(1);
        _tokenOwner[_tokenId] = address(0);
    }

    function addTokenTo(address _to, uint256 _tokenId) internal {
        require(_tokenOwner[_tokenId] == address(0), "Token already has an owner");
        _tokenOwner[_tokenId] = _to;
        _ownedTokensCount[_to] = _ownedTokensCount[_to].add(1);
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
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