// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AccessControl {
    struct Permission {
        bool canCall;
        bool isPublic;
    }

    mapping(address => Permission) private permissions;
    event AccessModified(address indexed user, bool canCall, bool isPublic);
    event BatchAccessModified(address[] users, bool[] canCall, bool[] isPublic);

    modifier onlyWithPermission(address user) {
        require(permissions[user].canCall, "User does not have call permission");
        _;
    }

    function modifyAccess(address user, bool canCall, bool isPublic) public onlyWithPermission(msg.sender) {
        permissions[user] = Permission(canCall, isPublic);
        emit AccessModified(user, canCall, isPublic);
    }

    function batchModifyAccess(address[] memory users, bool[] memory canCall, bool[] memory isPublic) public onlyWithPermission(msg.sender) {
        require(users.length == canCall.length && users.length == isPublic.length, "Input arrays must have the same length");
        for (uint i = 0; i < users.length; i++) {
            permissions[users[i]] = Permission(canCall[i], isPublic[i]);
        }
        emit BatchAccessModified(users, canCall, isPublic);
    }

    function checkAccess(address user) public view returns (bool canCall, bool isPublic) {
        Permission memory perm = permissions[user];
        return (perm.canCall, perm.isPublic);
    }
}