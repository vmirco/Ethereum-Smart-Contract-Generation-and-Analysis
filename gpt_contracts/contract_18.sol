// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract RoleBasedAccessControl is AccessControl {

    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    event RoleChanged(address indexed user, bytes32 indexed role, string action);

    constructor() {
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    function grantRole(bytes32 role, address account) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an administrator");
        _grantRole(role, account);
        emit RoleChanged(account, role, "granted");
    }

    function revokeRole(bytes32 role, address account) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an administrator");
        _revokeRole(role, account);
        emit RoleChanged(account, role, "revoked");
    }

    function checkUserRole(address account) public view returns (bool) {
        return hasRole(USER_ROLE, account);
    }

    function checkAdminRole(address account) public view returns (bool) {
        return hasRole(ADMIN_ROLE, account);
    }

    function setupAdminRole(address account) public {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an administrator");
        _setupRole(ADMIN_ROLE, account);
    }
}