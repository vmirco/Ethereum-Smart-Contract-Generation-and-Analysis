// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// OpenZeppelin's Pausable contract
abstract contract Pausable {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
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

// OpenZeppelin's Ownable contract
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
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
    mapping(address => mapping(address => uint256)) public reserves;

    event AddLiquidity(address indexed tokenA, address indexed tokenB, uint256 amount);
    event RemoveLiquidity(address indexed tokenA, address indexed tokenB, uint256 amount);
    event Swap(address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

    // Add liquidity to a token pair
    function addLiquidity(address tokenA, address tokenB, uint256 amount) public whenNotPaused onlyOwner {
        // Update the reserves
        reserves[tokenA][tokenB] += amount;
        reserves[tokenB][tokenA] += amount;
        
        // Emit event
        emit AddLiquidity(tokenA, tokenB, amount);
    }

    // Remove liquidity from a token pair
    function removeLiquidity(address tokenA, address tokenB, uint256 amount) public whenNotPaused onlyOwner {
        // Check the reserves
        require(reserves[tokenA][tokenB] >= amount && reserves[tokenB][tokenA] >= amount, "Not enough liquidity");

        // Update the reserves
        reserves[tokenA][tokenB] -= amount;
        reserves[tokenB][tokenA] -= amount;
        
        // Emit event
        emit RemoveLiquidity(tokenA, tokenB, amount);
    }

    // Swap tokens
    function swap(address tokenIn, address tokenOut, uint256 amountIn) public whenNotPaused returns (uint256) {
        // Check the reserves
        require(reserves[tokenIn][tokenOut] >= amountIn, "Not enough liquidity");

        // Calculate the amount out using a simple equation (amountIn / reserveIn) * reserveOut
        uint256 amountOut = (amountIn / reserves[tokenIn][tokenOut]) * reserves[tokenOut][tokenIn];

        // Update the reserves
        reserves[tokenIn][tokenOut] -= amountIn;
        reserves[tokenOut][tokenIn] += amountOut;
        
        // Emit event
        emit Swap(tokenIn, tokenOut, amountIn, amountOut);

        return amountOut;
    }

    // Get the amount of tokens out given the amount in
    function getAmountOut(address tokenIn, address tokenOut, uint256 amountIn) public view returns (uint256) {
        // Check the reserves
        require(reserves[tokenIn][tokenOut] >= amountIn, "Not enough liquidity");

        // Calculate the amount out using a simple equation (amountIn / reserveIn) * reserveOut
        uint256 amountOut = (amountIn / reserves[tokenIn][tokenOut]) * reserves[tokenOut][tokenIn];

        return amountOut;
    }

    // Pause contract
    function pause() public onlyOwner {
        _pause();
    }

    // Unpause contract
    function unpause() public onlyOwner {
        _unpause();
    }
}