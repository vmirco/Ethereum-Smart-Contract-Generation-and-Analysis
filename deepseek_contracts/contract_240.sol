// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PermissionedEntryPoint {
    address public owner;
    mapping(address => bool) public operators;
    mapping(bytes32 => bool) public usedHashes;
    uint256 public remainingFees;
    uint256 public remainingValue;

    struct UserOperation {
        address sender;
        uint256 nonce;
        bytes initCode;
        bytes callData;
        uint256 callGasLimit;
        uint256 verificationGasLimit;
        uint256 preVerificationGas;
        uint256 maxFeePerGas;
        uint256 maxPriorityFeePerGas;
        address paymaster;
        bytes paymasterData;
        bytes signature;
    }

    event OperatorPermissionSet(address indexed operator, bool permission);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyOperator() {
        require(operators[msg.sender], "Not an operator");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function initialize(address _owner) external {
        require(owner == address(0), "Already initialized");
        owner = _owner;
    }

    function setOperatorPermission(address operator, bool permission) external onlyOwner {
        operators[operator] = permission;
        emit OperatorPermissionSet(operator, permission);
    }

    function validateUserOperation(UserOperation calldata userOp, bytes32 requestId, uint256 missingAccountFunds) external onlyOperator {
        require(!usedHashes[requestId], "User operation already used");
        usedHashes[requestId] = true;

        bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
            keccak256("UserOperation(address sender,uint256 nonce,bytes initCode,bytes callData,uint256 callGasLimit,uint256 verificationGasLimit,uint256 preVerificationGas,uint256 maxFeePerGas,uint256 maxPriorityFeePerGas,address paymaster,bytes paymasterData)"),
            userOp.sender,
            userOp.nonce,
            keccak256(userOp.initCode),
            keccak256(userOp.callData),
            userOp.callGasLimit,
            userOp.verificationGasLimit,
            userOp.preVerificationGas,
            userOp.maxFeePerGas,
            userOp.maxPriorityFeePerGas,
            userOp.paymaster,
            keccak256(userOp.paymasterData)
        )));

        address recoveredAddress = ECDSA.recover(digest, userOp.signature);
        require(recoveredAddress == userOp.sender, "Invalid signature");

        if (missingAccountFunds > 0) {
            remainingFees += missingAccountFunds;
            remainingValue += missingAccountFunds;
        }
    }

    function _hashTypedDataV4(bytes32 structHash) internal view returns (bytes32) {
        return ECDSA.toTypedDataHash(domainSeparator(), structHash);
    }

    function domainSeparator() public view returns (bytes32) {
        return keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256(bytes("PermissionedEntryPoint")),
            keccak256(bytes("1")),
            block.chainid,
            address(this)
        ));
    }
}

library ECDSA {
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            revert("ECDSA: invalid signature 'v' value");
        }

        return ecrecover(hash, v, r, s);
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}