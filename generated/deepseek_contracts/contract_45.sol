// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenMarket {
    struct Token {
        address tokenAddress;
        string name;
        string symbol;
        uint8 decimals;
    }

    struct Trade {
        address trader;
        address tokenAddress;
        uint256 amount;
        uint256 price;
        bool isBuy;
    }

    Token[] public tokens;
    Trade[] public trades;
    mapping(address => mapping(address => uint256)) public balances;

    event TokenAdded(address indexed tokenAddress, string name, string symbol, uint8 decimals);
    event TokenRemoved(address indexed tokenAddress);
    event TradeExecuted(address indexed trader, address indexed tokenAddress, uint256 amount, uint256 price, bool isBuy);

    modifier validToken(address _tokenAddress) {
        require(_tokenAddress != address(0), "Invalid token address");
        bool found = false;
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i].tokenAddress == _tokenAddress) {
                found = true;
                break;
            }
        }
        require(found, "Token not found");
        _;
    }

    function addToken(address _tokenAddress, string memory _name, string memory _symbol, uint8 _decimals) public {
        tokens.push(Token(_tokenAddress, _name, _symbol, _decimals));
        emit TokenAdded(_tokenAddress, _name, _symbol, _decimals);
    }

    function removeToken(address _tokenAddress) public validToken(_tokenAddress) {
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i].tokenAddress == _tokenAddress) {
                tokens[i] = tokens[tokens.length - 1];
                tokens.pop();
                emit TokenRemoved(_tokenAddress);
                break;
            }
        }
    }

    function executeTrade(address _tokenAddress, uint256 _amount, uint256 _price, bool _isBuy) public validToken(_tokenAddress) {
        require(_amount > 0, "Amount must be greater than 0");
        require(_price > 0, "Price must be greater than 0");

        if (_isBuy) {
            require(balances[msg.sender][address(0)] >= _amount * _price, "Insufficient balance");
            balances[msg.sender][address(0)] -= _amount * _price;
            balances[msg.sender][_tokenAddress] += _amount;
        } else {
            require(balances[msg.sender][_tokenAddress] >= _amount, "Insufficient token balance");
            balances[msg.sender][_tokenAddress] -= _amount;
            balances[msg.sender][address(0)] += _amount * _price;
        }

        trades.push(Trade(msg.sender, _tokenAddress, _amount, _price, _isBuy));
        emit TradeExecuted(msg.sender, _tokenAddress, _amount, _price, _isBuy);
    }

    function deposit() public payable {
        balances[msg.sender][address(0)] += msg.value;
    }

    function withdraw(uint256 _amount) public {
        require(balances[msg.sender][address(0)] >= _amount, "Insufficient balance");
        balances[msg.sender][address(0)] -= _amount;
        payable(msg.sender).transfer(_amount);
    }
}