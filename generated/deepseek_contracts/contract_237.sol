// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BananaNFT {
    address public owner;
    bool public paused;
    uint256 public totalSupply;
    uint256 public maxSupply;
    uint256 public whitelistPrice;
    uint256 public publicPrice;
    uint256 public maxMintPerAddress;
    address public superBananaAddress;

    mapping(address => bool) public whitelist;
    mapping(address => uint256) public mintedCount;
    mapping(uint256 => address) public tokenOwners;
    mapping(address => uint256) public ownedTokensCount;

    event Mint(address indexed to, uint256 tokenId);
    event Burn(uint256 tokenId);
    event Pause();
    event Unpause();
    event Withdraw(address indexed to, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    constructor(
        uint256 _maxSupply,
        uint256 _whitelistPrice,
        uint256 _publicPrice,
        uint256 _maxMintPerAddress,
        address _superBananaAddress
    ) {
        owner = msg.sender;
        maxSupply = _maxSupply;
        whitelistPrice = _whitelistPrice;
        publicPrice = _publicPrice;
        maxMintPerAddress = _maxMintPerAddress;
        superBananaAddress = _superBananaAddress;
    }

    function addToWhitelist(address[] memory _addresses) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            whitelist[_addresses[i]] = true;
        }
    }

    function removeFromWhitelist(address[] memory _addresses) external onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            whitelist[_addresses[i]] = false;
        }
    }

    function mintWhitelist() external payable whenNotPaused {
        require(whitelist[msg.sender], "Not whitelisted");
        require(mintedCount[msg.sender] < maxMintPerAddress, "Exceeded mint limit");
        require(msg.value >= whitelistPrice, "Insufficient funds");
        require(totalSupply < maxSupply, "Max supply reached");

        _mint(msg.sender);
    }

    function mintPublic() external payable whenNotPaused {
        require(mintedCount[msg.sender] < maxMintPerAddress, "Exceeded mint limit");
        require(msg.value >= publicPrice, "Insufficient funds");
        require(totalSupply < maxSupply, "Max supply reached");

        _mint(msg.sender);
    }

    function _mint(address _to) internal {
        uint256 tokenId = totalSupply + 1;
        totalSupply++;
        mintedCount[_to]++;
        tokenOwners[tokenId] = _to;
        ownedTokensCount[_to]++;
        emit Mint(_to, tokenId);
    }

    function burn(uint256 _tokenId) external {
        require(tokenOwners[_tokenId] == msg.sender, "Not the owner");
        ownedTokensCount[msg.sender]--;
        delete tokenOwners[_tokenId];
        emit Burn(_tokenId);
    }

    function pause() external onlyOwner {
        paused = true;
        emit Pause();
    }

    function unpause() external onlyOwner {
        paused = false;
        emit Unpause();
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
        emit Withdraw(owner, balance);
    }

    function isClaimed(address _address) external view returns (bool) {
        return mintedCount[_address] > 0;
    }
}