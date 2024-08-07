// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Timelock {
    uint256 public constant MINIMUM_DELAY = 1 hours;
    uint256 public constant MAXIMUM_DELAY = 30 days;
    uint256 public constant GRACE_PERIOD = 14 days;

    address public admin;
    address public pendingAdmin;
    uint256 public delay;

    mapping(bytes32 => bool) public queuedTransactions;

    event NewAdmin(address indexed newAdmin);
    event NewPendingAdmin(address indexed newPendingAdmin);
    event NewDelay(uint256 indexed newDelay);
    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint256 value, string signature, bytes data, uint256 eta);
    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint256 value, string signature, bytes data, uint256 eta);
    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint256 value, string signature, bytes data, uint256 eta);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Timelock: Caller is not the admin");
        _;
    }

    constructor(uint256 _delay) {
        require(_delay >= MINIMUM_DELAY && _delay <= MAXIMUM_DELAY, "Timelock: Invalid delay");
        admin = msg.sender;
        delay = _delay;
    }

    function setDelay(uint256 _delay) public onlyAdmin {
        require(_delay >= MINIMUM_DELAY && _delay <= MAXIMUM_DELAY, "Timelock: Invalid delay");
        delay = _delay;
        emit NewDelay(_delay);
    }

    function acceptAdmin() public {
        require(msg.sender == pendingAdmin, "Timelock: Caller is not the pending admin");
        admin = pendingAdmin;
        pendingAdmin = address(0);
        emit NewAdmin(admin);
    }

    function setPendingAdmin(address _pendingAdmin) public onlyAdmin {
        pendingAdmin = _pendingAdmin;
        emit NewPendingAdmin(_pendingAdmin);
    }

    function queueTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 eta) public onlyAdmin returns (bytes32) {
        require(eta >= block.timestamp + delay, "Timelock: Estimated execution block is before current block");
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = true;
        emit QueueTransaction(txHash, target, value, signature, data, eta);
        return txHash;
    }

    function cancelTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 eta) public onlyAdmin {
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = false;
        emit CancelTransaction(txHash, target, value, signature, data, eta);
    }

    function executeTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 eta) public payable onlyAdmin returns (bytes memory) {
        bytes32 txHash = keccak256(abi.encode(target, value, signature, data, eta));
        require(queuedTransactions[txHash], "Timelock: Transaction hasn't been queued");
        require(block.timestamp >= eta, "Timelock: Transaction hasn't surpassed time lock");
        require(block.timestamp <= eta + GRACE_PERIOD, "Timelock: Transaction is stale");

        queuedTransactions[txHash] = false;

        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        (bool success, bytes memory returnData) = target.call{value: value}(callData);
        require(success, "Timelock: Transaction execution reverted.");

        emit ExecuteTransaction(txHash, target, value, signature, data, eta);
        return returnData;
    }
}