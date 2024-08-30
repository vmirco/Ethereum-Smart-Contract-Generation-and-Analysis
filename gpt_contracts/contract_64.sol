// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// IAddressProvider Interface
interface IAddressProvider {
    function getPriceProvidersAggregator() external view returns (address);
}

// IPriceProvider Interface
interface IPriceProvider {
    function getUSDPrice(address tokenAddress) external view returns (uint256);
    function quote(address baseToken, address quoteToken) external view returns (uint256);
}

// IPriceProvidersAggregator Interface
interface IPriceProvidersAggregator {
    function getDefaultPriceProvider() external view returns (address);
}

contract TokenPriceManager {
    IAddressProvider private addressProvider;

    // Only allowed address modifier
    modifier onlyAllowedAddress() {
        require(msg.sender == address(addressProvider), "OnlyAllowedAddress: caller is not the allowed address");
        _;
    }

    constructor(IAddressProvider _addressProvider) {
        addressProvider = _addressProvider;
    }

    // Update the Address Provider
    function updateAddressProvider(IAddressProvider _addressProvider) external onlyAllowedAddress() {
        addressProvider = _addressProvider;
    }

    // Get the current price of a token in USD
    function getCurrentPriceInUSD(address tokenAddress) external view returns (uint256) {
        IPriceProvidersAggregator aggregator = IPriceProvidersAggregator(addressProvider.getPriceProvidersAggregator());
        IPriceProvider priceProvider = IPriceProvider(aggregator.getDefaultPriceProvider());

        return priceProvider.getUSDPrice(tokenAddress);
    }

    // Quote a token pair
    function quoteTokenPair(address baseToken, address quoteToken) external view returns (uint256) {
        IPriceProvidersAggregator aggregator = IPriceProvidersAggregator(addressProvider.getPriceProvidersAggregator());
        IPriceProvider priceProvider = IPriceProvider(aggregator.getDefaultPriceProvider());

        return priceProvider.quote(baseToken, quoteToken);
    }
}