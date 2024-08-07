// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenSwap {
    // Struct to hold token information
    struct Token {
        address tokenAddress;
        uint256 reserve;
    }

    // Mapping to store token pairs and their reserves
    mapping(address => mapping(address => Token)) public tokenPairs;

    // Event emitted when tokens are swapped
    event Swap(address indexed sender, uint256 amountIn, uint256 amountOut, address indexed tokenIn, address indexed tokenOut);

    // Event emitted when liquidity is added
    event AddLiquidity(address indexed provider, uint256 amountTokenA, uint256 amountTokenB, uint256 liquidity);

    // Event emitted when liquidity is removed
    event RemoveLiquidity(address indexed provider, uint256 amountTokenA, uint256 amountTokenB, uint256 liquidity);

    // Function to swap tokens
    function swapTokens(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOutMin) external {
        // Retrieve the reserves for the token pair
        Token storage tokenInReserve = tokenPairs[tokenIn][tokenOut];
        Token storage tokenOutReserve = tokenPairs[tokenOut][tokenIn];

        // Update reserves (simplified, no slippage or fee calculation)
        tokenInReserve.reserve += amountIn;
        tokenOutReserve.reserve -= amountOutMin;

        // Emit swap event
        emit Swap(msg.sender, amountIn, amountOutMin, tokenIn, tokenOut);
    }

    // Function to add liquidity
    function addLiquidity(address tokenA, address tokenB, uint256 amountA, uint256 amountB) external {
        // Retrieve the reserves for the token pair
        Token storage tokenAReserve = tokenPairs[tokenA][tokenB];
        Token storage tokenBReserve = tokenPairs[tokenB][tokenA];

        // Update reserves
        tokenAReserve.reserve += amountA;
        tokenBReserve.reserve += amountB;

        // Emit add liquidity event
        emit AddLiquidity(msg.sender, amountA, amountB, amountA + amountB);
    }

    // Function to remove liquidity
    function removeLiquidity(address tokenA, address tokenB, uint256 liquidity) external {
        // Retrieve the reserves for the token pair
        Token storage tokenAReserve = tokenPairs[tokenA][tokenB];
        Token storage tokenBReserve = tokenPairs[tokenB][tokenA];

        // Calculate amounts to remove based on liquidity (simplified)
        uint256 amountA = liquidity / 2;
        uint256 amountB = liquidity / 2;

        // Update reserves
        tokenAReserve.reserve -= amountA;
        tokenBReserve.reserve -= amountB;

        // Emit remove liquidity event
        emit RemoveLiquidity(msg.sender, amountA, amountB, liquidity);
    }

    // Function to query reserves
    function getReserves(address tokenA, address tokenB) external view returns (uint256 reserveA, uint256 reserveB) {
        reserveA = tokenPairs[tokenA][tokenB].reserve;
        reserveB = tokenPairs[tokenB][tokenA].reserve;
    }
}