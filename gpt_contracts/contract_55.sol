// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AccessControl {
    mapping(address => bool) public accessRegistry;
    mapping(address => mapping(string => bool)) public permissionRegistry;

    event AccessGranted(address indexed user);
    event AccessRevoked(address indexed user);

    event PermissionGranted(address indexed user, string permission);
    event PermissionRevoked(address indexed user, string permission);

    address public admin;
    
    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "Caller is not an admin");
        _;
    }

    function grantAccess(address user) public onlyAdmin {
        accessRegistry[user] = true;
        emit AccessGranted(user);
    }

    function revokeAccess(address user) public onlyAdmin {
        accessRegistry[user] = false;
        emit AccessRevoked(user);
    }

    function batchGrantAccess(address[] memory users) public onlyAdmin {
        for (uint i = 0; i < users.length; i++) {
            grantAccess(users[i]);
        }
    }

    function batchRevokeAccess(address[] memory users) public onlyAdmin {
        for (uint i = 0; i < users.length; i++) {
            revokeAccess(users[i]);
        }
    }

    function grantPermission(address user, string memory permission) public onlyAdmin {
        permissionRegistry[user][permission] = true;
        emit PermissionGranted(user, permission);
    }

    function revokePermission(address user, string memory permission) public onlyAdmin {
        permissionRegistry[user][permission] = false;
        emit PermissionRevoked(user, permission);
    }

    function batchGrantPermission(address[] memory users, string memory permission) public onlyAdmin {
        for (uint i = 0; i < users.length; i++) {
            grantPermission(users[i], permission);
        }
    }

    function batchRevokePermission(address[] memory users, string memory permission) public onlyAdmin {
        for (uint i = 0; i < users.length; i++) {
            revokePermission(users[i], permission);
        }
    }

    function checkAccess(address user) public view returns(bool) {
        return accessRegistry[user];
    }

    function checkPermission(address user, string memory permission) public view returns(bool) {
        return permissionRegistry[user][permission];
    }

}