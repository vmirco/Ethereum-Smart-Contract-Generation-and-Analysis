// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract AccessControl is Context {
    mapping (address => uint8) private _roles;

    uint8 constant ROLE_DAO_ADMIN = 1;
    uint8 constant ROLE_OPERATOR = 2;
    uint8 constant ROLE_CALLER = 3;
    uint8 constant ROLE_CALLEE = 4;

    event RoleGranted(address indexed account, uint8 role);
    event RoleRevoked(address indexed account, uint8 role);

    constructor () {
        _setRole(_msgSender(), ROLE_DAO_ADMIN);
    }

    modifier onlyDAOAdmin() {
        require(_roles[_msgSender()] == ROLE_DAO_ADMIN, "AccessControl: not a DAO admin");
        _;
    }

    modifier onlyOperator() {
        require(_roles[_msgSender()] == ROLE_OPERATOR, "AccessControl: not an operator");
        _;
    }

    modifier onlyCaller() {
        require(_roles[_msgSender()] == ROLE_CALLER, "AccessControl: not a caller");
        _;
    }

    modifier onlyCallee() {
        require(_roles[_msgSender()] == ROLE_CALLEE, "AccessControl: not a callee");
        _;
    }

    function grantRole(address account, uint8 role) public onlyDAOAdmin {
        _setRole(account, role);
    }

    function revokeRole(address account, uint8 role) public onlyDAOAdmin {
        require(_roles[account] == role, "AccessControl: target does not have role");
        delete _roles[account];
        emit RoleRevoked(account, role);
    }

    function _setRole(address account, uint8 role) internal {
        _roles[account] = role;
        emit RoleGranted(account, role);
    }
}