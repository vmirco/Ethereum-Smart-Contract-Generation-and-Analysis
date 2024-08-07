// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AccessControl {
    struct Role {
        mapping(address => bool) members;
        bytes32 roleName;
    }

    mapping(bytes32 => Role) private roles;
    bytes32[] private roleList;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyRoleMember(bytes32 _role) {
        require(roles[_role].members[msg.sender], "Not a member of the role");
        _;
    }

    constructor() {
        owner = msg.sender;
        _createRole("ADMIN");
        _grantRole("ADMIN", msg.sender);
    }

    function _createRole(bytes32 _roleName) internal {
        require(roles[_roleName].roleName == bytes32(0), "Role already exists");
        roles[_roleName].roleName = _roleName;
        roleList.push(_roleName);
    }

    function createRole(bytes32 _roleName) external onlyOwner {
        _createRole(_roleName);
    }

    function grantRole(bytes32 _role, address _account) external onlyRoleMember("ADMIN") {
        _grantRole(_role, _account);
    }

    function _grantRole(bytes32 _role, address _account) internal {
        require(roles[_role].roleName != bytes32(0), "Role does not exist");
        roles[_role].members[_account] = true;
    }

    function revokeRole(bytes32 _role, address _account) external onlyRoleMember("ADMIN") {
        require(roles[_role].roleName != bytes32(0), "Role does not exist");
        roles[_role].members[_account] = false;
    }

    function isMemberOfRole(bytes32 _role, address _account) public view returns (bool) {
        return roles[_role].members[_account];
    }

    function getRoleList() external view returns (bytes32[] memory) {
        return roleList;
    }
}