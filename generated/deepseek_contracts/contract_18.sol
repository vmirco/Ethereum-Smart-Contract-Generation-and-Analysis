// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RoleBasedAccessControl {
    struct Role {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => Role) private roles;

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        require(hasRole(role, msg.sender), "RBAC: caller does not have the role");
        _;
    }

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return roles[role].members[account];
    }

    function getAdminRole(bytes32 role) public view returns (bytes32) {
        return roles[role].adminRole;
    }

    function setAdminRole(bytes32 role, bytes32 adminRole) public onlyRole(getAdminRole(role)) {
        roles[role].adminRole = adminRole;
    }

    function grantRole(bytes32 role, address account) public onlyRole(getAdminRole(role)) {
        roles[role].members[account] = true;
        emit RoleGranted(role, account, msg.sender);
    }

    function revokeRole(bytes32 role, address account) public onlyRole(getAdminRole(role)) {
        roles[role].members[account] = false;
        emit RoleRevoked(role, account, msg.sender);
    }
}