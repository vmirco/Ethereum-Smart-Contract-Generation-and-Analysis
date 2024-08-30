// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPriceProvidersAggregator {
    function getPriceProvider(address token) external view returns (IPriceProvider);
}

interface IPriceProvider {
    function getPrice(address token) external view returns (uint256);
    function quote(address tokenIn, address tokenOut, uint256 amountIn) external view returns (uint256 amountOut);
}

interface IAddressProvider {
    function getPriceProvidersAggregator() external view returns (IPriceProvidersAggregator);
    function setPriceProvidersAggregator(IPriceProvidersAggregator newAggregator) external;
}

contract PriceQuoter {
    IAddressProvider public addressProvider;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    address public owner;

    constructor(IAddressProvider _addressProvider) {
        addressProvider = _addressProvider;
        owner = msg.sender;
    }

    function getCurrentPriceInUSD(address token) public view returns (uint256) {
        IPriceProvidersAggregator aggregator = addressProvider.getPriceProvidersAggregator();
        IPriceProvider provider = aggregator.getPriceProvider(token);
        return provider.getPrice(token);
    }

    function quoteTokenPair(address tokenIn, address tokenOut, uint256 amountIn) public view returns (uint256) {
        IPriceProvidersAggregator aggregator = addressProvider.getPriceProvidersAggregator();
        IPriceProvider provider = aggregator.getPriceProvider(tokenIn);
        return provider.quote(tokenIn, tokenOut, amountIn);
    }

    function updateAddressProvider(IAddressProvider newAddressProvider) public onlyOwner {
        addressProvider = newAddressProvider;
    }
}