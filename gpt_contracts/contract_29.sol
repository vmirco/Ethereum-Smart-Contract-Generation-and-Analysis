// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Timelock {
    address public admin;
    address public pendingAdmin;
    uint public delay;

    mapping(bytes32 => bool) public queuedTransactions;

    event NewPendingAdmin(address indexed newAdmin);
    event SetDelay(uint delay);
    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,  bytes data, uint eta);
    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,  bytes data, uint eta);
    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,  bytes data, uint eta);

    constructor(address admin_, uint delay_) {
        require(delay_ >= 0, "Timelock::constructor: Delay must not be negative");
        admin = admin_;
        delay = delay_;
    }

    function setDelay(uint delay_) public {
        require(msg.sender == address(this), "Timelock::setDelay: Only callable by self");
        require(delay_ >= 0, "Timelock::setDelay: Delay must not be negative");
        delay = delay_;

        emit SetDelay(delay);
    }

    function acceptAdmin() public {
        require(msg.sender == pendingAdmin, "Timelock::acceptAdmin: Acceptance can only be done by pending admin");
        admin = msg.sender;
        pendingAdmin = address(0);
    }

    function setPendingAdmin(address pendingAdmin_) public {
        require(msg.sender == address(this), "Timelock::setPendingAdmin: Only callable by self");
        pendingAdmin = pendingAdmin_;

        emit NewPendingAdmin(pendingAdmin);
    }

    function queueTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) public returns (bytes32) {
        require(msg.sender == admin, "Timelock::queueTransaction: Only callable by admin");
        require(eta >= block.timestamp + delay, "Timelock::queueTransaction: ETA too soon");

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = true;

        emit QueueTransaction(txHash, target, value, signature, data, eta);
        return txHash;
    }

    function cancelTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) public {
        require(msg.sender == admin, "Timelock::cancelTransaction: Only callable by admin");

        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = false;

        emit CancelTransaction(txHash, target, value, signature, data, eta);
    }

    function executeTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) public payable returns (bool) {
        require(msg.sender == admin, "Timelock::executeTransaction: Only callable by admin");

        // Hash values to get unique identifier for queued transaction
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        require(queuedTransactions[txHash], "Timelock::executeTransaction: Transaction hasn't been queued.");
        require(block.timestamp >= eta, "Timelock::executeTransaction: Transaction hasn't surpassed time lock.");
        require(block.timestamp <= eta + delay, "Timelock::executeTransaction: Transaction is stale.");

        queuedTransactions[txHash] = false;

        bool success = false;
        // solium-disable-next-line security/no-call-value
        (success, data) = target.call{value: value}(abi.encodeWithSignature(signature, data));
        require(success, "Timelock::executeTransaction: Transaction execution unsuccessful.");

        emit ExecuteTransaction(txHash, target, value, signature, data, eta);

        return success;
    }
}