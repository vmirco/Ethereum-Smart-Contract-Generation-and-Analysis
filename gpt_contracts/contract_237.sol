// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract BananaNFT is ERC721, Ownable, Pausable {
    uint256 public bananaPrice = 0.05 ether;
    uint256 public maxPurchase = 20;
    uint256 public MAX_BANANAS = 10000;
    bool public saleIsActive = false;
    mapping(address => bool) public whitelistAddresses;

    constructor() ERC721("SuperBanana", "BNN") {}

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    function mintBanana(address _to, uint256 _count) public payable whenNotPaused {
        uint256 total = totalSupply();
        require(total + _count <= MAX_BANANAS, "Max limit");
        require(total <= MAX_BANANAS, "Sale end");
        require(_count <= maxPurchase, "Exceeds maxPurchase");
        require(bananaPrice * _count <= msg.value, "Value below price");

        for(uint256 i = 0; i < _count; i++){
            _safeMint(_to, total + i);
        }
    }

    function whitelistMintBanana(address _to, uint256 _count) public payable whenNotPaused {
        require(whitelistAddresses[msg.sender], "You are not on the whitelist");
        uint256 total = totalSupply();
        require(total + _count <= MAX_BANANAS, "Max limit");
        require(total <= MAX_BANANAS, "Sale end");
        require(_count <= maxPurchase, "Exceeds maxPurchase");
        require(bananaPrice * _count <= msg.value, "Value below price");

        for(uint256 i = 0; i < _count; i++){
            _safeMint(_to, total + i);
        }
    }

    function setSaleState(bool _value) public onlyOwner {
        saleIsActive = _value;
        if(_value == false){
            _pause();
        } else {
            _unpause();
        }
    }
    
    function setBananaPrice(uint256 _newPrice) public onlyOwner {
        bananaPrice = _newPrice;
    }

    function setMaxPurchase(uint256 _newMaxPurchase) public onlyOwner {
        maxPurchase = _newMaxPurchase;
    }

    function setMaxBananas(uint256 _newMaxBananas) public onlyOwner {
        MAX_BANANAS = _newMaxBananas;
    }
    
    function setWhitelistAddress(address _address, bool _whitelist) public onlyOwner {
        whitelistAddresses[_address] = _whitelist;
    }
    
    function checkIfClaimed(uint256 _tokenId) public view returns (bool) {
        return _exists(_tokenId);
    }

    function burn(uint256 _tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "Caller is not owner nor approved");
        _burn(_tokenId);
    }
}