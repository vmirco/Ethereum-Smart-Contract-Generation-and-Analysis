// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract AccessControl {
    function _setupRole(bytes32 role, address account) internal virtual { }
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual { }
    function _hasRole(bytes32 role, address account) internal view virtual returns (bool) { }
    function _grantRole(bytes32 role, address account) internal virtual { }
    function _revokeRole(bytes32 role, address account) internal virtual { }
    function _renounceRole(bytes32 role, address account) internal virtual { }
}

contract RoleBasedAccessControl is AccessControl {
    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyAdmin() {
        require(_hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _;
    }

    constructor() {
        _setupRole(ADMIN_ROLE, msg.sender);
        _setRoleAdmin(USER_ROLE, ADMIN_ROLE);
    }

    function grantRole(bytes32 role, address account) public onlyAdmin {
        _grantRole(role, account);
        emit RoleGranted(role, account, msg.sender);
    }

    function revokeRole(bytes32 role, address account) public onlyAdmin {
        _revokeRole(role, account);
        emit RoleRevoked(role, account, msg.sender);
    }

    function checkRole(bytes32 role, address account) public view returns (bool) {
        return _hasRole(role, account);
    }
}