// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LiquidityRouter is Pausable, Ownable {
    mapping(address => mapping(address => uint256)) public liquidityPools;
    mapping(address => uint256) public totalLiquidity;

    event LiquidityAdded(address indexed tokenA, address indexed tokenB, uint256 amountA, uint256 amountB);
    event LiquidityRemoved(address indexed tokenA, address indexed tokenB, uint256 amountA, uint256 amountB);
    event TokensSwapped(address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

    function addLiquidity(address tokenA, address tokenB, uint256 amountA, uint256 amountB) external whenNotPaused {
        require(tokenA != address(0) && tokenB != address(0), "Invalid token address");
        require(amountA > 0 && amountB > 0, "Amount must be greater than zero");

        liquidityPools[tokenA][tokenB] += amountA;
        liquidityPools[tokenB][tokenA] += amountB;
        totalLiquidity[tokenA] += amountA;
        totalLiquidity[tokenB] += amountB;

        emit LiquidityAdded(tokenA, tokenB, amountA, amountB);
    }

    function removeLiquidity(address tokenA, address tokenB, uint256 amountA, uint256 amountB) external whenNotPaused {
        require(tokenA != address(0) && tokenB != address(0), "Invalid token address");
        require(amountA > 0 && amountB > 0, "Amount must be greater than zero");
        require(liquidityPools[tokenA][tokenB] >= amountA && liquidityPools[tokenB][tokenA] >= amountB, "Insufficient liquidity");

        liquidityPools[tokenA][tokenB] -= amountA;
        liquidityPools[tokenB][tokenA] -= amountB;
        totalLiquidity[tokenA] -= amountA;
        totalLiquidity[tokenB] -= amountB;

        emit LiquidityRemoved(tokenA, tokenB, amountA, amountB);
    }

    function swapTokens(address tokenIn, address tokenOut, uint256 amountIn) external whenNotPaused returns (uint256 amountOut) {
        require(tokenIn != address(0) && tokenOut != address(0), "Invalid token address");
        require(amountIn > 0, "Amount must be greater than zero");
        require(liquidityPools[tokenIn][tokenOut] > 0, "No liquidity for this pair");

        amountOut = (amountIn * liquidityPools[tokenOut][tokenIn]) / (liquidityPools[tokenIn][tokenOut] + amountIn);
        require(amountOut > 0, "Insufficient output amount");

        liquidityPools[tokenIn][tokenOut] += amountIn;
        liquidityPools[tokenOut][tokenIn] -= amountOut;

        emit TokensSwapped(tokenIn, tokenOut, amountIn, amountOut);
    }

    function getAmountOut(address tokenIn, address tokenOut, uint256 amountIn) external view returns (uint256 amountOut) {
        require(tokenIn != address(0) && tokenOut != address(0), "Invalid token address");
        require(amountIn > 0, "Amount must be greater than zero");
        require(liquidityPools[tokenIn][tokenOut] > 0, "No liquidity for this pair");

        amountOut = (amountIn * liquidityPools[tokenOut][tokenIn]) / (liquidityPools[tokenIn][tokenOut] + amountIn);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}