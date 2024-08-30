// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IOutbox {
    function l2ToL1Sender() external view returns (address);
}

contract CrossChainEnabled {
    IOutbox public immutable bridge;

    modifier onlyL2Bridge {
        require(msg.sender == address(bridge), "ONLY_BRIDGE");
        _;
    }

    constructor(address _bridge) {
        bridge = IOutbox(_bridge);
    }

    function crossDomainSend(address _l1Target, bytes memory _data) internal {
        // Placeholder function to be overridden in inherited contracts.
    }

    function crossDomainReceiveMessage() external onlyL2Bridge {
        // Placeholder function to be overridden in inherited contracts.
    }
}

library LibArbitrumL1 {
    function l2ToL1Sender(IOutbox _bridge) internal view returns (address) {
        return _bridge.l2ToL1Sender();
    }
}

contract MyContract is CrossChainEnabled {

    using LibArbitrumL1 for IOutbox;

    constructor(address _bridge) CrossChainEnabled(_bridge) { }

    function getCrossChainStatus() public view returns (bool) {
        address sender = bridge.l2ToL1Sender();
        return sender != address(0);
    }

    function getCrossChainSender() public view returns (address) {
        return bridge.l2ToL1Sender();
    }

    function crossDomainSend(address _l1Target, bytes memory _data) internal override {
        bridge.l2ToL1Sender(); // Use the library method to handle cross-chain send
    }

    function crossDomainReceiveMessage() external override onlyL2Bridge {
        // Placeholder function to be overridden in inherited contracts.
    }
}