// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

contract PancakePairMock {
    address public token0;
    address public token1;
    uint public reserve0;
    uint public reserve1;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint reserve0, uint reserve1);

    constructor() public {
        token0 = address(1); 
        token1 = address(2); 
    }

    function mint(address to) external payable returns (uint liquidity) {
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));
        uint amount0 = balance0 - reserve0;
        uint amount1 = balance1 - reserve1;

        reserve0 = balance0;
        reserve1 = balance1;
        emit Mint(msg.sender, amount0, amount1);
    }

    function burn(address to) external returns (uint amount0, uint amount1) {
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));

        reserve0 = balance0;
        reserve1 = balance1;
        emit Burn(msg.sender, amount0, amount1, to);
    }

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external {
        uint balance0;
        uint balance1;
        { 
            balance0 = IERC20(token0).balanceOf(address(this));
            balance1 = IERC20(token1).balanceOf(address(this));
        }
        require(balance0 >= amount0Out, 'Pancake: INSUFFICIENT_A_AMOUNT');
        require(balance1 >= amount1Out, 'Pancake: INSUFFICIENT_B_AMOUNT');

        emit Swap(msg.sender, amount0Out, amount1Out, to);
    }

    function skim(address to) external {
        
    }

    function sync() external {
        reserve0 = IERC20(token0).balanceOf(address(this));
        reserve1 = IERC20(token1).balanceOf(address(this));
        emit Sync(reserve0, reserve1);
    }
}

interface IERC20{
    function balanceOf(address account) external view returns(uint);
}