// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC721Basic {
    // Events
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    
    // Functions
    function totalSupply() public view returns (uint256 _totalSupply);
    function balanceOf(address _owner) public view returns (uint256 _balance);
    function ownerOf(uint256 _tokenId) public view returns (address _owner);
    function approve(address _to, uint256 _tokenId) public;
    function getApproved(uint256 _tokenId) public view returns (address _operator);
    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public;
}

contract ERC721TokenReceiver {
    // Events
    event Received(operator, from, tokenId, data);
    
    // Functions
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) public returns(bytes4);
}

contract ERC721BasicToken is ERC721Basic {
    uint256 internal totalTokenSupply;
    mapping(address => uint256) internal balances;
    mapping(uint256 => address) internal tokenOwners;
    mapping(uint256 => address) internal tokenApprovals;

    function mint(address _to) public {
        uint256 newTokenId = totalTokenSupply;
        totalTokenSupply++;
        balances[_to]++;
        tokenOwners[newTokenId] = _to;
        emit Transfer(address(0), _to, newTokenId);
    }

    function totalSupply() public view override returns (uint256) {
        return totalTokenSupply;
    }

    function balanceOf(address _owner) public view override returns (uint256) {
        return balances[_owner];
    }

    function ownerOf(uint256 _tokenId) public view override returns (address) {
        return tokenOwners[_tokenId];
    }

    function approve(address _to, uint256 _tokenId) public override {
        tokenApprovals[_tokenId] = _to;
    }

    function getApproved(uint256 _tokenId) public view override returns (address) {
        return tokenApprovals[_tokenId];
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public override {
        require(tokenOwners[_tokenId] == _from, "Function called for unowned token.");
        require(_to != address(0), "0x0 address not permitted for transfer.");
    
        tokenOwners[_tokenId] = _to;
        balances[_from]--;
        balances[_to]++;
        emit Transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public override {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public override {
        transferFrom(_from, _to, _tokenId);

        if (isContract(_to)) {
            bytes4 response = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
            require(response == bytes4(0x150b7a02), "Transfer to non ERC721Receiver contract.");
        }
    }

    function isContract(address _address) private view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(_address) }
        return size > 0;
    }
}

contract ERC721Receiver is ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data) public override
        returns(bytes4) {
        emit Received(_operator, _from, _tokenId, _data);
        return this.onERC721Received.selector;
    }
}