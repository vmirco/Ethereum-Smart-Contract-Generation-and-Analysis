// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AccessControl {
    struct Permission {
        bool canCall;
        bool isPublic;
    }

    mapping(address => Permission) private permissions;
    address private owner;

    event PermissionUpdated(address indexed user, bool canCall, bool isPublic);
    event AccessChecked(address indexed user, bool canCall, bool isPublic);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function updatePermission(address user, bool canCall, bool isPublic) public onlyOwner {
        permissions[user] = Permission(canCall, isPublic);
        emit PermissionUpdated(user, canCall, isPublic);
    }

    function batchUpdatePermissions(address[] memory users, bool[] memory canCall, bool[] memory isPublic) public onlyOwner {
        require(users.length == canCall.length && users.length == isPublic.length, "Input arrays must be of equal length");
        for (uint256 i = 0; i < users.length; i++) {
            permissions[users[i]] = Permission(canCall[i], isPublic[i]);
            emit PermissionUpdated(users[i], canCall[i], isPublic[i]);
        }
    }

    function checkAccess(address user) public view returns (bool, bool) {
        Permission memory perm = permissions[user];
        return (perm.canCall, perm.isPublic);
    }

    function logAccessCheck(address user) public {
        (bool canCall, bool isPublic) = checkAccess(user);
        emit AccessChecked(user, canCall, isPublic);
    }
}