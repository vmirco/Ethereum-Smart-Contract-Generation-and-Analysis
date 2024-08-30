// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Timelock {
    address public admin;
    address public pendingAdmin;
    uint public delay;
    mapping(bytes32 => bool) public queuedTransactions;

    event NewAdmin(address indexed newAdmin);
    event NewPendingAdmin(address indexed newPendingAdmin);
    event NewDelay(uint indexed newDelay);
    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint eta);
    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint eta);
    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint eta);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Timelock: caller is not the admin");
        _;
    }

    constructor(uint _delay) {
        require(_delay > 0, "Timelock: delay must be greater than 0");
        admin = msg.sender;
        delay = _delay;
    }

    function setDelay(uint _delay) public onlyAdmin {
        require(_delay > 0, "Timelock: delay must be greater than 0");
        delay = _delay;
        emit NewDelay(_delay);
    }

    function acceptAdmin() public {
        require(msg.sender == pendingAdmin, "Timelock: caller is not the pending admin");
        admin = msg.sender;
        pendingAdmin = address(0);
        emit NewAdmin(admin);
    }

    function setPendingAdmin(address newPendingAdmin) public onlyAdmin {
        pendingAdmin = newPendingAdmin;
        emit NewPendingAdmin(newPendingAdmin);
    }

    function queueTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) public onlyAdmin returns (bytes32) {
        require(eta >= block.timestamp + delay, "Timelock: eta is before delay");
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = true;
        emit QueueTransaction(txHash, target, value, signature, data, eta);
        return txHash;
    }

    function cancelTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) public onlyAdmin {
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = false;
        emit CancelTransaction(txHash, target, value, signature, data, eta);
    }

    function executeTransaction(address target, uint value, string memory signature, bytes memory data, uint eta) public payable onlyAdmin returns (bytes memory) {
        require(block.timestamp >= eta, "Timelock: transaction is before eta");
        require(block.timestamp <= eta + delay, "Timelock: transaction is after eta + delay");
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        require(queuedTransactions[txHash], "Timelock: transaction is not queued");
        queuedTransactions[txHash] = false;

        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        (bool success, bytes memory returnData) = target.call{value: value}(callData);
        require(success, "Timelock: transaction execution reverted");

        emit ExecuteTransaction(txHash, target, value, signature, data, eta);
        return returnData;
    }
}