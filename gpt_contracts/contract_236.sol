// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//include AccessControlUpgradeable in the code

abstract contract AccessControlUpgradeable {
    function grantRole(bytes32 role, address account) public virtual;
    function revokeRole(bytes32 role, address account) public virtual;
    function renounceRole(bytes32 role, address account) public virtual;
    function hasRole(bytes32 role, address account) public view virtual returns (bool);
}

contract AdminRoleManagement is AccessControlUpgradeable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "AdminRoleManagement: caller is not an admin");
        _;
    }

    constructor() {
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    function grantAdminRole(address account) public onlyAdmin {
        grantRole(ADMIN_ROLE, account);
    }

    function revokeAdminRole(address account) public onlyAdmin {
        revokeRole(ADMIN_ROLE, account);
    }

    function renounceAdminRole() public {
        renounceRole(ADMIN_ROLE, msg.sender);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        grantRole(role, account);
    }
}