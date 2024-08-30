// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract CrossChainEnabled {
    function isCrossChain() internal view virtual returns (bool);
    function crossChainSender() internal view virtual returns (address);
}

library LibArbitrumL1 {
    address public immutable bridge;

    constructor(address _bridge) {
        bridge = _bridge;
    }

    function getBridge() internal view returns (address) {
        return bridge;
    }

    function isArbitrumL1() internal view returns (bool) {
        // Dummy implementation for demonstration
        return true;
    }

    function getL1Sender() internal view returns (address) {
        // Dummy implementation for demonstration
        return address(0);
    }
}

contract CrossChainContract is CrossChainEnabled {
    using LibArbitrumL1 for LibArbitrumL1;

    address public immutable bridgeAddress;

    constructor(address _bridgeAddress) {
        bridgeAddress = _bridgeAddress;
        LibArbitrumL1.constructor(_bridgeAddress);
    }

    function isCrossChain() internal view override returns (bool) {
        return LibArbitrumL1.isArbitrumL1();
    }

    function crossChainSender() internal view override returns (address) {
        return LibArbitrumL1.getL1Sender();
    }

    function getBridgeAddress() public view returns (address) {
        return bridgeAddress;
    }

    function getCrossChainSender() public view returns (address) {
        if (isCrossChain()) {
            return crossChainSender();
        } else {
            return address(0);
        }
    }
}