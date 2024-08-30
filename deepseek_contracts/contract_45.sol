// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenMarket {
    struct Token {
        address tokenAddress;
        string symbol;
        uint8 decimals;
        uint256 totalSupply;
    }

    struct Trade {
        address trader;
        address tokenAddress;
        uint256 amount;
        uint256 price;
        bool isBuy;
    }

    mapping(address => Token) public tokens;
    address[] public tokenList;
    mapping(address => mapping(address => uint256)) public balances;
    Trade[] public trades;

    event TokenAdded(address indexed tokenAddress, string symbol, uint8 decimals, uint256 totalSupply);
    event TokenRemoved(address indexed tokenAddress);
    event TradeExecuted(address indexed trader, address indexed tokenAddress, uint256 amount, uint256 price, bool isBuy);

    modifier tokenExists(address _tokenAddress) {
        require(tokens[_tokenAddress].tokenAddress != address(0), "Token does not exist");
        _;
    }

    function addToken(address _tokenAddress, string memory _symbol, uint8 _decimals, uint256 _totalSupply) public {
        require(tokens[_tokenAddress].tokenAddress == address(0), "Token already exists");
        tokens[_tokenAddress] = Token(_tokenAddress, _symbol, _decimals, _totalSupply);
        tokenList.push(_tokenAddress);
        emit TokenAdded(_tokenAddress, _symbol, _decimals, _totalSupply);
    }

    function removeToken(address _tokenAddress) public tokenExists(_tokenAddress) {
        delete tokens[_tokenAddress];
        for (uint256 i = 0; i < tokenList.length; i++) {
            if (tokenList[i] == _tokenAddress) {
                tokenList[i] = tokenList[tokenList.length - 1];
                tokenList.pop();
                break;
            }
        }
        emit TokenRemoved(_tokenAddress);
    }

    function modifyToken(address _tokenAddress, string memory _symbol, uint8 _decimals, uint256 _totalSupply) public tokenExists(_tokenAddress) {
        tokens[_tokenAddress].symbol = _symbol;
        tokens[_tokenAddress].decimals = _decimals;
        tokens[_tokenAddress].totalSupply = _totalSupply;
    }

    function tradeToken(address _tokenAddress, uint256 _amount, uint256 _price, bool _isBuy) public tokenExists(_tokenAddress) {
        require(_amount > 0, "Amount must be greater than 0");
        require(_price > 0, "Price must be greater than 0");

        if (_isBuy) {
            require(balances[msg.sender][_tokenAddress] >= _amount * _price, "Insufficient balance");
            balances[msg.sender][_tokenAddress] -= _amount * _price;
        } else {
            require(balances[msg.sender][_tokenAddress] >= _amount, "Insufficient token balance");
            balances[msg.sender][_tokenAddress] -= _amount;
        }

        trades.push(Trade(msg.sender, _tokenAddress, _amount, _price, _isBuy));
        emit TradeExecuted(msg.sender, _tokenAddress, _amount, _price, _isBuy);
    }

    function deposit(address _tokenAddress, uint256 _amount) public tokenExists(_tokenAddress) {
        require(_amount > 0, "Amount must be greater than 0");
        balances[msg.sender][_tokenAddress] += _amount;
    }

    function withdraw(address _tokenAddress, uint256 _amount) public tokenExists(_tokenAddress) {
        require(_amount > 0, "Amount must be greater than 0");
        require(balances[msg.sender][_tokenAddress] >= _amount, "Insufficient balance");
        balances[msg.sender][_tokenAddress] -= _amount;
    }

    function getTokenList() public view returns (address[] memory) {
        return tokenList;
    }

    function getTrades() public view returns (Trade[] memory) {
        return trades;
    }
}