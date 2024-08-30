// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UniqueTokens {
    using SafeMath for uint256;

    struct Token {
        uint256 id;
        address creator;
        string metadata;
        uint256 price;
        bool isForSale;
        uint256 royaltyPercentage;
    }

    uint256 public tokenCounter;
    mapping(uint256 => Token) public tokens;
    mapping(uint256 => address) public tokenOwner;
    mapping(address => uint256) public ownerTokenCount;

    event TokenMinted(uint256 indexed tokenId, address indexed creator, string metadata);
    event TokenPriceSet(uint256 indexed tokenId, uint256 price);
    event TokenSold(uint256 indexed tokenId, address indexed buyer, uint256 price);

    modifier onlyTokenOwner(uint256 _tokenId) {
        require(tokenOwner[_tokenId] == msg.sender, "Not the owner of the token");
        _;
    }

    function mintToken(string memory _metadata, uint256 _royaltyPercentage) public {
        tokenCounter = tokenCounter.add(1);
        uint256 newTokenId = tokenCounter;
        Token memory newToken = Token({
            id: newTokenId,
            creator: msg.sender,
            metadata: _metadata,
            price: 0,
            isForSale: false,
            royaltyPercentage: _royaltyPercentage
        });
        tokens[newTokenId] = newToken;
        tokenOwner[newTokenId] = msg.sender;
        ownerTokenCount[msg.sender] = ownerTokenCount[msg.sender].add(1);
        emit TokenMinted(newTokenId, msg.sender, _metadata);
    }

    function setTokenPrice(uint256 _tokenId, uint256 _price) public onlyTokenOwner(_tokenId) {
        tokens[_tokenId].price = _price;
        tokens[_tokenId].isForSale = true;
        emit TokenPriceSet(_tokenId, _price);
    }

    function buyToken(uint256 _tokenId) public payable {
        Token storage token = tokens[_tokenId];
        require(token.isForSale, "Token is not for sale");
        require(msg.value >= token.price, "Insufficient payment");

        address previousOwner = tokenOwner[_tokenId];
        uint256 royaltyAmount = msg.value.mul(token.royaltyPercentage).div(100);
        uint256 sellerAmount = msg.value.sub(royaltyAmount);

        payable(token.creator).transfer(royaltyAmount);
        payable(previousOwner).transfer(sellerAmount);

        tokenOwner[_tokenId] = msg.sender;
        ownerTokenCount[previousOwner] = ownerTokenCount[previousOwner].sub(1);
        ownerTokenCount[msg.sender] = ownerTokenCount[msg.sender].add(1);

        token.isForSale = false;
        emit TokenSold(_tokenId, msg.sender, msg.value);
    }

    function SafeMath() internal pure returns (uint256) {
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
}