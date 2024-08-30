pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 public maxSupply;
    uint256 public cost;

    string public baseTokenURI;
    string public baseTokenExtension;
    
    constructor(
        string memory name,
        string memory symbol,
        string memory _baseTokenURI, 
        string memory _baseTokenExtension,
        uint256 _cost, 
        uint256 _maxSupply
    ) ERC721(name, symbol) {
        baseTokenURI = _baseTokenURI;
        baseTokenExtension = _baseTokenExtension;
        cost = _cost;
        maxSupply = _maxSupply;
    }

    function mint(address to) public payable {
        require(msg.value >= cost, "Not enough Ether to mint the token.");
        require(_tokenIds.current() < maxSupply, "Max supply reached.");
        
        _tokenIds.increment();

        uint256 newTokenId = _tokenIds.current();
        _mint(to, newTokenId);
    }

    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function setBaseExtension(string memory _baseTokenExtension) public onlyOwner {
        baseTokenExtension = _baseTokenExtension;
    }

    function setCost(uint256 _cost) public onlyOwner {
        cost = _cost;
    }

    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        maxSupply = _maxSupply;
    }
    
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = baseTokenURI;
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), baseTokenExtension)) : "";
    }

}