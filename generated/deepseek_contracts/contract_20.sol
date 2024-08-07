// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenSwap {
    string public name = "TokenSwap";
    address public admin;
    uint256 public totalLiquidity;
    uint256 public constant FEE_RATE = 30; // 0.3% fee

    struct Token {
        uint256 balance;
        uint256 decimals;
        string symbol;
    }

    mapping(address => Token) public tokens;
    mapping(address => mapping(address => uint256)) public liquidity;

    event AddLiquidity(address indexed provider, address indexed token, uint256 amount);
    event RemoveLiquidity(address indexed provider, address indexed token, uint256 amount);
    event Swap(address indexed from, address indexed to, uint256 amountIn, uint256 amountOut);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function addToken(address _tokenAddress, uint256 _decimals, string memory _symbol) public onlyAdmin {
        tokens[_tokenAddress] = Token({balance: 0, decimals: _decimals, symbol: _symbol});
    }

    function addLiquidity(address _tokenAddress, uint256 _amount) public payable {
        require(tokens[_tokenAddress].decimals > 0, "Token not supported");
        if (_tokenAddress == address(0)) {
            require(msg.value == _amount, "Incorrect ETH amount");
            tokens[address(0)].balance += _amount;
        } else {
            require(IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _amount), "Transfer failed");
            tokens[_tokenAddress].balance += _amount;
        }
        liquidity[msg.sender][_tokenAddress] += _amount;
        totalLiquidity += _amount;
        emit AddLiquidity(msg.sender, _tokenAddress, _amount);
    }

    function removeLiquidity(address _tokenAddress, uint256 _amount) public {
        require(liquidity[msg.sender][_tokenAddress] >= _amount, "Insufficient liquidity");
        if (_tokenAddress == address(0)) {
            (bool sent, ) = msg.sender.call{value: _amount}("");
            require(sent, "Failed to send ETH");
            tokens[address(0)].balance -= _amount;
        } else {
            require(IERC20(_tokenAddress).transfer(msg.sender, _amount), "Transfer failed");
            tokens[_tokenAddress].balance -= _amount;
        }
        liquidity[msg.sender][_tokenAddress] -= _amount;
        totalLiquidity -= _amount;
        emit RemoveLiquidity(msg.sender, _tokenAddress, _amount);
    }

    function swap(address _tokenIn, address _tokenOut, uint256 _amountIn) public payable {
        require(tokens[_tokenIn].decimals > 0 && tokens[_tokenOut].decimals > 0, "Token not supported");
        uint256 amountInWithFee = _amountIn * (10000 - FEE_RATE) / 10000;
        uint256 amountOut = (amountInWithFee * tokens[_tokenOut].balance) / (tokens[_tokenIn].balance + _amountIn);

        if (_tokenIn == address(0)) {
            require(msg.value == _amountIn, "Incorrect ETH amount");
            tokens[address(0)].balance += _amountIn;
        } else {
            require(IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn), "Transfer failed");
            tokens[_tokenIn].balance += _amountIn;
        }

        if (_tokenOut == address(0)) {
            (bool sent, ) = msg.sender.call{value: amountOut}("");
            require(sent, "Failed to send ETH");
            tokens[address(0)].balance -= amountOut;
        } else {
            require(IERC20(_tokenOut).transfer(msg.sender, amountOut), "Transfer failed");
            tokens[_tokenOut].balance -= amountOut;
        }

        emit Swap(msg.sender, _tokenOut, _amountIn, amountOut);
    }
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}