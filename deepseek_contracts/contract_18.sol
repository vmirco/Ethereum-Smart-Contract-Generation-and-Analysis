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
    event AdminRoleSet(bytes32 indexed role, bytes32 indexed adminRole, address indexed sender);

    modifier onlyRoleAdmin(bytes32 role) {
        require(isAdmin(role, msg.sender), "Must be admin");
        _;
    }

    function isAdmin(bytes32 role, address account) public view returns (bool) {
        return roles[role].members[account];
    }

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return roles[role].members[account];
    }

    function getAdminRole(bytes32 role) public view returns (bytes32) {
        return roles[role].adminRole;
    }

    function setAdminRole(bytes32 role, bytes32 adminRole) public onlyRoleAdmin(role) {
        roles[role].adminRole = adminRole;
        emit AdminRoleSet(role, adminRole, msg.sender);
    }

    function grantRole(bytes32 role, address account) public onlyRoleAdmin(role) {
        roles[role].members[account] = true;
        emit RoleGranted(role, account, msg.sender);
    }

    function revokeRole(bytes32 role, address account) public onlyRoleAdmin(role) {
        roles[role].members[account] = false;
        emit RoleRevoked(role, account, msg.sender);
    }
}