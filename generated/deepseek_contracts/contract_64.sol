// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPriceProvidersAggregator {
    function getPriceProvider(address token) external view returns (IPriceProvider);
}

interface IPriceProvider {
    function getPrice(address token) external view returns (uint256);
    function getPriceInUSD(address token) external view returns (uint256);
}

interface IAddressProvider {
    function getPriceProvidersAggregator() external view returns (IPriceProvidersAggregator);
}

contract PriceQuoter {
    IAddressProvider public addressProvider;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(address _addressProvider) {
        addressProvider = IAddressProvider(_addressProvider);
        owner = msg.sender;
    }

    function updateAddressProvider(address _newAddressProvider) external onlyOwner {
        addressProvider = IAddressProvider(_newAddressProvider);
    }

    function getPriceInUSD(address token) public view returns (uint256) {
        IPriceProvidersAggregator aggregator = addressProvider.getPriceProvidersAggregator();
        IPriceProvider provider = aggregator.getPriceProvider(token);
        return provider.getPriceInUSD(token);
    }

    function quoteTokenPair(address tokenA, address tokenB) public view returns (uint256 priceAInUSD, uint256 priceBInUSD) {
        priceAInUSD = getPriceInUSD(tokenA);
        priceBInUSD = getPriceInUSD(tokenB);
    }
}