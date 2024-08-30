// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Pausable {
    bool private _paused;

    event Paused(address account);
    event Unpaused(address account);

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract LiquidityRouter is Pausable, Ownable {
    mapping(address => mapping(address => uint256)) private _balances;

    event LiquidityAdded(address indexed tokenA, address indexed tokenB, uint256 amountA, uint256 amountB);
    event LiquidityRemoved(address indexed tokenA, address indexed tokenB, uint256 amountA, uint256 amountB);
    event TokensSwapped(address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

    function addLiquidity(address tokenA, address tokenB, uint256 amountA, uint256 amountB) external whenNotPaused {
        require(tokenA != tokenB, "LiquidityRouter: TOKEN_MISMATCH");
        require(amountA > 0 && amountB > 0, "LiquidityRouter: INSUFFICIENT_INPUT_AMOUNT");

        _balances[tokenA][tokenB] += amountA;
        _balances[tokenB][tokenA] += amountB;

        emit LiquidityAdded(tokenA, tokenB, amountA, amountB);
    }

    function removeLiquidity(address tokenA, address tokenB, uint256 amountA, uint256 amountB) external whenNotPaused {
        require(tokenA != tokenB, "LiquidityRouter: TOKEN_MISMATCH");
        require(amountA > 0 && amountB > 0, "LiquidityRouter: INSUFFICIENT_INPUT_AMOUNT");
        require(_balances[tokenA][tokenB] >= amountA && _balances[tokenB][tokenA] >= amountB, "LiquidityRouter: INSUFFICIENT_LIQUIDITY");

        _balances[tokenA][tokenB] -= amountA;
        _balances[tokenB][tokenA] -= amountB;

        emit LiquidityRemoved(tokenA, tokenB, amountA, amountB);
    }

    function swapTokens(address tokenIn, address tokenOut, uint256 amountIn) external whenNotPaused returns (uint256 amountOut) {
        require(tokenIn != tokenOut, "LiquidityRouter: TOKEN_MISMATCH");
        require(amountIn > 0, "LiquidityRouter: INSUFFICIENT_INPUT_AMOUNT");
        require(_balances[tokenIn][tokenOut] > 0, "LiquidityRouter: INSUFFICIENT_LIQUIDITY");

        amountOut = (_balances[tokenIn][tokenOut] * amountIn) / (_balances[tokenIn][tokenOut] + amountIn);
        require(amountOut > 0, "LiquidityRouter: INSUFFICIENT_OUTPUT_AMOUNT");

        _balances[tokenIn][tokenOut] -= amountOut;
        _balances[tokenOut][tokenIn] += amountOut;

        emit TokensSwapped(tokenIn, tokenOut, amountIn, amountOut);
    }

    function getAmountOut(address tokenIn, address tokenOut, uint256 amountIn) external view returns (uint256 amountOut) {
        require(tokenIn != tokenOut, "LiquidityRouter: TOKEN_MISMATCH");
        require(amountIn > 0, "LiquidityRouter: INSUFFICIENT_INPUT_AMOUNT");
        require(_balances[tokenIn][tokenOut] > 0, "LiquidityRouter: INSUFFICIENT_LIQUIDITY");

        amountOut = (_balances[tokenIn][tokenOut] * amountIn) / (_balances[tokenIn][tokenOut] + amountIn);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}