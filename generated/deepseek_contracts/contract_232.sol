// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UniqueToken {
    using SafeMath for uint256;

    struct Token {
        uint256 id;
        address creator;
        string metadata;
        uint256 price;
        bool isForSale;
        uint256 royalty;
    }

    Token[] public tokens;
    mapping(uint256 => address) public tokenOwners;
    mapping(address => uint256[]) public ownerTokens;
    uint256 public tokenCounter;

    event TokenMinted(uint256 indexed tokenId, address indexed creator, string metadata);
    event TokenPriceSet(uint256 indexed tokenId, uint256 price);
    event TokenSold(uint256 indexed tokenId, address indexed buyer, uint256 price);

    modifier onlyTokenOwner(uint256 _tokenId) {
        require(tokenOwners[_tokenId] == msg.sender, "Not the owner");
        _;
    }

    function mintToken(string memory _metadata, uint256 _price, uint256 _royalty) public {
        require(_royalty <= 10000, "Royalty too high");
        uint256 tokenId = tokenCounter++;
        Token memory newToken = Token({
            id: tokenId,
            creator: msg.sender,
            metadata: _metadata,
            price: _price,
            isForSale: true,
            royalty: _royalty
        });
        tokens.push(newToken);
        tokenOwners[tokenId] = msg.sender;
        ownerTokens[msg.sender].push(tokenId);
        emit TokenMinted(tokenId, msg.sender, _metadata);
    }

    function setTokenPrice(uint256 _tokenId, uint256 _price) public onlyTokenOwner(_tokenId) {
        tokens[_tokenId].price = _price;
        emit TokenPriceSet(_tokenId, _price);
    }

    function buyToken(uint256 _tokenId) public payable {
        Token storage token = tokens[_tokenId];
        require(token.isForSale, "Token not for sale");
        require(msg.value >= token.price, "Insufficient funds");

        address oldOwner = tokenOwners[_tokenId];
        tokenOwners[_tokenId] = msg.sender;
        ownerTokens[msg.sender].push(_tokenId);

        uint256 royaltyAmount = msg.value.mul(token.royalty).div(10000);
        uint256 remainingAmount = msg.value.sub(royaltyAmount);

        payable(token.creator).transfer(royaltyAmount);
        payable(oldOwner).transfer(remainingAmount);

        emit TokenSold(_tokenId, msg.sender, token.price);
    }

    function getTokensByOwner(address _owner) public view returns (uint256[] memory) {
        return ownerTokens[_owner];
    }
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

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}