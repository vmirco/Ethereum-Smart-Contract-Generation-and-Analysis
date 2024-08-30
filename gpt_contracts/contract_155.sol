pragma solidity ^0.8.0;

contract RoleBasedAccessControl {
    struct Role {
        bool isExists;
        mapping (address => bool) members;
    }

    mapping (bytes32 => Role) private _roles;
    mapping (address => bytes32[]) private _userRoles;

    event RoleCreate(bytes32 indexed roleId);
    event RoleGrant(bytes32 indexed roleId, address indexed account);
    event RoleRevoke(bytes32 indexed roleId, address indexed account);
    
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    constructor() {
        _createRole(ADMIN_ROLE);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    modifier onlyAdmin {
        require(_isRoleGranted(ADMIN_ROLE, msg.sender), "RoleBasedAccessControl: Caller is not an admin");
        _;
    }

    modifier onlyRole(bytes32 roleId) {
        require(_isRoleGranted(roleId, msg.sender), "RoleBasedAccessControl: Caller does not have this role");
        _;
    }

    function createRole(bytes32 roleId) public onlyAdmin {
        _createRole(roleId);
    }

    function grantRole(bytes32 roleId, address account) public onlyAdmin {
        _grantRole(roleId, account);
    }

    function revokeRole(bytes32 roleId, address account) public onlyAdmin {
        _revokeRole(roleId, account);
    }

    function isRoleGranted(bytes32 roleId, address account) public view returns (bool) {
        return _isRoleGranted(roleId, account);
    }

    function getUserRoles(address account) public view returns (bytes32[] memory) {
        return _userRoles[account];
    }

    function _createRole(bytes32 roleId) private {
        require(! _roles[roleId].isExists, "RoleBasedAccessControl: Role already exists");
        _roles[roleId].isExists = true;

        emit RoleCreate(roleId);
    }

    function _grantRole(bytes32 roleId, address account) private {
        require(_roles[roleId].isExists, "RoleBasedAccessControl: Role does not exist");
        require(! _roles[roleId].members[account], "RoleBasedAccessControl: Role already granted");
        _roles[roleId].members[account] = true;
        _userRoles[account].push(roleId);

        emit RoleGrant(roleId, account);
    }

    function _revokeRole(bytes32 roleId, address account) private {
        require(_roles[roleId].isExists, "RoleBasedAccessControl: Role does not exist");
        require(_roles[roleId].members[account], "RoleBasedAccessControl: Role not granted");
        _roles[roleId].members[account] = false;

        for (uint256 i = 0; i < _userRoles[account].length; i++) {
            if (_userRoles[account][i] == roleId) {
                _userRoles[account][i] = _userRoles[account][_userRoles[account].length - 1];
                _userRoles[account].pop();
                break;
            }
        }

        emit RoleRevoke(roleId, account);
    }

    function _isRoleGranted(bytes32 roleId, address account) private view returns (bool) {
        return _roles[roleId].members[account];
    }
}