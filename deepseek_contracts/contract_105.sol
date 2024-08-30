// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RoleBasedAccessControl {
    // Role definitions
    bytes32 public constant DAO_ADMIN = keccak256("DAO_ADMIN");
    bytes32 public constant OPERATOR = keccak256("OPERATOR");
    bytes32 public constant CALLER = keccak256("CALLER");
    bytes32 public constant CALLEE = keccak256("CALLEE");

    // Mapping from role to account to boolean (true if account has role)
    mapping(bytes32 => mapping(address => bool)) private _roles;

    // Events
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    // Modifiers
    modifier onlyRole(bytes32 role) {
        require(_roles[role][msg.sender], "RoleBasedAccessControl: sender does not have the required role");
        _;
    }

    // Constructor
    constructor() {
        _grantRole(DAO_ADMIN, msg.sender);
    }

    // Role management functions
    function grantRole(bytes32 role, address account) external onlyRole(DAO_ADMIN) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) external onlyRole(DAO_ADMIN) {
        _revokeRole(role, account);
    }

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role][account];
    }

    // Internal role management functions
    function _grantRole(bytes32 role, address account) internal {
        if (!hasRole(role, account)) {
            _roles[role][account] = true;
            emit RoleGranted(role, account, msg.sender);
        }
    }

    function _revokeRole(bytes32 role, address account) internal {
        if (hasRole(role, account)) {
            _roles[role][account] = false;
            emit RoleRevoked(role, account, msg.sender);
        }
    }

    // Example functions with role-based access control
    function daoAdminFunction() external onlyRole(DAO_ADMIN) {
        // Functionality for DAO_ADMIN
    }

    function operatorFunction() external onlyRole(OPERATOR) {
        // Functionality for OPERATOR
    }

    function callerFunction() external onlyRole(CALLER) {
        // Functionality for CALLER
    }

    function calleeFunction() external onlyRole(CALLEE) {
        // Functionality for CALLEE
    }
}