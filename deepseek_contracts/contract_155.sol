// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AccessControl {
    mapping(bytes32 => mapping(address => bool)) private _roles;
    mapping(bytes32 => bytes32) private _roleAdmins;

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role][account];
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roleAdmins[role];
    }

    function grantRole(bytes32 role, address account) public {
        require(hasRole(_roleAdmins[role], msg.sender), "AccessControl: sender must be an admin to grant");
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public {
        require(hasRole(_roleAdmins[role], msg.sender), "AccessControl: sender must be an admin to revoke");
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role) public {
        _revokeRole(role, msg.sender);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal {
        bytes32 previousAdminRole = _roleAdmins[role];
        _roleAdmins[role] = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

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
}

contract RoleBasedAccessControl is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor() {
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    function createRole(bytes32 role, bytes32 adminRole) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "RoleBasedAccessControl: must have admin role to create role");
        _setRoleAdmin(role, adminRole);
    }

    function assignRole(bytes32 role, address account) public {
        require(hasRole(_roleAdmins[role], msg.sender), "RoleBasedAccessControl: sender must be an admin to assign");
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public {
        require(hasRole(_roleAdmins[role], msg.sender), "RoleBasedAccessControl: sender must be an admin to revoke");
        _revokeRole(role, account);
    }
}