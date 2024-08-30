// SPDX-License-Identifier: MIT

pragma solidity >=0.5.16 <0.9.0;

contract SimpleLiquidity {

    /**
     * @dev Dictionary that maps pairs of tokens to the balance
     *      The balance represents the liquidity pool's total balance
     **/
    mapping(address => mapping(address => uint256)) public poolBalance;

    /**
     * @dev Function that adds liquidity to the pool, for the pair tokenA-tokenB
     * @param tokenA: First token of the pair
     * @param tokenB: Second token of the pair
     * @param amountA: Amount of tokenA to add
     * @param amountB: Amount of tokenB to add
     **/
    function addLiquidity(address tokenA, address tokenB, uint256 amountA, uint256 amountB) public {
        // Here you would need to interact with the token contracts themselves
        // to allow for the transfer of the tokens to the smart contract.
        // Remember, the tokens are not actually 'in' the smart contract, 
        // they are only locked by it. To simplify, I'm just going to increase the balance.

        poolBalance[tokenA][tokenB] += amountA;
        poolBalance[tokenB][tokenA] += amountB;
    }

}