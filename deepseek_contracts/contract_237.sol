// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BananaNFT {
    address public owner;
    bool public salesPaused;
    uint256 public totalSupply;
    uint256 public maxSupply;
    uint256 public whitelistMintLimit;
    uint256 public publicMintLimit;
    mapping(address => bool) public whitelist;
    mapping(address => uint256) public mintedCount;
    mapping(uint256 => address) public nftOwners;
    address public superBananaAddress;

    event NFTMinted(address indexed owner, uint256 tokenId);
    event NFTRedeemed(address indexed owner, uint256 tokenId);
    event SalesPaused();
    event SalesResumed();
    event FundsWithdrawn(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier whenSalesNotPaused() {
        require(!salesPaused, "Sales are paused");
        _;
    }

    constructor(uint256 _maxSupply, uint256 _whitelistMintLimit, uint256 _publicMintLimit) {
        owner = msg.sender;
        maxSupply = _maxSupply;
        whitelistMintLimit = _whitelistMintLimit;
        publicMintLimit = _publicMintLimit;
        salesPaused = false;
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

    function mintNFT(uint256 _quantity) external payable whenSalesNotPaused {
        require(totalSupply + _quantity <= maxSupply, "Exceeds max supply");
        if (whitelist[msg.sender]) {
            require(mintedCount[msg.sender] + _quantity <= whitelistMintLimit, "Whitelist mint limit exceeded");
        } else {
            require(mintedCount[msg.sender] + _quantity <= publicMintLimit, "Public mint limit exceeded");
        }

        for (uint256 i = 0; i < _quantity; i++) {
            uint256 tokenId = totalSupply + 1;
            nftOwners[tokenId] = msg.sender;
            emit NFTMinted(msg.sender, tokenId);
            totalSupply++;
        }
        mintedCount[msg.sender] += _quantity;
    }

    function redeemNFT(uint256 _tokenId) external {
        require(nftOwners[_tokenId] == msg.sender, "Not the owner of the NFT");
        delete nftOwners[_tokenId];
        emit NFTRedeemed(msg.sender, _tokenId);
    }

    function pauseSales() external onlyOwner {
        salesPaused = true;
        emit SalesPaused();
    }

    function resumeSales() external onlyOwner {
        salesPaused = false;
        emit SalesResumed();
    }

    function withdrawFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
        emit FundsWithdrawn(balance);
    }

    function setSuperBananaAddress(address _newAddress) external onlyOwner {
        superBananaAddress = _newAddress;
    }

    function checkClaimedBananas(address _user) external view returns (uint256) {
        return mintedCount[_user];
    }

    function burnNFT(uint256 _tokenId) external {
        require(nftOwners[_tokenId] == msg.sender || msg.sender == superBananaAddress, "Not authorized to burn");
        delete nftOwners[_tokenId];
        emit NFTRedeemed(msg.sender, _tokenId);
    }
}