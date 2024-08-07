// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AccessControlEntryPoint {
    struct OperatorPermission {
        bool canSetPermissions;
        bool canValidateOperations;
    }

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
        bytes paymasterAndData;
        bytes signature;
    }

    address public owner;
    mapping(address => OperatorPermission) public operatorPermissions;
    mapping(address => uint256) public remainingFees;
    mapping(address => uint256) public remainingValues;

    bytes32 private constant EIP712_DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private constant USER_OPERATION_TYPEHASH = keccak256("UserOperation(address sender,uint256 nonce,bytes initCode,bytes callData,uint256 callGasLimit,uint256 verificationGasLimit,uint256 preVerificationGas,uint256 maxFeePerGas,uint256 maxPriorityFeePerGas,bytes paymasterAndData)");

    bytes32 public DOMAIN_SEPARATOR;

    constructor() {
        owner = msg.sender;
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256("AccessControlEntryPoint"),
                keccak256("1"),
                chainId,
                address(this)
            )
        );
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function setOperatorPermission(address operator, bool canSetPermissions, bool canValidateOperations) external onlyOwner {
        operatorPermissions[operator] = OperatorPermission(canSetPermissions, canValidateOperations);
    }

    function validateUserOperation(UserOperation calldata userOp, bytes32 requestId, uint256 missingAccountFunds) external {
        require(operatorPermissions[msg.sender].canValidateOperations, "No permission to validate operations");
        _validateSignature(userOp, requestId);
        _payPrefund(missingAccountFunds);
    }

    function _validateSignature(UserOperation calldata userOp, bytes32 requestId) internal view {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        USER_OPERATION_TYPEHASH,
                        userOp.sender,
                        userOp.nonce,
                        keccak256(userOp.initCode),
                        keccak256(userOp.callData),
                        userOp.callGasLimit,
                        userOp.verificationGasLimit,
                        userOp.preVerificationGas,
                        userOp.maxFeePerGas,
                        userOp.maxPriorityFeePerGas,
                        keccak256(userOp.paymasterAndData)
                    )
                )
            )
        );
        require(ECDSA.recover(digest, userOp.signature) == userOp.sender, "Invalid signature");
    }

    function _payPrefund(uint256 missingAccountFunds) internal {
        if (missingAccountFunds != 0) {
            require(address(this).balance >= missingAccountFunds, "Insufficient funds");
            payable(msg.sender).transfer(missingAccountFunds);
        }
    }

    function deposit() external payable {
        remainingValues[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(remainingValues[msg.sender] >= amount, "Insufficient balance");
        remainingValues[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
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
}