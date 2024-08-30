// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: Unable to send value, recipient may have reverted");
    }
}

contract Initializable {
    address public initializer;
    uint256 public initializationBlock;

    modifier initializer() {
        require(initializer == address(0), "already initialized");
        initializer = msg.sender;
        initializationBlock = block.number;
        _;
    }

    modifier reinitializer() {
        require(initializer != address(0), "not initialized yet");
        require(initializationBlock < block.number, "reinitialization not possible in same block");
        _;
    }

    function getInitializer() public view returns (address) {
        return initializer;
    }

    function getInitializationBlock() public view returns (uint256) {
        return initializationBlock;
    }

    function initialize() public initializer {
    }

    function reinitialize() public reinitializer {
        initializer = msg.sender;
        initializationBlock = block.number;
    }
}