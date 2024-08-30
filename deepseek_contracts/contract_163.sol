// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AccessControl {
    struct Role {
        mapping(address => bool) members;
        string roleName;
    }

    mapping(bytes32 => Role) private roles;
    mapping(address => bool) private administrators;

    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR");

    event RoleGranted(bytes32 indexed role, address indexed account);
    event RoleRevoked(bytes32 indexed role, address indexed account);
    event AdministratorAdded(address indexed account);
    event AdministratorRemoved(address indexed account);

    modifier onlyAdmin() {
        require(administrators[msg.sender], "Not an administrator");
        _;
    }

    modifier onlyRole(bytes32 role) {
        require(roles[role].members[msg.sender], "Missing role");
        _;
    }

    constructor() {
        administrators[msg.sender] = true;
        emit AdministratorAdded(msg.sender);
        _createRole(MODERATOR_ROLE, "Moderator");
    }

    function addAdministrator(address account) external onlyAdmin {
        administrators[account] = true;
        emit AdministratorAdded(account);
    }

    function removeAdministrator(address account) external onlyAdmin {
        require(account != msg.sender, "Cannot remove yourself");
        administrators[account] = false;
        emit AdministratorRemoved(account);
    }

    function grantRole(bytes32 role, address account) external onlyAdmin {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) external onlyAdmin {
        _revokeRole(role, account);
    }

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return roles[role].members[account];
    }

    function getRoleName(bytes32 role) public view returns (string memory) {
        return roles[role].roleName;
    }

    function _createRole(bytes32 role, string memory roleName) internal {
        roles[role].roleName = roleName;
    }

    function _grantRole(bytes32 role, address account) internal {
        roles[role].members[account] = true;
        emit RoleGranted(role, account);
    }

    function _revokeRole(bytes32 role, address account) internal {
        roles[role].members[account] = false;
        emit RoleRevoked(role, account);
    }
}