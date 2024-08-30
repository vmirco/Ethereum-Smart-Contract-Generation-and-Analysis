// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AccessControl {
    
    struct RoleData {
        mapping (address => bool) members;
    }

    mapping (bytes32 => RoleData) private _roles;
    bytes32 public constant ADMIN_ROLE = keccak256("admin");
    bytes32 public constant MODERATOR_ROLE = keccak256("moderator");

    event RoleGranted(bytes32 indexed role, address indexed account);
    event RoleRevoked(bytes32 indexed role, address indexed account);

    constructor () {
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "AccessControl: must have admin role to access");
        _;
    }
    
    modifier onlyModerator() {
        require(hasRole(MODERATOR_ROLE, msg.sender), "AccessControl: must have moderator role to access");
        _;
    }

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members[account];
    }
    
    function grantRole(bytes32 role, address account) public onlyAdmin {
        _grantRole(role, account);
    }
    
    function revokeRole(bytes32 role, address account) public onlyAdmin {
        _revokeRole(role, account);
    }

    function _grantRole(bytes32 role, address account) private {
        _roles[role].members[account] = true;
        emit RoleGranted(role, account);
    }

    function _revokeRole(bytes32 role, address account) private {
        _roles[role].members[account] = false;
        emit RoleRevoked(role, account);
    }
}