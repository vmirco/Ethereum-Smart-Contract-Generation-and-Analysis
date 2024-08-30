// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721Enumerable, Ownable {
    uint256 public MAX_SUPPLY;
    uint256 public PRESALE_PRICE;
    uint256 public PUBLIC_PRICE;
    uint256 public PRESALE_MINT_LIMIT;
    uint256 public PUBLIC_MINT_LIMIT;
    bool public presaleIsActive = false;
    bool public publicSaleIsActive = false;

    constructor(
        string memory name,
        string memory symbol,
        uint256 maxSupply,
        uint256 presalePrice,
        uint256 publicPrice,
        uint256 presaleLimit,
        uint256 publicLimit
    ) ERC721(name, symbol) {
        MAX_SUPPLY = maxSupply;
        PRESALE_PRICE = presalePrice;
        PUBLIC_PRICE = publicPrice;
        PRESALE_MINT_LIMIT = presaleLimit;
        PUBLIC_MINT_LIMIT = publicLimit;
    }

    function mintPublic(uint256 num) public payable {
        uint256 supply = totalSupply();
        require(publicSaleIsActive, "Sale is not active currently");
        require(num < PUBLIC_MINT_LIMIT, "You can mint maximum PUBLIC_MINT_LIMIT");
        require(supply + num < MAX_SUPPLY, "Exceeds MAX_SUPPLY");
        require(msg.value >= PUBLIC_PRICE * num, "Ether value sent is below the price");

        for(uint256 i; i < num; i++){
            _safeMint(msg.sender, supply + i);
        }
    }

    function mintPresale(uint256 num) public payable {
        uint256 supply = totalSupply();
        require(presaleIsActive, "Presale is not active currently");
        require(num < PRESALE_MINT_LIMIT, "You can mint maximum PRESALE_MINT_LIMIT");
        require(supply + num < MAX_SUPPLY, "Exceeds MAX_SUPPLY");
        require(msg.value >= PRESALE_PRICE * num, "Ether value sent is below the price");

        for (uint256 i; i < num; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }
    
    function setPresaleIsActive(bool _presaleIsActive) public onlyOwner {
        presaleIsActive = _presaleIsActive;
    }
    
    function setPublicSaleIsActive(bool _publicSaleIsActive) public onlyOwner {
        publicSaleIsActive = _publicSaleIsActive;
    }

    function withdraw() public payable onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) 
        internal 
        override(ERC721Enumerable) 
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) 
        public 
        view 
        override(ERC721Enumerable) 
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}